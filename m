From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [RFC] Wireless extensions rethink
Date: Mon, 7 Jun 2004 11:33:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF6214@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff suggested in an earlier post that there is an opportunity to
totally rethink the wireless extensions now that we have wireless-2.6.

Let's get rid of the iotcl and /proc interfaces as Jeff suggests:

1) iw_handler API goes away and is replaced by struct 
   net_device::wireless_ops (ala ethtool_ops).
2) sysfs get/set mapping for wireless_ops.
3) iw_statistics just becomes one of the wireless_ops.
4) Remove /proc/net/wireless support from wireless.c.  (Already
   have sysfs support for the same :)
5) No private handler support.  If you need private support,
   pass it in some other way (custom sysfs of modparam).  Or, 
   better yet, make a case that others could benefit and move
   into wireless_ops as standard.
6) Convert drivers from iw_handler and iw_statistics to
   wireless_ops.
7) Rewrite iw* tools to use sysfs interface rather than ioctl.
   (scriptable tools?)
8) [Optional] Remove iotcl interface.  May want to keep for
   backward compat with legacy tools?  Easy to map between
   ioctl and wireless_ops in wireless.c.
9) [Open] What to do about wireless events?  Any ideas?

Proposed sysfs layout:

	class/
	`-- net
	    |-- eth[x]
	        |-- wireless
	            |-- statistics
	            |   |-- beacon
			|   |-- crypt
	            |   `-- ...
	            `-- control
	                |-- commit
	                |-- name
	                |-- network_id
	                |-- freq
	                `-- ...

Is someone already working on this???

Comments?

-scott
