From: Tim Hansen <devtimhansen@gmail.com>
Subject: Re: [PATCH v2] net/core: Fix BUG to BUG_ON conditionals.
Date: Sun, 8 Oct 2017 16:03:38 -0400
Message-ID: <20171008200338.2noygmfbdri6lc4y@debian>
References: <20171008191720.prewqllyazdstwkp@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: willemb@google.com, edumazet@google.com, soheil@google.com,
        elena.reshetova@intel.com, pabeni@redhat.com, tom@quantonium.net,
        Jason@zx2c4.com, fw@strlen.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexander.levin@one.verizon.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171008191720.prewqllyazdstwkp@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mistakenly sent the patch previously with a missing semicolon.
Apologies.

Fix BUG() calls to use BUG_ON(conditional) macros.

This was found using make coccicheck M=net/core on linux next
tag next-20170929

Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
---
 net/core/skbuff.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d98c2e3ce2bf..34ce4c1a0f3c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1350,8 +1350,7 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 	/* Set the tail pointer and length */
 	skb_put(n, skb->len);
 
-	if (skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len));
 
 	copy_skb_header(n, skb);
 	return n;
@@ -1449,8 +1448,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	BUG_ON(nhead < 0);
 
-	if (skb_shared(skb))
-		BUG();
+	BUG_ON(skb_shared(skb));
 
 	size = SKB_DATA_ALIGN(size);
 
@@ -1595,9 +1593,8 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 		head_copy_off = newheadroom - head_copy_len;
 
 	/* Copy the linear header and data. */
-	if (skb_copy_bits(skb, -head_copy_len, n->head + head_copy_off,
-			  skb->len + head_copy_len))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, -head_copy_len, n->head + head_copy_off,
+			     skb->len + head_copy_len));
 
 	copy_skb_header(n, skb);
 
@@ -1878,8 +1875,8 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 			return NULL;
 	}
 
-	if (skb_copy_bits(skb, skb_headlen(skb), skb_tail_pointer(skb), delta))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, skb_headlen(skb),
+			     skb_tail_pointer(skb), delta));
 
 	/* Optimization: no fragments, no reasons to preestimate
 	 * size of pulled pages. Superb.
-- 
2.14.2
