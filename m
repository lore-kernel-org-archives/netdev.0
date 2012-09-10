From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] rndis_wlan: move the dereference below the NULL test
Date: Mon, 10 Sep 2012 12:46:46 +0800
Message-ID: <CAPgLHd97uPhcX-dTkur_Ceb=8YOwWQtbRk7MqirNvsYBbDoZ1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: jussi.kivilinna@mbnet.fi, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:62757 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab2IJEqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 00:46:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The dereference should be moved below the NULL test.

spatch with a semantic match is used to found this.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/rndis_wlan.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 7a4ae9e..de2a673 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1946,12 +1946,19 @@ static int rndis_get_tx_power(struct wiphy *wiphy, int *dbm)
 static int rndis_scan(struct wiphy *wiphy,
 			struct cfg80211_scan_request *request)
 {
-	struct net_device *dev = request->wdev->netdev;
-	struct usbnet *usbdev = netdev_priv(dev);
-	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
+	struct net_device *dev;
+	struct usbnet *usbdev;
+	struct rndis_wlan_private *priv;
 	int ret;
 	int delay = SCAN_DELAY_JIFFIES;
 
+	if (!request)
+		return -EINVAL;
+
+	dev = request->wdev->netdev;
+	usbdev = netdev_priv(dev);
+	priv = get_rndis_wlan_priv(usbdev);
+
 	netdev_dbg(usbdev->net, "cfg80211.scan\n");
 
 	/* Get current bssid list from device before new scan, as new scan
@@ -1959,9 +1966,6 @@ static int rndis_scan(struct wiphy *wiphy,
 	 */
 	rndis_check_bssid_list(usbdev, NULL, NULL);
 
-	if (!request)
-		return -EINVAL;
-
 	if (priv->scan_request && priv->scan_request != request)
 		return -EBUSY;
 
