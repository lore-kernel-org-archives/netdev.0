From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] DECnet: Use container_of() for embedded struct
Date: Mon, 8 May 2017 15:31:44 -0700
Message-ID: <20170508223144.GA53216@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of a direct cross-type cast, use conatiner_of() to locate
the embedded structure, even in the face of future struct layout
randomization.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/decnet/dn_neigh.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 482730cd8a56..eeb5fc561f80 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -110,7 +110,7 @@ struct neigh_table dn_neigh_table = {
 static int dn_neigh_construct(struct neighbour *neigh)
 {
 	struct net_device *dev = neigh->dev;
-	struct dn_neigh *dn = (struct dn_neigh *)neigh;
+	struct dn_neigh *dn = container_of(neigh, struct dn_neigh, n);
 	struct dn_dev *dn_db;
 	struct neigh_parms *parms;
 
@@ -339,7 +339,7 @@ int dn_to_neigh_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *) dst;
 	struct neighbour *neigh = rt->n;
-	struct dn_neigh *dn = (struct dn_neigh *)neigh;
+	struct dn_neigh *dn = container_of(neigh, struct dn_neigh, n);
 	struct dn_dev *dn_db;
 	bool use_long;
 
@@ -391,7 +391,7 @@ int dn_neigh_router_hello(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	neigh = __neigh_lookup(&dn_neigh_table, &src, skb->dev, 1);
 
-	dn = (struct dn_neigh *)neigh;
+	dn = container_of(neigh, struct dn_neigh, n);
 
 	if (neigh) {
 		write_lock(&neigh->lock);
@@ -451,7 +451,7 @@ int dn_neigh_endnode_hello(struct net *net, struct sock *sk, struct sk_buff *skb
 
 	neigh = __neigh_lookup(&dn_neigh_table, &src, skb->dev, 1);
 
-	dn = (struct dn_neigh *)neigh;
+	dn = container_of(neigh, struct dn_neigh, n);
 
 	if (neigh) {
 		write_lock(&neigh->lock);
@@ -510,7 +510,7 @@ static void neigh_elist_cb(struct neighbour *neigh, void *_info)
 	if (neigh->dev != s->dev)
 		return;
 
-	dn = (struct dn_neigh *) neigh;
+	dn = container_of(neigh, struct dn_neigh, n);
 	if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
 		return;
 
@@ -549,7 +549,7 @@ int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
 static inline void dn_neigh_format_entry(struct seq_file *seq,
 					 struct neighbour *n)
 {
-	struct dn_neigh *dn = (struct dn_neigh *) n;
+	struct dn_neigh *dn = container_of(n, struct dn_neigh, n);
 	char buf[DN_ASCBUF_LEN];
 
 	read_lock(&n->lock);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
