From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: fix memory leak on regd when chan is zero
Date: Thu, 15 Sep 2016 17:21:17 +0100
Message-ID: <20160915162117.1209-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47516 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754253AbcIOQXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 12:23:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

When chan is zero mwifiex_create_custom_regdomain does not kfree
regd and we have a memory leak. Fix this by freeing regd before
the return.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
index 3344a26..15a91f3 100644
--- a/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c
@@ -1049,8 +1049,10 @@ mwifiex_create_custom_regdomain(struct mwifiex_private *priv,
 		enum nl80211_band band;
 
 		chan = *buf++;
-		if (!chan)
+		if (!chan) {
+			kfree(regd);
 			return NULL;
+		}
 		chflags = *buf++;
 		band = (chan <= 14) ? NL80211_BAND_2GHZ : NL80211_BAND_5GHZ;
 		freq = ieee80211_channel_to_frequency(chan, band);
-- 
2.9.3
