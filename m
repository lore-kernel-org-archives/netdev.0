From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 1/7] r8152: add aldps_enable for rtl_ops
Date: Tue, 28 Jun 2016 20:28:36 +0800
Message-ID: <1394712342-15778-199-Taiwan-albertk@realtek.com>
References: <1394712342-15778-184-Taiwan-albertk@realtek.com>
 <1394712342-15778-198-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-198-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add aldps_enable() for rtl_ops.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 11178f9..b253003 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -619,6 +619,7 @@ struct r8152 {
 		int (*eee_get)(struct r8152 *, struct ethtool_eee *);
 		int (*eee_set)(struct r8152 *, struct ethtool_eee *);
 		bool (*in_nway)(struct r8152 *);
+		void (*aldps_enable)(struct r8152 *tp, bool enable);
 		void (*hw_phy_cfg)(struct r8152 *);
 	} rtl_ops;
 
@@ -2474,9 +2475,9 @@ static void r8152_aldps_en(struct r8152 *tp, bool enable)
 
 static void rtl8152_disable(struct r8152 *tp)
 {
-	r8152_aldps_en(tp, false);
+	tp->rtl_ops.aldps_enable(tp, false);
 	rtl_disable(tp);
-	r8152_aldps_en(tp, true);
+	tp->rtl_ops.aldps_enable(tp, true);
 }
 
 static void r8152b_hw_phy_cfg(struct r8152 *tp)
@@ -2801,9 +2802,7 @@ static void r8153_aldps_en(struct r8152 *tp, bool enable)
 
 static void rtl8153_disable(struct r8152 *tp)
 {
-	r8153_aldps_en(tp, false);
-	rtl_disable(tp);
-	r8153_aldps_en(tp, true);
+	rtl8152_disable(tp);
 	usb_enable_lpm(tp->udev);
 }
 
@@ -2924,9 +2923,9 @@ static void rtl8153_up(struct r8152 *tp)
 		return;
 
 	r8153_u1u2en(tp, false);
-	r8153_aldps_en(tp, false);
+	tp->rtl_ops.aldps_enable(tp, false);
 	r8153_first_init(tp);
-	r8153_aldps_en(tp, true);
+	tp->rtl_ops.aldps_enable(tp, true);
 	r8153_u2p3en(tp, true);
 	r8153_u1u2en(tp, true);
 	usb_enable_lpm(tp->udev);
@@ -2942,9 +2941,9 @@ static void rtl8153_down(struct r8152 *tp)
 	r8153_u1u2en(tp, false);
 	r8153_u2p3en(tp, false);
 	r8153_power_cut_en(tp, false);
-	r8153_aldps_en(tp, false);
+	tp->rtl_ops.aldps_enable(tp, false);
 	r8153_enter_oob(tp);
-	r8153_aldps_en(tp, true);
+	tp->rtl_ops.aldps_enable(tp, true);
 }
 
 static bool rtl8152_in_nway(struct r8152 *tp)
@@ -4142,6 +4141,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_get		= r8152_get_eee;
 		ops->eee_set		= r8152_set_eee;
 		ops->in_nway		= rtl8152_in_nway;
+		ops->aldps_enable	= r8152_aldps_en;
 		ops->hw_phy_cfg		= r8152b_hw_phy_cfg;
 		break;
 
@@ -4158,6 +4158,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_get		= r8153_get_eee;
 		ops->eee_set		= r8153_set_eee;
 		ops->in_nway		= rtl8153_in_nway;
+		ops->aldps_enable	= r8153_aldps_en;
 		ops->hw_phy_cfg		= r8153_hw_phy_cfg;
 		break;
 
-- 
2.4.11
