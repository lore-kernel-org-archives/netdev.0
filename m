From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 6/7] net: wireless: wcn36xx: remove powersaving for wcn3620
Date: Sun, 18 Jan 2015 13:11:11 +0800
Message-ID: <20150118051111.31866.39208.stgit@114-36-241-182.dynamic.hinet.net>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35506 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbARFLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:11:18 -0500
In-Reply-To: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WCN3620 powersaving mode is not stable.  Disable it if we're
on a wcn3620 chip type.

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index c4178c7..569d45b 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -924,6 +924,10 @@ static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
 		IEEE80211_HW_AMPDU_AGGREGATION |
 		IEEE80211_HW_TIMING_BEACON_ONLY;
 
+	/* 3620 powersaving currently unstable */
+	if (wcn->chip_version == WCN36XX_CHIP_3620)
+		wcn->hw->flags &= ~IEEE80211_HW_SUPPORTS_PS;
+
 	wcn->hw->wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION) |
 		BIT(NL80211_IFTYPE_AP) |
 		BIT(NL80211_IFTYPE_ADHOC) |
