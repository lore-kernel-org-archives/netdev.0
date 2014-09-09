From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: use usleep_range
Date: Tue, 9 Sep 2014 11:40:28 +0800
Message-ID: <1394712342-15778-35-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace mdelay with usleep_range to avoid busy loop.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f95e678..2130c75 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2051,13 +2051,13 @@ static void rtl8152_disable(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if ((ocp_data & FIFO_EMPTY) == FIFO_EMPTY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	for (i = 0; i < 1000; i++) {
 		if (ocp_read_word(tp, MCU_TYPE_PLA, PLA_TCR0) & TCR0_TX_EMPTY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	for (i = 0; i < RTL8152_MAX_RX; i++)
@@ -2202,7 +2202,7 @@ static void rtl_clear_bp(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_2, 0);
 	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_4, 0);
 	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_6, 0);
-	mdelay(3);
+	usleep_range(3000, 6000);
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_BP_BA, 0);
 	ocp_write_word(tp, MCU_TYPE_USB, USB_BP_BA, 0);
 }
@@ -2288,7 +2288,7 @@ static void r8152b_exit_oob(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7);
@@ -2299,7 +2299,7 @@ static void r8152b_exit_oob(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	rtl8152_nic_reset(tp);
@@ -2360,7 +2360,7 @@ static void r8152b_enter_oob(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7);
@@ -2371,7 +2371,7 @@ static void r8152b_enter_oob(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
@@ -2518,7 +2518,7 @@ static void r8153_first_init(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7);
@@ -2529,7 +2529,7 @@ static void r8153_first_init(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
@@ -2573,7 +2573,7 @@ static void r8153_enter_oob(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7);
@@ -2584,7 +2584,7 @@ static void r8153_enter_oob(struct r8152 *tp)
 		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 		if (ocp_data & LINK_LIST_READY)
 			break;
-		mdelay(1);
+		usleep_range(1000, 2000);
 	}
 
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8153_RMS);
-- 
1.9.3
