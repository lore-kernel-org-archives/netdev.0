From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/6i V3.18] rtlwifi: rtl8192ce: Add missing section to read descriptor setting
Date: Wed, 29 Oct 2014 23:17:11 -0500
Message-ID: <1414642633-3700-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:65370 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbaJ3ER2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 00:17:28 -0400
In-Reply-To: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new version of rtlwifi needs code in rtl92ce_get_desc() that returns
the buffer address for read operations.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h | 2 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
index 831df10..9b660df 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
@@ -114,6 +114,8 @@
 	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 16, 4)
 #define	GET_C2H_CMD_FEEDBACK_CCX_SEQ(__pcmdfbhdr)	\
 	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 20, 12)
+#define GET_RX_STATUS_DESC_BUFF_ADDR(__pdesc)			\
+	SHIFT_AND_MASK_LE(__pdesc + 24, 0, 32)
 
 #define CHIP_VER_B			BIT(4)
 #define CHIP_BONDING_IDENTIFIER(_value) (((_value) >> 22) & 0x3)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 2fb9c7a..dc3d20b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -728,6 +728,9 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_name)
 		case HW_DESC_RXPKT_LEN:
 			ret = GET_RX_DESC_PKT_LEN(pdesc);
 			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret = GET_RX_STATUS_DESC_BUFF_ADDR(pdesc);
+			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
-- 
2.1.1
