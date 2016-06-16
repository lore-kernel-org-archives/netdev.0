From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 1/3] r8152: disable MAC clock speed down
Date: Thu, 16 Jun 2016 10:55:17 +0800
Message-ID: <1394712342-15778-180-Taiwan-albertk@realtek.com>
References: <1394712342-15778-179-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-179-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disable MAC clock speed down. It may casue the first control
transfer to contain the wrong data, when the power state change
from U1 to U0.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3f9f6ed..89dc752 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3382,15 +3382,11 @@ static void r8153_init(struct r8152 *tp)
 	r8153_power_cut_en(tp, false);
 	r8153_u1u2en(tp, true);
 
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL, ALDPS_SPDWN_RATIO);
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL2, EEE_SPDWN_RATIO);
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL3,
-		       PKT_AVAIL_SPDWN_EN | SUSPEND_SPDWN_EN |
-		       U1U2_SPDWN_EN | L1_SPDWN_EN);
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL4,
-		       PWRSAVE_SPDWN_EN | RXDV_SPDWN_EN | TX10MIDLE_EN |
-		       TP100_SPDWN_EN | TP500_SPDWN_EN | TP1000_SPDWN_EN |
-		       EEE_SPDWN_EN);
+	/* MAC clock speed down */
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL, 0);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL2, 0);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL3, 0);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL4, 0);
 
 	r8153_enable_eee(tp);
 	r8153_aldps_en(tp, true);
-- 
2.4.11
