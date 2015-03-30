From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 2/9 net-next] net: core: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:10 +0200
Message-ID: <1427749998-28464-2-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/core/rtnetlink.c |  3 +--
 net/core/skbuff.c    | 15 ++++++---------
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b96ac21..ed496d3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1770,8 +1770,7 @@ static int do_setlink(const struct sk_buff *skb,
 		nla_for_each_nested(af, tb[IFLA_AF_SPEC], rem) {
 			const struct rtnl_af_ops *af_ops;
 
-			if (!(af_ops = rtnl_af_lookup(nla_type(af))))
-				BUG();
+			BUG_ON(!(af_ops = rtnl_af_lookup(nla_type(af))));
 
 			err = af_ops->set_link_af(dev, af);
 			if (err < 0)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cdb939b..704ba4d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1056,8 +1056,7 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 	/* Set the tail pointer and length */
 	skb_put(n, skb->len);
 
-	if (skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, -headerlen, n->head, headerlen + skb->len));
 
 	copy_skb_header(n, skb);
 	return n;
@@ -1154,8 +1153,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 
 	BUG_ON(nhead < 0);
 
-	if (skb_shared(skb))
-		BUG();
+	BUG_ON(skb_shared(skb));
 
 	size = SKB_DATA_ALIGN(size);
 
@@ -1289,9 +1287,8 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 		head_copy_off = newheadroom - head_copy_len;
 
 	/* Copy the linear header and data. */
-	if (skb_copy_bits(skb, -head_copy_len, n->head + head_copy_off,
-			  skb->len + head_copy_len))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, -head_copy_len, n->head + head_copy_off,
+			     skb->len + head_copy_len));
 
 	copy_skb_header(n, skb);
 
@@ -1567,8 +1564,8 @@ unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)
 			return NULL;
 	}
 
-	if (skb_copy_bits(skb, skb_headlen(skb), skb_tail_pointer(skb), delta))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, skb_headlen(skb), skb_tail_pointer(skb),
+			     delta));
 
 	/* Optimization: no fragments, no reasons to preestimate
 	 * size of pulled pages. Superb.
-- 
1.9.1
