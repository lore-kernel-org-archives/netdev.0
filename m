From: Kalev Lember <kalev@smartlink.ee>
Subject: Re: [PATCH] natsemi netpoll support
Date: Tue, 27 Jul 2004 21:22:40 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41069D70.9030207@smartlink.ee>
References: <41052937.5010101@smartlink.ee> <410697F8.2050205@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030800070407040709060509"
Cc: netdev@oss.sgi.com, manfred@colorfullife.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <410697F8.2050205@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030800070407040709060509
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:

> please also #ifdef the prototype

Sorry. Attached updated patch.

-- 
Kalev Lember

--------------030800070407040709060509
Content-Type: text/x-patch;
 name="natsemi_netconsole.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="natsemi_netconsole.diff"

--- linux-2.6.8-rc2/drivers/net/natsemi.c.orig	2004-07-25 23:37:05.000000000 +0300
+++ linux-2.6.8-rc2/drivers/net/natsemi.c	2004-07-27 21:18:52.676300394 +0300
@@ -750,6 +750,9 @@ static void netdev_error(struct net_devi
 static void netdev_rx(struct net_device *dev);
 static void netdev_tx_done(struct net_device *dev);
 static int natsemi_change_mtu(struct net_device *dev, int new_mtu);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void natsemi_poll_controller(struct net_device *dev);
+#endif
 static void __set_rx_mode(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static void __get_stats(struct net_device *dev);
@@ -920,6 +923,9 @@ static int __devinit natsemi_probe1 (str
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = &natsemi_poll_controller;
+#endif
 
 	if (mtu)
 		dev->mtu = mtu;
@@ -2364,6 +2370,15 @@ static struct net_device_stats *get_stat
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

--------------030800070407040709060509--
