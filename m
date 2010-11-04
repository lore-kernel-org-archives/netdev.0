From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] mac80211: Remove redundant checks for NULL before calls to
 crypto_free_cipher()
Date: Thu, 4 Nov 2010 22:59:56 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1011042251520.16015@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

crypto_free_cipher() is a wrapper around crypto_free_tfm() which is a 
wrapper around crypto_destroy_tfm() and the latter can handle being passed 
a NULL pointer, so checking for NULL in the 
ieee80211_aes_key_free()/ieee80211_aes_cmac_key_free() wrappers around 
crypto_free_cipher() is pointless and just increase object code size 
needlesly and makes us execute extra test/branch instructions that we 
don't need.
Btw; don't we have to many wrappers around wrappers ad nauseam here?
Anyway, this patch removes the redundant conditionals.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 aes_ccm.c  |    3 +--
 aes_cmac.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index d2b03e0..4bd6ef0 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -147,6 +147,5 @@ struct crypto_cipher *ieee80211_aes_key_setup_encrypt(const u8 key[])
 
 void ieee80211_aes_key_free(struct crypto_cipher *tfm)
 {
-	if (tfm)
-		crypto_free_cipher(tfm);
+	crypto_free_cipher(tfm);
 }
diff --git a/net/mac80211/aes_cmac.c b/net/mac80211/aes_cmac.c
index b4d66cc..d502b26 100644
--- a/net/mac80211/aes_cmac.c
+++ b/net/mac80211/aes_cmac.c
@@ -128,6 +128,5 @@ struct crypto_cipher * ieee80211_aes_cmac_key_setup(const u8 key[])
 
 void ieee80211_aes_cmac_key_free(struct crypto_cipher *tfm)
 {
-	if (tfm)
-		crypto_free_cipher(tfm);
+	crypto_free_cipher(tfm);
 }



-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
