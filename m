From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc4-bk3-netdev3 3/3] r8169: netconsole support
Date: Tue, 19 Oct 2004 01:11:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018231102.GB27418@electric-eye.fr.zoreil.com>
References: <20041018230823.GB19990@electric-eye.fr.zoreil.com> <20041018230948.GA27418@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041018230948.GA27418@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netconsole support.

Signed-off-by: John W. Linville <linville@tuxdriver.com>

diff -puN drivers/net/r8169.c~r8169-235 drivers/net/r8169.c
--- linux-2.6.9/drivers/net/r8169.c~r8169-235	2004-10-18 23:39:38.000000000 +0200
+++ linux-2.6.9-fr/drivers/net/r8169.c	2004-10-18 23:56:27.000000000 +0200
@@ -1088,6 +1088,23 @@ static inline void rtl8169_request_timer
 	add_timer(timer);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void rtl8169_netpoll(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
+
+	disable_irq(pdev->irq);
+	rtl8169_interrupt(pdev->irq, dev, NULL);
+	enable_irq(pdev->irq);
+}
+#endif
+
 static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 				  void *ioaddr)
 {
@@ -1314,6 +1331,10 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->vlan_rx_kill_vid = rtl8169_vlan_rx_kill_vid;
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = rtl8169_netpoll;
+#endif
+
 	tp->intr_mask = 0xffff;
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;

_
