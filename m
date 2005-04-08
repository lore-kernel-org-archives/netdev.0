From: Radheka Godse <radheka.godse@intel.com>
Subject: Re: [Bonding-devel] [PATCH 2.6.12-rc2 r16/17] bonding: version, date
 and log update - revised
Date: Fri, 8 Apr 2005 14:53:45 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081406120.14132@localhost.localdomain>
References: <Pine.LNX.4.61.0504081710350.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Radheka Godse <radheka.godse@intel.com>
In-Reply-To: <Pine.LNX.4.61.0504081710350.10355@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>This patch updates the bonding version number and adds entries to
>the change log in bond_main. The major version number is changed to 3
>because of the sysfs interface.
Revised to reflect sysfs stat file removal change!

Signed-off-by: Radheka Godse <radheka.godse@intel.com>

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bonding.h
--- linux-2.6.12-rc2clean/drivers/net/bonding/bonding.h	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bonding.h	2005-04-09 11:19:27.000000000 -0700
@@ -37,8 +37,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"2.6.1"
-#define DRV_RELDATE	"October 29, 2004"
+#define DRV_VERSION	"3.1.6"
+#define DRV_RELDATE	"April 8, 2005"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bond_main.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_main.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2-sans_sysfs_stat/drivers/net/bonding/bond_main.c	2005-04-09 11:18:45.000000000 -0700
@@ -475,6 +475,59 @@
  *        Solution is to move call to dev_remove_pack outside of the
  *        spinlock.
  *        Set version to 2.6.1.
+ * 2004/12/14 - Mitch Williams <mitch.a.williams at intel dot com>
+ *      - Split out bond creation code to allow for future addition of
+ *        sysfs interface.
+ *      - Added extra optional parameter to bond_enslave to return a
+ *        a pointer to the new slave.  This will be used by future
+ *        sysfs functionality.
+ *      - Removed static declaration on some functions and data items.
+ *      Set version to 2.6.3
+ * 2005/02/10 - Mitch Williams <mitch.a.williams at intel dot com>
+ *      - Added sysfs support, including capability to add/remove/change
+ *        any bond at runtime.
+ *      Set version to 3.0.5
+ * 2005/02/18 - Radheka Godse <radheka.godse at intel dot com>
+ *      - Corrected bugs in bond_check_abi_version so sys fs interface can 
+ * 	  be used simultaneously with ifenslave version 1 and above 
+ *      Set version to 3.0.7
+ * 2005/02/23 - Mitch Williams <mitch.a.williams at intel dot com>
+ *      - fixed sysfs bug where the primary could not be cleared
+ *      - ioctls call now grab the sysfs semaphore to prevent race
+ *	  conditions if both ifenslave and sysfs are being used
+ *      Set version to 3.0.8
+ * 2005/03/18 - Radheka Godse <radheka.godse at intel dot com>
+ *      - added ifenslave -c type functionality to sysfs
+ *      - split sysfs stat into separate files for attribs such as
+ *	  MII Status and 802.3ad aggregator values to sysfs
+ * 	- added "name value" format to sysfs "mode" and 
+ *	  "lacp_rate", for e.g., "active-backup 1" or "slow 0" for 
+ *	  consistency and ease of script parsing
+ *	- fixed reversal of octets in arp_ip_targets via sysfs
+ *	- added bonding: <bondname>: prefix to sysfs log messages
+ * 	- sysfs support to handle bond interface re-naming
+ *	- Added log messages to reflect/notify changes in updelay and  
+ *	  downdelay values due to changes to miimon configuration
+ * 	- added arp_ip_targets to /proc entry
+ * 	- trivial fix: added missing modes description to modinfo
+ *	- made "my_ip" a per bond value instead of a global
+ *      Set version to 3.0.9
+ * 2005/03/23 - Mitch Williams <mitch.a.williams at intel dot com>
+ *      - Moved all sysfs entries into /sys/class/net instead of
+ *        of using a standalone subsystem.
+ *      - Added sysfs symlinks between masters and slaves
+ *      - Corrected bug in ALB init where kmalloc is called inside
+ *        a held lock
+ *      Set version to 3.1.0
+ * 2005/04/08 - Radheka Godse <radheka.godse at intel dot com>
+ *      - Corrected behaviour to maintain bond link when changing
+ *	  from arp monitor to miimon and vice versa 
+ *      - Corrected bugs in sysfs unload path when creating bonds
+ * 	  with existing interface names.
+ *      - Added missing bonding: <bondname>: prefix to alb, ad log messages 
+ *      - Removed redundant sysfs stat file since it duplicates slave info 
+ *	  from the proc file
+ *      Set version to 3.1.6
  *
  */
 
