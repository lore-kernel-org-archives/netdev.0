From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 1/2] strip: clash with include/linux/netdevice.h
Date: Mon, 14 Feb 2005 00:30:59 +0100
Message-ID: <20050213233059.GC2060@electric-eye.fr.zoreil.com>
References: <420FBAD3.3020909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <420FBAD3.3020909@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Clash with include/linux/netdevice.h

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/wireless/strip.c~strip-000 drivers/net/wireless/strip.c
--- a/drivers/net/wireless/strip.c~strip-000	2005-02-14 00:11:04.238635826 +0100
+++ b/drivers/net/wireless/strip.c	2005-02-14 00:11:04.242635176 +0100
@@ -2398,10 +2398,11 @@ static int set_mac_address(struct strip 
 	return 0;
 }
 
-static int dev_set_mac_address(struct net_device *dev, void *addr)
+static int strip_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct strip *strip_info = (struct strip *) (dev->priv);
 	struct sockaddr *sa = addr;
+
 	printk(KERN_INFO "%s: strip_set_dev_mac_address called\n", dev->name);
 	set_mac_address(strip_info, (MetricomAddress *) sa->sa_data);
 	return 0;
@@ -2552,7 +2553,7 @@ static void strip_dev_setup(struct net_d
 	dev->hard_start_xmit = strip_xmit;
 	dev->hard_header = strip_header;
 	dev->rebuild_header = strip_rebuild_header;
-	dev->set_mac_address = dev_set_mac_address;
+	dev->set_mac_address = strip_set_mac_address;
 	dev->get_stats = strip_get_stats;
 	dev->change_mtu = strip_change_mtu;
 }

_
