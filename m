From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [PATCH] poll controller in natsemi
Date: Thu, 12 Aug 2004 01:15:00 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040812011500.19162388@zanzibar.2ka.mipt.ru>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Thu__12_Aug_2004_01_15_00_+0400_tgXlCy2XbyvZAHVz"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Thu__12_Aug_2004_01_15_00_+0400_tgXlCy2XbyvZAHVz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Patch enables poll controller and netconsole for natsemi network
driver.
Patch is against 2.6.8-rc4 kernel.

Tested. Works.

Please apply.

	Evgeniy Polyakov ( s0mbre )

Only failure makes us experts. -- Theo de Raadt

--Multipart=_Thu__12_Aug_2004_01_15_00_+0400_tgXlCy2XbyvZAHVz
Content-Type: text/plain;
 name="natsemi.diff"
Content-Disposition: attachment;
 filename="natsemi.diff"
Content-Transfer-Encoding: 7bit

--- linux-2.6/drivers/net/natsemi.c	2004-08-10 13:35:34.000000000 +0400
+++ linux-2.6/drivers/net/natsemi.c	2004-08-11 23:41:29.000000000 +0400
@@ -765,6 +765,9 @@
 static int netdev_close(struct net_device *dev);
 static int netdev_get_regs(struct net_device *dev, u8 *buf);
 static int netdev_get_eeprom(struct net_device *dev, u8 *buf);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void natsemi_poll_controller(struct net_device *dev);
+#endif
 
 static void move_int_phy(struct net_device *dev, int addr)
 {
@@ -920,6 +923,9 @@
 	dev->do_ioctl = &netdev_ioctl;
 	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = natsemi_poll_controller;
+#endif
 
 	if (mtu)
 		dev->mtu = mtu;
@@ -2188,6 +2194,15 @@
 	return IRQ_RETVAL(handled);
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
 /* This routine is logically part of the interrupt handler, but separated
    for clarity and better register allocation. */
 static void netdev_rx(struct net_device *dev)

--Multipart=_Thu__12_Aug_2004_01_15_00_+0400_tgXlCy2XbyvZAHVz--
