From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/7] [au1000]: Use netif_carrier_* instead of IFF_RUNNING
Date: Mon, 28 Mar 2005 02:06:58 +0200
Message-ID: <20050328000658.GO3086@postel.suug.ch>
References: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, source@mvista.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328000610.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/28 00:06:22+02:00 tgraf@suug.ch 
#   [au1000]: Use netif_carrier_* instead of IFF_RUNNING
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
# 
# drivers/net/au1000_eth.c
#   2005/03/28 00:06:10+02:00 tgraf@suug.ch +2 -8
#   [au1000]: Use netif_carrier_* instead of IFF_RUNNING
# 
diff -Nru a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
--- a/drivers/net/au1000_eth.c	2005-03-28 01:08:16 +02:00
+++ b/drivers/net/au1000_eth.c	2005-03-28 01:08:16 +02:00
@@ -1681,10 +1681,6 @@
 		control |= MAC_FULL_DUPLEX;
 	}
 
-	/* fix for startup without cable */
-	if (!link) 
-		dev->flags &= ~IFF_RUNNING;
-
 	aup->mac->control = control;
 	aup->mac->vlan1_tag = 0x8100; /* activate vlan support */
 	au_sync();
@@ -1709,16 +1705,14 @@
 	if_port = dev->if_port;
 	if (aup->phy_ops->phy_status(dev, aup->phy_addr, &link, &speed) == 0) {
 		if (link) {
-			if (!(dev->flags & IFF_RUNNING)) {
+			if (!netif_carrier_ok) {
 				netif_carrier_on(dev);
-				dev->flags |= IFF_RUNNING;
 				printk(KERN_INFO "%s: link up\n", dev->name);
 			}
 		}
 		else {
-			if (dev->flags & IFF_RUNNING) {
+			if (netif_carrier_ok) {
 				netif_carrier_off(dev);
-				dev->flags &= ~IFF_RUNNING;
 				dev->if_port = 0;
 				printk(KERN_INFO "%s: link down\n", dev->name);
 			}
