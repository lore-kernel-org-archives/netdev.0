From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ath5k: fix potential NULL pointer dereference in ath5k_beacon_update()
Date: Mon, 8 Oct 2012 08:42:58 +0800
Message-ID: <CAPgLHd8JOwHeMPu1MfUvse1npL7QMXxgMk4xkjft-JEP_mbv4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	ath5k-devel@lists.ath5k.org, netdev@vger.kernel.org
To: jirislaby@gmail.com, mickflemm@gmail.com, mcgrof@qca.qualcomm.com,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:65437 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab2JHAm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 20:42:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The dereference should be moved below the NULL test.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/ath/ath5k/base.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 9fd6d9a..9f31cfa 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1804,7 +1804,7 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 {
 	int ret;
 	struct ath5k_hw *ah = hw->priv;
-	struct ath5k_vif *avf = (void *)vif->drv_priv;
+	struct ath5k_vif *avf;
 	struct sk_buff *skb;
 
 	if (WARN_ON(!vif)) {
@@ -1819,6 +1819,7 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 		goto out;
 	}
 
+	avf = (void *)vif->drv_priv;
 	ath5k_txbuf_free_skb(ah, avf->bbuf);
 	avf->bbuf->skb = skb;
 	ret = ath5k_beacon_setup(ah, avf->bbuf);
