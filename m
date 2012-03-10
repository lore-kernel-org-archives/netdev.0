From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/8] r8169: move the driver removal method to the end of the driver file.
Date: Sat, 10 Mar 2012 23:18:18 +0100
Message-ID: <20120310221818.GB9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41073 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752673Ab2CJWTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:19:30 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   58 +++++++++++++++++-----------------
 1 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c04df3d..ef6ef60 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4263,34 +4263,6 @@ err_out_free_dev_1:
 	goto out;
 }
 
-static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct rtl8169_private *tp = netdev_priv(dev);
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
-		rtl8168_driver_stop(tp);
-	}
-
-	cancel_work_sync(&tp->wk.work);
-
-	unregister_netdev(dev);
-
-	rtl_release_firmware(tp);
-
-	if (pci_dev_run_wake(pdev))
-		pm_runtime_get_noresume(&pdev->dev);
-
-	/* restore original MAC address */
-	rtl_rar_set(tp, dev->perm_addr);
-
-	rtl_disable_msi(pdev, tp);
-	rtl8169_release_board(pdev, dev, tp->mmio_addr);
-	pci_set_drvdata(pdev, NULL);
-}
-
 static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
 {
 	struct rtl_fw *rtl_fw;
@@ -6316,11 +6288,39 @@ static void rtl_shutdown(struct pci_dev *pdev)
 	pm_runtime_put_noidle(d);
 }
 
+static void __devexit rtl_remove_one(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+		rtl8168_driver_stop(tp);
+	}
+
+	cancel_work_sync(&tp->wk.work);
+
+	unregister_netdev(dev);
+
+	rtl_release_firmware(tp);
+
+	if (pci_dev_run_wake(pdev))
+		pm_runtime_get_noresume(&pdev->dev);
+
+	/* restore original MAC address */
+	rtl_rar_set(tp, dev->perm_addr);
+
+	rtl_disable_msi(pdev, tp);
+	rtl8169_release_board(pdev, dev, tp->mmio_addr);
+	pci_set_drvdata(pdev, NULL);
+}
+
 static struct pci_driver rtl8169_pci_driver = {
 	.name		= MODULENAME,
 	.id_table	= rtl8169_pci_tbl,
 	.probe		= rtl8169_init_one,
-	.remove		= __devexit_p(rtl8169_remove_one),
+	.remove		= __devexit_p(rtl_remove_one),
 	.shutdown	= rtl_shutdown,
 	.driver.pm	= RTL8169_PM_OPS,
 };
-- 
1.7.7.6
