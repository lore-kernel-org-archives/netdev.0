From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/8 V4] rtlwifi: rtl8192cu: Fix smatch warning in rtl8192cu/trx.c
Date: Wed, 25 Sep 2013 12:57:44 -0500
Message-ID: <1380131869-19185-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1380131869-19185-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:61086 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927Ab3IYR6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 13:58:10 -0400
In-Reply-To: <1380131869-19185-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
drivers/net/wireless/rtlwifi/rtl8192cu/trx.c:367 _rtl_rx_process() warn: assigning (-98) to unsigned variable 'stats.noise'

This variable is unused, thus the initializer is removed, as well as a
comment referring to that variable.

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
