From: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mac80211: use constant time comparison with keys
Date: Tue, 17 Oct 2017 20:32:07 +0200
Message-ID: <20171017183207.23124-1-Jason@zx2c4.com>
References: <CAHmME9qd_m-FDj1E+eiBYWKvnMBvr0tWVcJ4ph2tr=Y1d_tb1g@mail.gmail.com>
Cc: "Jason A. Donenfeld" <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHmME9qd_m-FDj1E+eiBYWKvnMBvr0tWVcJ4ph2tr=Y1d_tb1g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Otherwise we risk leaking information via timing side channel.

Fixes: fdf7cb4185b6 ("mac80211: accept key reinstall without changing anything")
Signed-off-by: Jason A. Donenfeld <Jason-OnJsPKxuuEcAvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/key.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index ae995c8480db..035d16fe926e 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -19,6 +19,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 #include <net/mac80211.h>
+#include <crypto/algapi.h>
 #include <asm/unaligned.h>
 #include "ieee80211_i.h"
 #include "driver-ops.h"
@@ -635,7 +636,7 @@ int ieee80211_key_link(struct ieee80211_key *key,
 	 * new version of the key to avoid nonce reuse or replay issues.
 	 */
 	if (old_key && key->conf.keylen == old_key->conf.keylen &&
-	    !memcmp(key->conf.key, old_key->conf.key, key->conf.keylen)) {
+	    !crypto_memneq(key->conf.key, old_key->conf.key, key->conf.keylen)) {
 		ieee80211_key_free_unused(key);
 		ret = 0;
 		goto out;
-- 
2.14.2
