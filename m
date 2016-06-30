From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: clear LINK_OFF_WAKE_EN after autoresume
Date: Thu, 30 Jun 2016 15:33:35 +0800
Message-ID: <1394712342-15778-206-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LINK_OFF_WAKE_EN should be cleared after autoresume, otherwise after
system suspend, the system would wake up when linking off occurs.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4e257b8..d7f20a9 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2421,7 +2421,18 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 
 		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 	} else {
+		u32 ocp_data;
+
 		__rtl_set_wol(tp, tp->saved_wolopts);
+
+		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
+
+		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CONFIG34);
+		ocp_data &= ~LINK_OFF_WAKE_EN;
+		ocp_write_word(tp, MCU_TYPE_PLA, PLA_CONFIG34, ocp_data);
+
+		ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
+
 		r8153_u2p3en(tp, true);
 		r8153_u1u2en(tp, true);
 	}
-- 
2.4.11
