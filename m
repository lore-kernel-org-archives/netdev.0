From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [Bonding-devel] Re: [bonding] Add basic support for dynamic configuration of bond interfaces
Date: Mon, 12 Jan 2004 17:44:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDCC@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Jay Vosburgh" <fubar@us.ibm.com>, <bonding-devel@lists.sourceforge.net>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, "Noam, Amir" <amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I don't disagree with the overall goal of these patches, but 
> I think we might need to pause a bit, and consider how best to 
> configure, add, and remove bonding interfaces, if we are coming
> up with a new interface.

Could sysfs be used for the bonding UI?  Seems like a natural fit.
Something like:

1) load bonding.o

/sys/class/net/
			eth0/
			eth1/
			add_bond		<< write-only file added

2) Create a bond:

# echo "some params" >/sys/class/net/add_bond

/sys/class/net/
			eth0/
			eth1/
			bond0/
				del_bond
				add_if
				del_if
			add_bond

3) Hook up the bond:

# echo "eth0" >/sys/class/net/bond0/add_if
# echo "eth1" >/sys/class/net/bond0/add_if

/sys/class/net/
			eth0/
			eth1/
			bond0/
				-->eth0/
				-->eth1/
				del_bond
				add_if
				del_if
			new_bond

4) Delete the bond:

# echo "byebye" >/sys/class/net/bond0/del_bond

Etc.  The whole kobject API is so clean, this should be trivial to code
up.  Seems like VLAN and bridge modules could follow.

-scott
