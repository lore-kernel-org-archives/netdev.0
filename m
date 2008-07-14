From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH] mac80211: return correct error return from ieee80211_wep_init
Date: Mon, 14 Jul 2008 12:52:08 -0700
Message-ID: <487BAE68.6040403@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:58263 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947AbYGNTwV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 15:52:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return the proper error code rather than a hard-coded ENOMEM from
ieee80211_wep_init.  Also, print the error code on failure.

Signed-off-by: Jeremy Fitzhardinge <jeremy@goop.org>
---
 net/mac80211/main.c |    4 ++--
 net/mac80211/wep.c  |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

===================================================================
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1741,8 +1741,8 @@
 	result = ieee80211_wep_init(local);
 
 	if (result < 0) {
-		printk(KERN_DEBUG "%s: Failed to initialize wep\n",
-		       wiphy_name(local->hw.wiphy));
+		printk(KERN_DEBUG "%s: Failed to initialize wep: %d\n",
+		       wiphy_name(local->hw.wiphy), result);
 		goto fail_wep;
 	}
 
===================================================================
--- a/net/mac80211/wep.c
+++ b/net/mac80211/wep.c
@@ -31,13 +31,13 @@
 	local->wep_tx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0,
 						CRYPTO_ALG_ASYNC);
 	if (IS_ERR(local->wep_tx_tfm))
-		return -ENOMEM;
+		return PTR_ERR(local->wep_tx_tfm);
 
 	local->wep_rx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0,
 						CRYPTO_ALG_ASYNC);
 	if (IS_ERR(local->wep_rx_tfm)) {
 		crypto_free_blkcipher(local->wep_tx_tfm);
-		return -ENOMEM;
+		return PTR_ERR(local->wep_rx_tfm);
 	}
 
 	return 0;


