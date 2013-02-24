From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] rndis_wlan: Remove redundant NULL check before kfree
Date: Mon, 25 Feb 2013 03:35:43 +0530
Message-ID: <1361743543-27912-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com
To: jussi.kivilinna@mbnet.fi, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:36409 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab3BXWF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 17:05:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on a NULL pointer is a no-op.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/net/wireless/rndis_wlan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 525fd75..5f66b4e 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2839,8 +2839,7 @@ static void rndis_wlan_do_link_up_work(struct usbnet *usbdev)
 	} else if (priv->infra_mode == NDIS_80211_INFRA_ADHOC)
 		cfg80211_ibss_joined(usbdev->net, bssid, GFP_KERNEL);
 
-	if (info != NULL)
-		kfree(info);
+	kfree(info);
 
 	priv->connected = true;
 	memcpy(priv->bssid, bssid, ETH_ALEN);
-- 
1.7.9.5
