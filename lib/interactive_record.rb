require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

	def self.table_name
		self.to_s.downcase.pluralize
	end

	def self.column_names
	  DB[:conn].results_as_hash = true

	  sql = "PRAGMA table_info('#{table_name}')"

	  table_info = DB[:conn].execute(sql)
	  column_names = []
	  # binding.pry
	  table_info.each do |column|
	    column_names << column["name"]
	  end
	  # binding.pry
	  column_names.compact
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
  		DB[:conn].execute(sql)
	end

	def self.find_by(hash)
		sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0]} = '#{hash.values[0]}'"
  		DB[:conn].execute(sql)
	end

	def initialize(options={})
	  	options.each do |property, value|
	    	self.send("#{property}=", value)
  		end
	end

	def values_for_insert
		col_values = self.class.column_names.map do |col_name|
			value = self.send("#{col_name}")
			"'#{value}'" if value
		end.compact.join(', ')
	end

	def table_name_for_insert
		self.class.table_name
	end

	def col_names_for_insert
		column_names = self.class.column_names
		column_names.delete('id')
		column_names.compact.join(', ')
	end

	def save
		# binding.pry
		sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  		DB[:conn].execute(sql)
  		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
	end

end