From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 1][PATCH 6/6][bonding] backport 2.6 changes to 2.4
Date: Fri, 8 Aug 2003 17:44:43 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081744.43532.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update versions/contributions in header and bump version

diff -Nuarp linux-2.4.22-rc1/Documentation/networking/ifenslave.c linux-2.4.22-rc1-devel/Documentation/networking/ifenslave.c
--- linux-2.4.22-rc1/Documentation/networking/ifenslave.c	Fri Aug  8 14:02:36 2003
+++ linux-2.4.22-rc1-devel/Documentation/networking/ifenslave.c	Fri Aug  8 14:02:37 2003
@@ -140,6 +140,7 @@ static const char *howto_msg =
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
+#include <linux/if.h>
 #include <net/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_bonding.h>
diff -Nuarp linux-2.4.22-rc1/drivers/net/bonding/bond_main.c linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-rc1/drivers/net/bonding/bond_main.c	Fri Aug  8 14:02:36 2003
+++ linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c	Fri Aug  8 14:02:37 2003
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
@@ -382,18 +382,32 @@
  *	  ABI version if receiving unsupported ioctl commands.
  *
  * 2003/05/22 - Jay Vosburgh <fubar at us dot ibm dot com>
+ *	- Fix ifenslave -c causing bond to loose existing routes;
+ *	  added bond_set_mac_address() that doesn't require the
+ *	  bond to be down.
  *	- In conjunction with fix for ifenslave -c, in
  *	  bond_change_active(), changing to the already active slave
  *	  is no longer an error (it successfully does nothing).
  *
  * 2003/06/30 - Amir Noam <amir.noam at intel dot com>
  * 	- Fixed bond_change_active() for ALB/TLB modes.
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
  *
  * 2003/08/06 - Amir Noam <amir.noam at intel dot com>
  * 	- Back port from 2.6: use alloc_netdev(); fix /proc handling;
  *	  made stats a part of bond struct so no need to allocate
  *	  and free it separately; use standard list operations instead
  *	  of pre-allocated array of bonds.
+ *	  Version to 2.3.0.
  */
 
 #include <linux/config.h>
@@ -438,10 +452,10 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION		"2.2.14"
-#define DRV_RELDATE		"June 30, 2003"
-#define DRV_NAME		"bonding"
-#define DRV_DESCRIPTION		"Ethernet Channel Bonding Driver"
+#define DRV_VERSION	"2.3.0"
+#define DRV_RELDATE	"August 6, 2003"
+#define DRV_NAME	"bonding"
+#define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
 static const char *version =
 DRV_NAME ".c:v" DRV_VERSION " (" DRV_RELDATE ")\n";

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
