From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/8 V2] rtlwifi: rtl8192cu: Fix smatch warning in rtl8192cu/trx.c
Date: Mon, 16 Sep 2013 13:55:17 -0500
Message-ID: <1379357722-17687-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:52400 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab3IPSzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 14:55:47 -0400
In-Reply-To: <1379357722-17687-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
drivers/net/wireless/rtlwifi/rtl8192cu/trx.c:367 _rtl_rx_process() warn: assigning (-98) to unsigned variable 'stats.noise'

This variable is unused, thus it is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 763cf1d..04c7e57 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -349,7 +349,6 @@ bool rtl92cu_rx_query_desc(struct ieee80211_hw *hw,
 	}
 	/*rx_status->qual = stats->signal; */
 	rx_status->signal = stats->rssi + 10;
-	/*rx_status->noise = -stats->noise; */
 	return true;
 }
 
@@ -364,7 +363,6 @@ static void _rtl_rx_process(struct ieee80211_hw *hw, struct sk_buff *skb)
 	u8 *rxdesc;
 	struct rtl_stats stats = {
 		.signal = 0,
-		.noise = -98,
 		.rate = 0,
 	};
 	struct rx_fwinfo_92c *p_drvinfo;
-- 
1.8.1.4
