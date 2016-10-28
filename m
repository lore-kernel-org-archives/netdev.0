From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] mac80211: fix incorrect error return path on tmp allocation failure
Date: Fri, 28 Oct 2016 19:08:24 +0100
Message-ID: <20161028180824.7110-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

The current exit path when tmp fails to be allocated is via the
fail label which frees tfm2 which has not yet been allocated,
which is problematic since tfm2 is not initialized and is a garbage
pointer. Fix this by exiting directly to the return at the end
of the function and hence avoiding the freeing of tfm2.

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 net/mac80211/fils_aead.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/fils_aead.c b/net/mac80211/fils_aead.c
index b81b4f24..c114737 100644
--- a/net/mac80211/fils_aead.c
+++ b/net/mac80211/fils_aead.c
@@ -112,7 +112,7 @@ static int aes_siv_encrypt(const u8 *key, size_t key_len,
 	tmp = kmemdup(plain, plain_len, GFP_KERNEL);
 	if (!tmp) {
 		res = -ENOMEM;
-		goto fail;
+		goto fail_ret;
 	}
 
 	/* IV for CTR before encrypted data */
@@ -150,6 +150,7 @@ static int aes_siv_encrypt(const u8 *key, size_t key_len,
 fail:
 	kfree(tmp);
 	crypto_free_skcipher(tfm2);
+fail_ret:
 	return res;
 }
 
-- 
2.9.3
