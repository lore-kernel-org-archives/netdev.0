From: Kalev Lember <kalev@smartlink.ee>
Subject: [PATCH] natsemi netpoll support
Date: Mon, 26 Jul 2004 18:54:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41052937.5010101@smartlink.ee>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030605060906010102010202"
Cc: netdev@oss.sgi.com, manfred@colorfullife.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030605060906010102010202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I have implemented netpoll support in natsemi.c. I am sending you the 
patch, it is against linux-2.6.8-rc2.
It has not recieved a lot of testing, I can only tell that netconsole 
now works for me.

-- 
Best regards,
Kalev Lember

--------------030605060906010102010202
Content-Type: text/x-patch;
 name="natsemi_netconsole.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="natsemi_netconsole.diff"

--- linux-2.6.8-rc2/drivers/net/natsemi.c.orig	2004-07-25 23:37:05.000000000 +0300
+++ linux-2.6.8-rc2/drivers/net/natsemi.c	2004-07-26 00:02:32.000000000 +0300
@@ -750,6 +750,7 @@ static void netdev_error(struct net_devi
 static void netdev_rx(struct net_device *dev);
 static void netdev_tx_done(struct net_device *dev);
 static int natsemi_change_mtu(struct net_device *dev, int new_mtu);
+static void natsemi_poll_controller(struct net_device *dev);
 static void __set_rx_mode(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static void __get_stats(struct net_device *dev);
@@ -920,6 +921,9 @@ static int __devinit natsemi_probe1 (str
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = &natsemi_poll_controller;
+#endif
 
 	if (mtu)
 		dev->mtu = mtu;
@@ -2364,6 +2368,15 @@ static struct net_device_stats *get_stat
 	return &np->stats;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void natsemi_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	intr_handler(dev->irq, dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 #define HASH_TABLE	0x200
 static void __set_rx_mode(struct net_device *dev)
 {

--------------030605060906010102010202--
