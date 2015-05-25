From: Shailendra Verma <shailendra.capricorn@gmail.com>
Subject: [PATCH] net:wireless:rndis_wlan - Use bool function return value
Date: Mon, 25 May 2015 23:40:22 +0530
Message-ID: <1432577422-3917-1-git-send-email-shailendra.capricorn@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Shailendra Verma <shailendra.capricorn@gmail.com>
To: Jussi Kivilinna <jussi.kivilinna@iki.fi>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function rndis_bss_info_update() has bool return type.
So use bool value flase instead of NULL to return.

Signed-off-by: Shailendra Verma <shailendra.capricorn@gmail.com>
---
 drivers/net/wireless/rndis_wlan.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d72ff8e..b2bff5c 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2000,7 +2000,7 @@ static bool rndis_bss_info_update(struct usbnet *usbdev,
 
 	if (bssid_len < sizeof(struct ndis_80211_bssid_ex) +
 			sizeof(struct ndis_80211_fixed_ies))
-		return NULL;
+		return false;
 
 	fixed = (struct ndis_80211_fixed_ies *)bssid->ies;
 
@@ -2009,13 +2009,13 @@ static bool rndis_bss_info_update(struct usbnet *usbdev,
 					(int)le32_to_cpu(bssid->ie_length));
 	ie_len -= sizeof(struct ndis_80211_fixed_ies);
 	if (ie_len < 0)
-		return NULL;
+		return false;
 
 	/* extract data for cfg80211_inform_bss */
 	channel = ieee80211_get_channel(priv->wdev.wiphy,
 			KHZ_TO_MHZ(le32_to_cpu(bssid->config.ds_config)));
 	if (!channel)
-		return NULL;
+		return false;
 
 	signal = level_to_qual(le32_to_cpu(bssid->rssi));
 	timestamp = le64_to_cpu(*(__le64 *)fixed->timestamp);
-- 
1.7.9.5
