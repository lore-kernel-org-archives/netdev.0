From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 6/8] r8169: move the netpoll handler after the irq handler.
Date: Sat, 10 Mar 2012 23:20:23 +0100
Message-ID: <20120310222023.GG9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41103 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752673Ab2CJWVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:21:35 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8d4515e..12329c5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -774,8 +774,6 @@ MODULE_FIRMWARE(FIRMWARE_8105E_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
 
-static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
-
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
 	mutex_lock(&tp->wk.mutex);
@@ -3289,15 +3287,6 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	rtl_schedule_task(tp, RTL_FLAG_TASK_PHY_PENDING);
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void rtl8169_netpoll(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	rtl8169_interrupt(tp->pci_dev->irq, dev);
-}
-#endif
-
 static void rtl8169_release_board(struct pci_dev *pdev, struct net_device *dev,
 				  void __iomem *ioaddr)
 {
@@ -5720,6 +5709,15 @@ static int rtl8169_close(struct net_device *dev)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void rtl8169_netpoll(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	rtl8169_interrupt(tp->pci_dev->irq, dev);
+}
+#endif
+
 static int rtl_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-- 
1.7.7.6
