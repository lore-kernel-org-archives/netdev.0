From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] r8152: remove rtl_phy_reset function
Date: Thu, 7 Jul 2016 15:09:18 +0800
Message-ID: <1394712342-15778-211-Taiwan-albertk@realtek.com>
References: <1394712342-15778-210-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-210-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In rtl_hw_phy_work_func_t(), the flag of PHY_RESET is set in
rtl_ops.hw_phy_cfg() and cleared in rtl8152_set_speed(). Therefore,
the rtl_phy_reset() is never run and is unnecessary.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b225bc2..e005ee6 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2450,27 +2450,6 @@ static void rtl8153_runtime_enable(struct r8152 *tp, bool enable)
 	}
 }
 
-static void rtl_phy_reset(struct r8152 *tp)
-{
-	u16 data;
-	int i;
-
-	data = r8152_mdio_read(tp, MII_BMCR);
-
-	/* don't reset again before the previous one complete */
-	if (data & BMCR_RESET)
-		return;
-
-	data |= BMCR_RESET;
-	r8152_mdio_write(tp, MII_BMCR, data);
-
-	for (i = 0; i < 50; i++) {
-		msleep(20);
-		if ((r8152_mdio_read(tp, MII_BMCR) & BMCR_RESET) == 0)
-			break;
-	}
-}
-
 static void r8153_teredo_off(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -3069,9 +3048,6 @@ static void rtl_work_func_t(struct work_struct *work)
 	    netif_carrier_ok(tp->netdev))
 		napi_schedule(&tp->napi);
 
-	if (test_and_clear_bit(PHY_RESET, &tp->flags))
-		rtl_phy_reset(tp);
-
 	mutex_unlock(&tp->control);
 
 out1:
-- 
2.7.4
