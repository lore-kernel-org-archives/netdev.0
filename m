From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH v2 net-next 10/10] r8169:call "rtl8168_driver_start" "rtl8168_driver_stop" only when hardware dash function is enabled
Date: Wed, 1 Oct 2014 23:17:21 +0800
Message-ID: <1412176641-24393-10-git-send-email-hau@realtek.com>
References: <1412176641-24393-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412176641-24393-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two functions are used to inform dash firmware that driver is been
brought up or brought down. So call these two functions only when hardware dash
function is enabled.

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 305f3b4..c03891b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7387,9 +7387,10 @@ static void rtl_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
+	    r8168_check_dash(tp)) {
 		rtl8168_driver_stop(tp);
 	}
 
@@ -7822,9 +7823,10 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   rtl_chip_infos[chipset].jumbo_tx_csum ? "ok" : "ko");
 	}
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
-	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
+	    r8168_check_dash(tp)) {
 		rtl8168_driver_start(tp);
 	}
 
-- 
1.8.3.2
