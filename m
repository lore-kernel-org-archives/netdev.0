From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 6/10] [bonding 2.6] fix OOPS in bonding driver, when removing primary
Date: Thu, 4 Sep 2003 20:45:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042045.07050.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:05 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:18:06 2003
@@ -1941,6 +1941,10 @@ static int bond_release(struct net_devic
 			/* release the slave from its bond */
 			bond_detach_slave(bond, our_slave);
 
+			if (bond->primary_slave == our_slave) {
+				bond->primary_slave = NULL;
+			}
+
 			printk (KERN_INFO "%s: releasing %s interface %s",
 				master->name,
 				(our_slave->state == BOND_STATE_ACTIVE) ? "active" : "backup",
@@ -1957,10 +1961,6 @@ static int bond_release(struct net_devic
 				printk(KERN_INFO
 					"%s: now running without any active interface !\n",
 					master->name);
-			}
-
-			if (bond->primary_slave == our_slave) {
-				bond->primary_slave = NULL;
 			}
 
 			if ((bond_mode == BOND_MODE_TLB) ||
