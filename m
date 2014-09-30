From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH net-next 10/10] r8169:call "rtl8168_driver_start" "rtl8168_driver_stop" only when dash is enabled
Date: Tue, 30 Sep 2014 23:00:30 +0800
Message-ID: <1412089230-10208-10-git-send-email-hau@realtek.com>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:54614 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaI3PAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:00:51 -0400
In-Reply-To: <1412089230-10208-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two functions are to inform dash firmware driver is been brought up or
brought down. So only call these two functions when dash is enabled.

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b5aab28..583ebca 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7388,9 +7388,10 @@ static void rtl_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
+	     r8168_check_dash(tp)) {
 		rtl8168_driver_stop(tp);
 	}
 
@@ -7823,9 +7824,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   rtl_chip_infos[chipset].jumbo_tx_csum ? "ok" : "ko");
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
+	     r8168_check_dash(tp)) {
 		rtl8168_driver_start(tp);
 	}
 
-- 
1.8.3.2
