From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 09/11] r8152: check if disabling ALDPS is finished
Date: Fri, 9 Jun 2017 17:11:46 +0800
Message-ID: <1394712342-15778-269-Taiwan-albertk@realtek.com>
References: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use PLA 0xe000 bit 8 to check if disabling ALDPS is finished.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f43b7a8..204f4b2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2836,9 +2836,15 @@ static void r8153_aldps_en(struct r8152 *tp, bool enable)
 		data |= EN_ALDPS;
 		ocp_reg_write(tp, OCP_POWER_CFG, data);
 	} else {
+		int i;
+
 		data &= ~EN_ALDPS;
 		ocp_reg_write(tp, OCP_POWER_CFG, data);
-		msleep(20);
+		for (i = 0; i < 20; i++) {
+			usleep_range(1000, 2000);
+			if (ocp_read_word(tp, MCU_TYPE_PLA, 0xe000) & 0x0100)
+				break;
+		}
 	}
 }
 
-- 
2.7.4
