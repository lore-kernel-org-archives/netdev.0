From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 9/10] [bonding 2.6] Add missing free_netdev()
Date: Thu, 11 Sep 2003 17:44:54 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111744.54683.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:40 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:41 2003
@@ -3788,7 +3788,7 @@ static void bond_free_all(void)
 
 		unregister_netdev(dev);
 		bond_deinit(dev);
-		kfree(dev);
+		free_netdev(dev);
 	}
 }
 
@@ -4194,7 +4194,7 @@ static int __init bonding_init(void)
 
 		err = dev_alloc_name(dev, "bond%d");
 		if (err < 0) {
-			kfree(dev);
+			free_netdev(dev);
 			goto out_err;
 		}
 
@@ -4204,7 +4204,7 @@ static int __init bonding_init(void)
 		 */
 		err = bond_init(dev);
 		if (err < 0) {
-			kfree(dev);
+			free_netdev(dev);
 			goto out_err;
 		}
 
@@ -4213,7 +4213,7 @@ static int __init bonding_init(void)
 		err = register_netdevice(dev);
 		if (err < 0) {
 			bond_deinit(dev);
-			kfree(dev);
+			free_netdev(dev);
 			goto out_err;
 		}
 	}
