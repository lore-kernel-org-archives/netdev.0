From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 5/6] r8152: split rtl8152_enable
Date: Thu, 2 Jan 2014 11:22:43 +0800
Message-ID: <1388632963-1341-6-git-send-email-hayeswang@realtek.com>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
 <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split the contents of rtl8152_enable() into rtl_set_eee_plus() and
rtl_enable().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8a7c876..bc5d569 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1447,13 +1447,11 @@ static inline u8 rtl8152_get_speed(struct r8152 *tp)
 	return ocp_read_byte(tp, MCU_TYPE_PLA, PLA_PHYSTATUS);
 }
 
-static int rtl8152_enable(struct r8152 *tp)
+static void rtl_set_eee_plus(struct r8152 *tp)
 {
 	u32 ocp_data;
-	int i, ret;
 	u8 speed;
 
-	set_tx_qlen(tp);
 	speed = rtl8152_get_speed(tp);
 	if (speed & _10bps) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR);
@@ -1464,6 +1462,12 @@ static int rtl8152_enable(struct r8152 *tp)
 		ocp_data &= ~EEEP_CR_EEEP_TX;
 		ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR, ocp_data);
 	}
+}
+
+static int rtl_enable(struct r8152 *tp)
+{
+	u32 ocp_data;
+	int i, ret;
 
 	r8152b_reset_packet_filter(tp);
 
@@ -1485,6 +1489,14 @@ static int rtl8152_enable(struct r8152 *tp)
 	return ret;
 }
 
+static int rtl8152_enable(struct r8152 *tp)
+{
+	set_tx_qlen(tp);
+	rtl_set_eee_plus(tp);
+
+	return rtl_enable(tp);
+}
+
 static void rtl8152_disable(struct r8152 *tp)
 {
 	struct net_device_stats *stats = rtl8152_get_stats(tp->netdev);
-- 
1.8.3.1
