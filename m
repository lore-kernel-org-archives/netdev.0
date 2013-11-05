From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3] rtlwifi: rtl8192se: Fix incorrect signal strength for unassociated AP
Date: Tue,  5 Nov 2013 15:15:28 -0600
Message-ID: <1383686130-5113-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1383686130-5113-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35881 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab3KEVPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 16:15:48 -0500
In-Reply-To: <1383686130-5113-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The routine that processes received frames was returning the RSSI value for the
signal strength; however, that value is available only for associated APs. As
a result, the strength was the absurd value of 10 dBm. As a result, scans
return incorrect values for the strength, which causes unwanted attempts to roam.

This patch fixes https://bugzilla.kernel.org/show_bug.cgi?id=63881.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Matthieu Baerts <matttbe@gmail.com>
Cc: Stable <stable@vger.kernel.org> [3.0 +]
---
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 222d2e7..27efbcd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -329,7 +329,7 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
 	}
 
 	/*rx_status->qual = stats->signal; */
-	rx_status->signal = stats->rssi + 10;
+	rx_status->signal = stats->recvsignalpower + 10;
 
 	return true;
 }
-- 
1.8.4
