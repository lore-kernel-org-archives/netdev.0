From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 4/7] r8152: add u2p3_enable for rtl_ops
Date: Tue, 28 Jun 2016 20:28:39 +0800
Message-ID: <1394712342-15778-202-Taiwan-albertk@realtek.com>
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

Add u2p3_enable() for rtl_ops.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a4f8a01..df370e5 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -621,6 +621,7 @@ struct r8152 {
 		bool (*in_nway)(struct r8152 *);
 		void (*aldps_enable)(struct r8152 *tp, bool enable);
 		void (*u1u2_enable)(struct r8152 *tp, bool enable);
+		void (*u2p3_enable)(struct r8152 *tp, bool enable);
 		void (*hw_phy_cfg)(struct r8152 *);
 		void (*power_cut_en)(struct r8152 *tp, bool enable);
 	} rtl_ops;
@@ -2418,7 +2419,7 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 		u32 ocp_data;
 
 		tp->rtl_ops.u1u2_enable(tp, false);
-		r8153_u2p3en(tp, false);
+		tp->rtl_ops.u2p3_enable(tp, false);
 
 		__rtl_set_wol(tp, WAKE_ANY);
 
@@ -2431,7 +2432,7 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 	} else {
 		__rtl_set_wol(tp, tp->saved_wolopts);
-		r8153_u2p3en(tp, true);
+		tp->rtl_ops.u2p3_enable(tp, true);
 		tp->rtl_ops.u1u2_enable(tp, true);
 	}
 }
@@ -2935,7 +2936,7 @@ static void rtl8153_up(struct r8152 *tp)
 	tp->rtl_ops.aldps_enable(tp, false);
 	r8153_first_init(tp);
 	tp->rtl_ops.aldps_enable(tp, true);
-	r8153_u2p3en(tp, true);
+	tp->rtl_ops.u2p3_enable(tp, true);
 	tp->rtl_ops.u1u2_enable(tp, true);
 	usb_enable_lpm(tp->udev);
 }
@@ -2948,7 +2949,7 @@ static void rtl8153_down(struct r8152 *tp)
 	}
 
 	tp->rtl_ops.u1u2_enable(tp, false);
-	r8153_u2p3en(tp, false);
+	tp->rtl_ops.u2p3_enable(tp, false);
 	tp->rtl_ops.power_cut_en(tp, false);
 	tp->rtl_ops.aldps_enable(tp, false);
 	r8153_enter_oob(tp);
@@ -4152,6 +4153,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->in_nway		= rtl8152_in_nway;
 		ops->aldps_enable	= r8152_aldps_en;
 		ops->u1u2_enable	= r8153_u1u2en;
+		ops->u2p3_enable	= r8153_u2p3en;
 		ops->hw_phy_cfg		= r8152b_hw_phy_cfg;
 		ops->power_cut_en	= r8152_power_cut_en;
 		break;
@@ -4171,6 +4173,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->in_nway		= rtl8153_in_nway;
 		ops->aldps_enable	= r8153_aldps_en;
 		ops->u1u2_enable	= r8153_u1u2en;
+		ops->u2p3_enable	= r8153_u2p3en;
 		ops->hw_phy_cfg		= r8153_hw_phy_cfg;
 		ops->power_cut_en	= r8153A_power_cut_en;
 		break;
-- 
2.4.11
