From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 10/10] [bonding 2.6] misc fixes: missing include, typos, comments
Date: Thu, 4 Sep 2003 20:45:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042045.53223.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
--- a/Documentation/networking/ifenslave.c	Thu Sep  4 20:18:16 2003
+++ b/Documentation/networking/ifenslave.c	Thu Sep  4 20:18:17 2003
@@ -140,6 +140,7 @@ static const char *howto_msg =
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
+#include <linux/if.h>
 #include <net/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_bonding.h>
diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:16 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:17 2003
@@ -278,7 +278,7 @@
  *	  bonding round-robin mode ignoring links after failover/recovery
  *
  * 2003/03/17 - Jay Vosburgh <fubar at us dot ibm dot com>
- *	- kmalloc fix (GPF_KERNEL to GPF_ATOMIC) reported by
+ *	- kmalloc fix (GFP_KERNEL to GFP_ATOMIC) reported by
  *	  Shmulik dot Hen at intel.com.
  *	- Based on discussion on mailing list, changed use of
  *	  update_slave_cnt(), created wrapper functions for adding/removing
@@ -323,22 +323,22 @@
  * 2003/03/18 - Amir Noam <amir.noam at intel dot com>,
  *		Tsippy Mendelson <tsippy.mendelson at intel dot com> and
  *		Shmulik Hen <shmulik.hen at intel dot com>
- *    - Added support for IEEE 802.3ad Dynamic link aggregation mode.
+ *	- Added support for IEEE 802.3ad Dynamic link aggregation mode.
  *
  * 2003/05/01 - Amir Noam <amir.noam at intel dot com>
- *    - Added ABI version control to restore compatibility between
- *      new/old ifenslave and new/old bonding.
+ *	- Added ABI version control to restore compatibility between
+ *	  new/old ifenslave and new/old bonding.
  *
  * 2003/05/01 - Shmulik Hen <shmulik.hen at intel dot com>
- *    - Fixed bug in bond_release_all(): save old value of current_slave
- *      before setting it to NULL.
- *    - Changed driver versioning scheme to include version number instead
- *      of release date (that is already in another field). There are 3
- *      fields X.Y.Z where:
- *            X - Major version - big behavior changes
- *            Y - Minor version - addition of features
- *            Z - Extra version - minor changes and bug fixes
- *      The current version is 1.0.0 as a base line.
+ *	- Fixed bug in bond_release_all(): save old value of current_slave
+ *	  before setting it to NULL.
+ *	- Changed driver versioning scheme to include version number instead
+ *	  of release date (that is already in another field). There are 3
+ *	  fields X.Y.Z where:
+ *		X - Major version - big behavior changes
+ *		Y - Minor version - addition of features
+ *		Z - Extra version - minor changes and bug fixes
+ *	  The current version is 1.0.0 as a base line.
  *
  * 2003/05/01 - Tsippy Mendelson <tsippy.mendelson at intel dot com> and
  *		Amir Noam <amir.noam at intel dot com>
@@ -371,6 +371,43 @@
  *	- Added support for Adaptive load balancing mode which is
  *	  equivalent to Transmit load balancing + Receive load balancing.
  *	  new version - 2.2.0
+ *
+ * 2003/05/15 - Jay Vosburgh <fubar at us dot ibm dot com>
+ *	- Applied fix to activebackup_arp_monitor posted to bonding-devel
+ *	  by Tony Cureington <tony.cureington * hp_com>.  Fixes ARP
+ *	  monitor endless failover bug.  Version to 2.2.10
+ *
+ * 2003/05/20 - Amir Noam <amir.noam at intel dot com>
+ *	- Fixed bug in ABI version control - Don't commit to a specific
+ *	  ABI version if receiving unsupported ioctl commands.
+ *
+ * 2003/05/22 - Jay Vosburgh <fubar at us dot ibm dot com>
+ *	- Fix ifenslave -c causing bond to loose existing routes;
+ *	  added bond_set_mac_address() that doesn't require the
+ *	  bond to be down.
+ *	- In conjunction with fix for ifenslave -c, in
+ *	  bond_change_active(), changing to the already active slave
+ *	  is no longer an error (it successfully does nothing).
+ *
+ * 2003/06/30 - Amir Noam <amir.noam at intel dot com>
+ * 	- Fixed bond_change_active() for ALB/TLB modes.
+ *	  Version to 2.2.14.
+ *
+ * 2003/07/29 - Amir Noam <amir.noam at intel dot com>
+ * 	- Fixed ARP monitoring bug.
+ *	  Version to 2.2.15.
+ *
+ * 2003/07/31 - Willy Tarreau <willy at ods dot org>
+ * 	- Fixed kernel panic when using ARP monitoring without
+ *	  setting bond's IP address.
+ *	  Version to 2.2.16.
+ *
+ * 2003/08/06 - Amir Noam <amir.noam at intel dot com>
+ * 	- Back port from 2.6: use alloc_netdev(); fix /proc handling;
+ *	  made stats a part of bond struct so no need to allocate
+ *	  and free it separately; use standard list operations instead
+ *	  of pre-allocated array of bonds.
+ *	  Version to 2.3.0.
  */
 
 #include <linux/config.h>
@@ -415,10 +452,10 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION		"2.2.0"
-#define DRV_RELDATE		"April 15, 2003"
-#define DRV_NAME		"bonding"
-#define DRV_DESCRIPTION		"Ethernet Channel Bonding Driver"
+#define DRV_VERSION	"2.3.0"
+#define DRV_RELDATE	"August 6, 2003"
+#define DRV_NAME	"bonding"
+#define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
 static const char *version =
 DRV_NAME ".c:v" DRV_VERSION " (" DRV_RELDATE ")\n";
@@ -474,8 +511,8 @@ static struct bond_parm_tbl bond_mode_tb
 {	"balance-xor",		BOND_MODE_XOR},
 {	"broadcast",		BOND_MODE_BROADCAST},
 {	"802.3ad",		BOND_MODE_8023AD},
-{	"tlb",			BOND_MODE_TLB},
-{	"alb",			BOND_MODE_ALB},
+{	"balance-tlb",		BOND_MODE_TLB},
+{	"balance-alb",		BOND_MODE_ALB},
 {	NULL,			-1},
 };
 
@@ -505,7 +542,7 @@ MODULE_PARM_DESC(max_bonds, "Max number 
 MODULE_PARM(miimon, "i");
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 MODULE_PARM(use_carrier, "i");
-MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; 09 for off, 1 for on (default)");
+MODULE_PARM_DESC(use_carrier, "Use netif_carrier_ok (vs MII ioctls) in miimon; 0 for off, 1 for on (default)");
 MODULE_PARM(mode, "s");
 MODULE_PARM_DESC(mode, "Mode of operation : 0 for round robin, 1 for active-backup, 2 for xor");
 MODULE_PARM(arp_interval, "i");
@@ -2988,7 +3025,7 @@ static int bond_ioctl(struct net_device 
 	} else if (orig_app_abi_ver != app_abi_ver) {
 		printk(KERN_ERR
 		       "bonding: Error: already using ifenslave ABI "
-		       "version %d; to upgrade ifenslave to version %d,"
+		       "version %d; to upgrade ifenslave to version %d, "
 		       "you must first reload bonding.\n",
 		       orig_app_abi_ver, app_abi_ver);
 		return -EINVAL;
@@ -3601,8 +3638,8 @@ static int __init bond_init(struct net_d
 	bond->bond_proc_info_file->owner = THIS_MODULE;
 #endif /* CONFIG_PROC_FS */
 
-
 	list_add_tail(&bond->bond_list, &bond_dev_list);
+
 	return 0;
 }
 
