From: Bernd Schubert <bernd.schubert-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH 2/2] Rename 'n' into a longer variable name.
Date: Tue, 16 Aug 2011 12:56:59 +0200
Message-ID: <20110816105659.1805137.44398.stgit@fsdevel3>
References: <20110816105648.1805137.35191.stgit@fsdevel3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110816105648.1805137.35191.stgit@fsdevel3>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When it comes to me variable names consisting of a single letter
should be forbidden by coding style guide lines, as it is rather
difficult to search for single letter, such as 'n'.

Rename struct neighbour *n to dst_neigh


Signed-off-by: Bernd Schubert <bernd.schubert-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index fe89c46..189d4cb 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -717,22 +717,22 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
-	struct neighbour *n = NULL;
+	struct neighbour *dst_neigh = NULL;
 	unsigned long flags;
 
 	if (likely(skb_dst(skb)))
-		n = dst_get_neighbour(skb_dst(skb));
+		dst_neigh = dst_get_neighbour(skb_dst(skb));
 
-	if (likely(n)) {
-		if (unlikely(!*to_ipoib_neigh(n))) {
+	if (likely(dst_neigh)) {
+		if (unlikely(!*to_ipoib_neigh(dst_neigh))) {
 			ipoib_path_lookup(skb, dev);
 			return NETDEV_TX_OK;
 		}
 
-		neigh = *to_ipoib_neigh(n);
+		neigh = *to_ipoib_neigh(dst_neigh);
 
 		if (unlikely((memcmp(&neigh->dgid.raw,
-				     n->ha + 4,
+				     dst_neigh->ha + 4,
 				     sizeof(union ib_gid))) ||
 			     (neigh->dev != dev))) {
 			spin_lock_irqsave(&priv->lock, flags);
@@ -758,7 +758,8 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				return NETDEV_TX_OK;
 			}
 		} else if (neigh->ah) {
-			ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(n->ha));
+			ipoib_send(dev, skb, neigh->ah,
+				   IPOIB_QPN(dst_neigh->ha));
 			return NETDEV_TX_OK;
 		}
 

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
