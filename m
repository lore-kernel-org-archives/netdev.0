From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/8] r8169: move net_device_ops beyond the methods it references.
Date: Sat, 10 Mar 2012 23:19:28 +0100
Message-ID: <20120310221928.GD9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41085 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752673Ab2CJWUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:20:45 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   49 ++++++++++++++--------------------
 1 files changed, 20 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3455d37..5ce9f64 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -774,19 +774,10 @@ MODULE_FIRMWARE(FIRMWARE_8105E_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
 
-static int rtl8169_open(struct net_device *dev);
-static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
-				      struct net_device *dev);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
 static int rtl8169_init_ring(struct net_device *dev);
 static void rtl_hw_start(struct net_device *dev);
-static int rtl8169_close(struct net_device *dev);
 static void rtl_set_rx_mode(struct net_device *dev);
-static void rtl8169_tx_timeout(struct net_device *dev);
-static struct rtnl_link_stats64 *rtl8169_get_stats64(struct net_device *dev,
-						    struct rtnl_link_stats64
-						    *stats);
-static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
 
@@ -3528,25 +3519,6 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 	}
 }
 
-static const struct net_device_ops rtl8169_netdev_ops = {
-	.ndo_open		= rtl8169_open,
-	.ndo_stop		= rtl8169_close,
-	.ndo_get_stats64	= rtl8169_get_stats64,
-	.ndo_start_xmit		= rtl8169_start_xmit,
-	.ndo_tx_timeout		= rtl8169_tx_timeout,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= rtl8169_change_mtu,
-	.ndo_fix_features	= rtl8169_fix_features,
-	.ndo_set_features	= rtl8169_set_features,
-	.ndo_set_mac_address	= rtl_set_mac_address,
-	.ndo_do_ioctl		= rtl8169_ioctl,
-	.ndo_set_rx_mode	= rtl_set_rx_mode,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= rtl8169_netpoll,
-#endif
-
-};
-
 static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
 {
 	struct mdio_ops *ops = &tp->mdio_ops;
@@ -6071,6 +6043,25 @@ static void __devexit rtl_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
+static const struct net_device_ops rtl_netdev_ops = {
+	.ndo_open		= rtl8169_open,
+	.ndo_stop		= rtl8169_close,
+	.ndo_get_stats64	= rtl8169_get_stats64,
+	.ndo_start_xmit		= rtl8169_start_xmit,
+	.ndo_tx_timeout		= rtl8169_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= rtl8169_change_mtu,
+	.ndo_fix_features	= rtl8169_fix_features,
+	.ndo_set_features	= rtl8169_set_features,
+	.ndo_set_mac_address	= rtl_set_mac_address,
+	.ndo_do_ioctl		= rtl8169_ioctl,
+	.ndo_set_rx_mode	= rtl_set_rx_mode,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= rtl8169_netpoll,
+#endif
+
+};
+
 static int __devinit
 rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -6095,7 +6086,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	dev->netdev_ops = &rtl8169_netdev_ops;
+	dev->netdev_ops = &rtl_netdev_ops;
 	tp = netdev_priv(dev);
 	tp->dev = dev;
 	tp->pci_dev = pdev;
-- 
1.7.7.6
