From: Joe Perches <joe@perches.com>
Subject: [PATCH 22/24] wireless: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:41 -0700
Message-ID: <c451f15431dc866c1345e6d5ec199c373af76166.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wireless/lib80211_crypt_ccmp.c |    2 --
 net/wireless/lib80211_crypt_tkip.c |    4 ----
 net/wireless/lib80211_crypt_wep.c  |    4 ----
 net/wireless/util.c                |    5 ++---
 4 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/net/wireless/lib80211_crypt_ccmp.c b/net/wireless/lib80211_crypt_ccmp.c
index dacb3b4..755738d 100644
--- a/net/wireless/lib80211_crypt_ccmp.c
+++ b/net/wireless/lib80211_crypt_ccmp.c
@@ -77,8 +77,6 @@ static void *lib80211_ccmp_init(int key_idx)
 
 	priv->tfm = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tfm)) {
-		printk(KERN_DEBUG "lib80211_crypt_ccmp: could not allocate "
-		       "crypto API aes\n");
 		priv->tfm = NULL;
 		goto fail;
 	}
diff --git a/net/wireless/lib80211_crypt_tkip.c b/net/wireless/lib80211_crypt_tkip.c
index 7ea4f2b..3873484 100644
--- a/net/wireless/lib80211_crypt_tkip.c
+++ b/net/wireless/lib80211_crypt_tkip.c
@@ -101,7 +101,6 @@ static void *lib80211_tkip_init(int key_idx)
 	priv->tx_tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0,
 						CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm_arc4)) {
-		printk(KERN_DEBUG pr_fmt("could not allocate crypto API arc4\n"));
 		priv->tx_tfm_arc4 = NULL;
 		goto fail;
 	}
@@ -109,7 +108,6 @@ static void *lib80211_tkip_init(int key_idx)
 	priv->tx_tfm_michael = crypto_alloc_hash("michael_mic", 0,
 						 CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm_michael)) {
-		printk(KERN_DEBUG pr_fmt("could not allocate crypto API michael_mic\n"));
 		priv->tx_tfm_michael = NULL;
 		goto fail;
 	}
@@ -117,7 +115,6 @@ static void *lib80211_tkip_init(int key_idx)
 	priv->rx_tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0,
 						CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm_arc4)) {
-		printk(KERN_DEBUG pr_fmt("could not allocate crypto API arc4\n"));
 		priv->rx_tfm_arc4 = NULL;
 		goto fail;
 	}
@@ -125,7 +122,6 @@ static void *lib80211_tkip_init(int key_idx)
 	priv->rx_tfm_michael = crypto_alloc_hash("michael_mic", 0,
 						 CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm_michael)) {
-		printk(KERN_DEBUG pr_fmt("could not allocate crypto API michael_mic\n"));
 		priv->rx_tfm_michael = NULL;
 		goto fail;
 	}
diff --git a/net/wireless/lib80211_crypt_wep.c b/net/wireless/lib80211_crypt_wep.c
index 2f265e0..c130401 100644
--- a/net/wireless/lib80211_crypt_wep.c
+++ b/net/wireless/lib80211_crypt_wep.c
@@ -50,16 +50,12 @@ static void *lib80211_wep_init(int keyidx)
 
 	priv->tx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->tx_tfm)) {
-		printk(KERN_DEBUG "lib80211_crypt_wep: could not allocate "
-		       "crypto API arc4\n");
 		priv->tx_tfm = NULL;
 		goto fail;
 	}
 
 	priv->rx_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(priv->rx_tfm)) {
-		printk(KERN_DEBUG "lib80211_crypt_wep: could not allocate "
-		       "crypto API arc4\n");
 		priv->rx_tfm = NULL;
 		goto fail;
 	}
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 844ddb0..4252765 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -513,10 +513,9 @@ int ieee80211_data_from_8023(struct sk_buff *skb, const u8 *addr,
 		if (head_need)
 			skb_orphan(skb);
 
-		if (pskb_expand_head(skb, head_need, 0, GFP_ATOMIC)) {
-			pr_err("failed to reallocate Tx buffer\n");
+		if (pskb_expand_head(skb, head_need, 0, GFP_ATOMIC))
 			return -ENOMEM;
-		}
+
 		skb->truesize += head_need;
 	}
 
-- 
1.7.6.405.gc1be0
