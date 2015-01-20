From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2 for 3.19 5/7] rtlwifi: rtl8192ee: Fix parsing of received packet
Date: Tue, 20 Jan 2015 11:01:24 -0600
Message-ID: <1421773286-1039-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:57107 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804AbbATRBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 12:01:48 -0500
In-Reply-To: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Tan <troy_tan@realsil.com.cn>

The firmware supplies two kinds of packets via the RX mechanism. Besides the
normal data received over the air, these packets may contain bluetooth status
and other information. The present code fails to detect which kind of
information was received.

Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [V3.18]
---
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c | 4 ++++
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
index 1535680..cb3cbb6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
@@ -354,6 +354,10 @@ bool rtl92ee_rx_query_desc(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr;
 	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
 
+	if (GET_RX_STATUS_DESC_RPT_SEL(pdesc) == 0)
+		status->packet_report_type = NORMAL_RX;
+	else
+		status->packet_report_type = C2H_PACKET;
 	status->length = (u16)GET_RX_DESC_PKT_LEN(pdesc);
 	status->rx_drvinfo_size = (u8)GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
 				  RX_DRV_INFO_SIZE_UNIT;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
index c56f305..8f78ac9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
@@ -542,6 +542,8 @@
 	LE_BITS_TO_4BYTE(__pdesc+8, 12, 4)
 #define GET_RX_DESC_RX_IS_QOS(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+8, 16, 1)
+#define GET_RX_STATUS_DESC_RPT_SEL(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+8, 28, 1)
 
 #define GET_RX_DESC_RXMCS(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+12, 0, 7)
-- 
2.1.2
