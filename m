From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 2/6] net/ipv6: use constant time memory comparison for mac
Date: Sat, 10 Jun 2017 04:59:08 +0200
Message-ID: <20170610025912.6499-3-Jason@zx2c4.com>
References: <20170610025912.6499-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org,
	stable@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-8503-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170610025912.6499-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Otherwise, we enable a MAC forgery via timing attack.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: stable@vger.kernel.org
---
 net/ipv6/seg6_hmac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index f950cb53d5e3..54213c83b44e 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -38,6 +38,7 @@
 #include <net/xfrm.h>
 
 #include <linux/cryptohash.h>
+#include <crypto/algapi.h>
 #include <crypto/hash.h>
 #include <crypto/sha.h>
 #include <net/seg6.h>
@@ -274,7 +275,7 @@ bool seg6_hmac_validate_skb(struct sk_buff *skb)
 	if (seg6_hmac_compute(hinfo, srh, &ipv6_hdr(skb)->saddr, hmac_output))
 		return false;
 
-	if (memcmp(hmac_output, tlv->hmac, SEG6_HMAC_FIELD_LEN) != 0)
+	if (crypto_memneq(hmac_output, tlv->hmac, SEG6_HMAC_FIELD_LEN))
 		return false;
 
 	return true;
-- 
2.13.1
