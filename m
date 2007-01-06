From: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
Subject: [PATCH] d80211: Only free WEP crypto ciphers when they have been
 allocated correctly.
Date: Sat, 06 Jan 2007 18:00:52 +0100
Message-ID: <459FD5C4.9070301@kpnplanet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from CPEXFE-VOIP04.KPNplanet.nl ([194.151.105.222]:30303 "EHLO
	cpexfe-voip04.KPNplanet.nl" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751440AbXAFRPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 12:15:50 -0500
To: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The d80211 stack still tries to free the WEP crypto ciphers, even when
allocating them previously has failed. This results in an oops.
Make sure that the d80211 stack only frees the crypto ciphers when they have
been allocated successfully.

Signed-off-by: Gertjan van Wingerde <gwingerde@kpnplanet.nl>

---
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index dee8eae..5abcda6 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -44,8 +44,10 @@ int ieee80211_wep_init(struct ieee80211_local *local)
 
 void ieee80211_wep_free(struct ieee80211_local *local)
 {
-	crypto_free_blkcipher(local->wep_tx_tfm);
-	crypto_free_blkcipher(local->wep_rx_tfm);
+	if (!IS_ERR(local->wep_tx_tfm))
+		crypto_free_blkcipher(local->wep_tx_tfm);
+	if (!IS_ERR(local->wep_rx_tfm))
+		crypto_free_blkcipher(local->wep_rx_tfm);
 }
 
 static inline int ieee80211_wep_weak_iv(u32 iv, int keylen)

