From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 3/9 net-next] af_key: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:11 +0200
Message-ID: <1427749998-28464-3-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/key/af_key.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9255fd9..c77dcc9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -889,8 +889,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		pfkey_sockaddr_fill(&x->props.saddr, 0,
 				    (struct sockaddr *) (addr + 1),
 				    x->props.family);
-	if (!addr->sadb_address_prefixlen)
-		BUG();
+	BUG_ON(!addr->sadb_address_prefixlen);
 
 	/* dst address */
 	addr = (struct sadb_address*) skb_put(skb,
@@ -906,8 +905,7 @@ static struct sk_buff *__pfkey_xfrm_state2msg(const struct xfrm_state *x,
 		pfkey_sockaddr_fill(&x->id.daddr, 0,
 				    (struct sockaddr *) (addr + 1),
 				    x->props.family);
-	if (!addr->sadb_address_prefixlen)
-		BUG();
+	BUG_ON(!addr->sadb_address_prefixlen);
 
 	if (!xfrm_addr_equal(&x->sel.saddr, &x->props.saddr,
 			     x->props.family)) {
@@ -2030,11 +2028,8 @@ static int pfkey_xfrm_policy2msg(struct sk_buff *skb, const struct xfrm_policy *
 	addr->sadb_address_proto = pfkey_proto_from_xfrm(xp->selector.proto);
 	addr->sadb_address_prefixlen = xp->selector.prefixlen_s;
 	addr->sadb_address_reserved = 0;
-	if (!pfkey_sockaddr_fill(&xp->selector.saddr,
-				 xp->selector.sport,
-				 (struct sockaddr *) (addr + 1),
-				 xp->family))
-		BUG();
+	BUG_ON(!pfkey_sockaddr_fill(&xp->selector.saddr, xp->selector.sport,
+				    (struct sockaddr *)(addr + 1), xp->family));
 
 	/* dst address */
 	addr = (struct sadb_address*) skb_put(skb,
@@ -3133,8 +3128,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 		pfkey_sockaddr_fill(&x->props.saddr, 0,
 				    (struct sockaddr *) (addr + 1),
 				    x->props.family);
-	if (!addr->sadb_address_prefixlen)
-		BUG();
+	BUG_ON(!addr->sadb_address_prefixlen);
 
 	/* dst address */
 	addr = (struct sadb_address*) skb_put(skb,
@@ -3149,8 +3143,7 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 		pfkey_sockaddr_fill(&x->id.daddr, 0,
 				    (struct sockaddr *) (addr + 1),
 				    x->props.family);
-	if (!addr->sadb_address_prefixlen)
-		BUG();
+	BUG_ON(!addr->sadb_address_prefixlen);
 
 	pol = (struct sadb_x_policy *)  skb_put(skb, sizeof(struct sadb_x_policy));
 	pol->sadb_x_policy_len = sizeof(struct sadb_x_policy)/sizeof(uint64_t);
@@ -3346,8 +3339,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 		pfkey_sockaddr_fill(&x->props.saddr, 0,
 				    (struct sockaddr *) (addr + 1),
 				    x->props.family);
-	if (!addr->sadb_address_prefixlen)
-		BUG();
+	BUG_ON(!addr->sadb_address_prefixlen);
 
 	/* NAT_T_SPORT (old port) */
 	n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
@@ -3369,8 +3361,7 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 		pfkey_sockaddr_fill(ipaddr, 0,
 				    (struct sockaddr *) (addr + 1),
 				    x->props.family);
-	if (!addr->sadb_address_prefixlen)
-		BUG();
+	BUG_ON(!addr->sadb_address_prefixlen);
 
 	/* NAT_T_DPORT (new port) */
 	n_port = (struct sadb_x_nat_t_port*) skb_put(skb, sizeof (*n_port));
-- 
1.9.1
