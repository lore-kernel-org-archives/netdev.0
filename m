From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/6i V3.18] rtlwifi: rtl8192se: Add missing section to read descriptor setting
Date: Wed, 29 Oct 2014 23:17:10 -0500
Message-ID: <1414642633-3700-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:57008 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbaJ3ER1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 00:17:27 -0400
In-Reply-To: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new version of rtlwifi needs code in rtl92se_get_desc() that returns
the buffer address for read operations.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
---
 drivers/net/wireless/rtlwifi/rtl8192se/def.h | 2 ++
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/def.h b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
index 83c9867..6e7a70b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
@@ -446,6 +446,8 @@
 /* DWORD 6 */
 #define SET_RX_STATUS__DESC_BUFF_ADDR(__pdesc, __val)	\
 	SET_BITS_OFFSET_LE(__pdesc + 24, 0, 32, __val)
+#define GET_RX_STATUS_DESC_BUFF_ADDR(__pdesc)			\
+	SHIFT_AND_MASK_LE(__pdesc + 24, 0, 32)
 
 #define SE_RX_HAL_IS_CCK_RATE(_pdesc)\
 	(GET_RX_STATUS_DESC_RX_MCS(_pdesc) == DESC92_RATE1M ||	\
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index b358ebc..672fd3b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -640,6 +640,9 @@ u32 rtl92se_get_desc(u8 *desc, bool istx, u8 desc_name)
 		case HW_DESC_RXPKT_LEN:
 			ret = GET_RX_STATUS_DESC_PKT_LEN(desc);
 			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret = GET_RX_STATUS_DESC_BUFF_ADDR(desc);
+			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
-- 
2.1.1
