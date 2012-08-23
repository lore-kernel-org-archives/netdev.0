From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ipw2100: use is_zero_ether_addr() and is_broadcast_ether_addr()
Date: Thu, 23 Aug 2012 14:53:24 +0800
Message-ID: <CAPgLHd_zKkfbms8pMPiTKtGxWXw9=b0+AftqFxWZCPLb3EBaig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: stas.yakovlev@gmail.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:53376 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab2HWGxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:53:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() and is_broadcast_ether_addr() instead of
directly use memcmp() to determine if the ethernet address is all zeros.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/ipw2x00/ipw2100.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 95aa8e1..c3e14b2 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6963,13 +6963,6 @@ static int ipw2100_wx_set_wap(struct net_device *dev,
 	struct ipw2100_priv *priv = libipw_priv(dev);
 	int err = 0;
 
-	static const unsigned char any[] = {
-		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
-	};
-	static const unsigned char off[] = {
-		0x00, 0x00, 0x00, 0x00, 0x00, 0x00
-	};
-
 	// sanity checks
 	if (wrqu->ap_addr.sa_family != ARPHRD_ETHER)
 		return -EINVAL;
@@ -6980,8 +6973,8 @@ static int ipw2100_wx_set_wap(struct net_device *dev,
 		goto done;
 	}
 
-	if (!memcmp(any, wrqu->ap_addr.sa_data, ETH_ALEN) ||
-	    !memcmp(off, wrqu->ap_addr.sa_data, ETH_ALEN)) {
+	if (is_broadcast_ether_addr(wrqu->ap_addr.sa_data) ||
+	    is_zero_ether_addr(wrqu->ap_addr.sa_data)) {
 		/* we disable mandatory BSSID association */
 		IPW_DEBUG_WX("exit - disable mandatory BSSID\n");
 		priv->config &= ~CFG_STATIC_BSSID;
