From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Revert "net: Reset secmark when scrubbing packet"
Date: Thu, 16 Apr 2015 16:12:53 +0800
Message-ID: <20150416081253.GA13595@gondor.apana.org.au>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
 <20150415102229.GA3917@gondor.apana.org.au>
 <20150415135739.GA5534@gondor.apana.org.au>
 <552E86A6.9000101@6wind.com>
 <20150416010326.GA10864@gondor.apana.org.au>
 <alpine.LRH.2.11.1504161700130.23392@namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-security-module@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Flavio Leitner <fbl@sysclose.org>
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.11.1504161700130.23392@namei.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 16, 2015 at 05:02:15PM +1000, James Morris wrote:
> 
> They don't support namespaces, and maintaining the label is critical for 
> SELinux, at least, which mediates security for the system as a whole.

Thanks for the confirmation James, I thought this looked a bit
dodgy :)

---8<---
This patch reverts commit b8fb4e0648a2ab3734140342002f68fb0c7d1602
because the secmark must be preserved even when a packet crosses
namespace boundaries.  The reason is that security labels apply to
the system as a whole and is not per-namespace.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a185427..d1967da 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4130,7 +4130,6 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 	skb->ignore_df = 0;
 	skb_dst_drop(skb);
 	skb_sender_cpu_clear(skb);
-	skb_init_secmark(skb);
 	secpath_reset(skb);
 	nf_reset(skb);
 	nf_reset_trace(skb);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
