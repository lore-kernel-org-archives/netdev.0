From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Problem with Compaq NC3131 dual eth card
Date: Tue, 6 Jan 2004 11:43:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDAF@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: "Chris Adams" <cmadams@hiwaay.net>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> eth1: OEM i82557/i82558 10/100 Ethernet, FF:FF:FF:FF:FF:FF, IRQ 11.

[snip]

> eth2: Invalid EEPROM checksum 0xffc0, check settings before 
> activating this device!

You're EEPROM image is invalid - looks like it's all 0xFFs - verify with
ethtool -e ethX.  The first three words of the EEPROM should be the MAC
address.  e100 errors out because it wants a valid MAC address.

> Is my card defective or is this a compatibility problem?  Is 
> there a way to fix this?

Get another nic or reprogram the EEPROM in this one.  Ok, so you want to
reprogram the eeprom?  This isn't going to be pretty: 1) get a good
image from a like-NC3131-nic using ethtool -e eth<x>; 2) modify e100 to
skip the check for valid MAC address and valid checksum so the driver
will load; 3) run ethtool -E eth<x> magic 4660 offset <y> value <z>,
where x is your interface, y is the byte offset, and z is byte value to
write.  You can do this by hand, or write a script to parse the output
from ethtool -e; 4) revert e100 back to original  Told you it wasn't
pretty.

Maybe someone could write a little script to 

# ethtool -e eth0 | up_eeprom eth1
 Enter unique MAC address: 00:A0:45:78:90:02

-scott
