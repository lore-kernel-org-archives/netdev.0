From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/7] [tlan]: Use netif_carrier_* intead of IFF_RUNNING
Date: Mon, 28 Mar 2005 02:08:13 +0200
Message-ID: <20050328000813.GQ3086@postel.suug.ch>
References: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chessman@tux.org
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328000610.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/28 00:13:23+02:00 tgraf@suug.ch 
#   [tlan]: Use netif_carrier_* intead of IFF_RUNNING
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
# 
# drivers/net/tlan.c
#   2005/03/28 00:13:12+02:00 tgraf@suug.ch +2 -2
#   [tlan]: Use netif_carrier_* intead of IFF_RUNNING
# 
diff -Nru a/drivers/net/tlan.c b/drivers/net/tlan.c
--- a/drivers/net/tlan.c	2005-03-28 01:08:02 +02:00
+++ b/drivers/net/tlan.c	2005-03-28 01:08:02 +02:00
@@ -2807,7 +2807,7 @@
  	       if (priv->link) {
 		      priv->link = 0;
 	              printk(KERN_DEBUG "TLAN: %s has lost link\n", dev->name);
-	              dev->flags &= ~IFF_RUNNING;
+		      netif_carrier_off(dev);
 		      TLan_SetTimer( dev, (2*HZ), TLAN_TIMER_LINK_BEAT );
 		      return;
 		}
@@ -2817,7 +2817,7 @@
         if ((phy_status & MII_GS_LINK) && !priv->link) {
  		priv->link = 1;
         	printk(KERN_DEBUG "TLAN: %s has reestablished link\n", dev->name);
-        	dev->flags |= IFF_RUNNING;
+		netif_carrier_on(dev);
         }
 
 	/* Setup a new monitor */
