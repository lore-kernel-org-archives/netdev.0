From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ipw2200: use is_zero_ether_addr() and is_broadcast_ether_addr()
Date: Thu, 23 Aug 2012 14:54:05 +0800
Message-ID: <CAPgLHd_K=bbQ=zpKY8kW3HCGeuE3GwCCQOAg+gJoFdCv9SnVrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: stas.yakovlev@gmail.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:43534 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757454Ab2HWGyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:54:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() and is_broadcast_ether_addr() instead of
directly use memcmp() to determine if the ethernet address is all zeros.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/ipw2x00/ipw2200.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 0df4591..935120f 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -9037,18 +9037,11 @@ static int ipw_wx_set_wap(struct net_device *dev,
 {
 	struct ipw_priv *priv = libipw_priv(dev);
 
-	static const unsigned char any[] = {
-		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
-	};
-	static const unsigned char off[] = {
-		0x00, 0x00, 0x00, 0x00, 0x00, 0x00
-	};
-
 	if (wrqu->ap_addr.sa_family != ARPHRD_ETHER)
 		return -EINVAL;
 	mutex_lock(&priv->mutex);
-	if (!memcmp(any, wrqu->ap_addr.sa_data, ETH_ALEN) ||
-	    !memcmp(off, wrqu->ap_addr.sa_data, ETH_ALEN)) {
+	if (is_broadcast_ether_addr(wrqu->ap_addr.sa_data) ||
+	    is_zero_ether_addr(wrqu->ap_addr.sa_data)) {
 		/* we disable mandatory BSSID association */
 		IPW_DEBUG_WX("Setting AP BSSID to ANY\n");
 		priv->config &= ~CFG_STATIC_BSSID;
