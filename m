From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 03/25] IB/ipoib: Rename qpn to dqpn in ipoib_send and post_send functions
Date: Mon, 13 Mar 2017 20:31:14 +0200
Message-ID: <1489429896-10781-4-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49704 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752742AbdCMScB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:01 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h    | 2 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index b3900b253ad5..d94a7a953338 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -483,7 +483,7 @@ static inline void ipoib_put_ah(struct ipoib_ah *ah)
 int ipoib_add_umcast_attr(struct net_device *dev);
 
 void ipoib_send(struct net_device *dev, struct sk_buff *skb,
-		struct ipoib_ah *address, u32 qpn);
+		struct ipoib_ah *address, u32 dqpn);
 void ipoib_reap_ah(struct work_struct *work);
 
 struct ipoib_path *__path_find(struct net_device *dev, void *gid);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 5d732c5f01ee..dd5fb2964e63 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -514,7 +514,7 @@ void ipoib_send_comp_handler(struct ib_cq *cq, void *dev_ptr)
 
 static inline int post_send(struct ipoib_dev_priv *priv,
 			    unsigned int wr_id,
-			    struct ib_ah *address, u32 qpn,
+			    struct ib_ah *address, u32 dqpn,
 			    struct ipoib_tx_buf *tx_req,
 			    void *head, int hlen)
 {
@@ -524,7 +524,7 @@ static inline int post_send(struct ipoib_dev_priv *priv,
 	ipoib_build_sge(priv, tx_req);
 
 	priv->tx_wr.wr.wr_id	= wr_id;
-	priv->tx_wr.remote_qpn	= qpn;
+	priv->tx_wr.remote_qpn	= dqpn;
 	priv->tx_wr.ah		= address;
 
 	if (head) {
@@ -539,7 +539,7 @@ static inline int post_send(struct ipoib_dev_priv *priv,
 }
 
 void ipoib_send(struct net_device *dev, struct sk_buff *skb,
-		struct ipoib_ah *address, u32 qpn)
+		struct ipoib_ah *address, u32 dqpn)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_tx_buf *tx_req;
@@ -621,7 +621,7 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 	skb_dst_drop(skb);
 
 	rc = post_send(priv, priv->tx_head & (ipoib_sendq_size - 1),
-		       address->ah, qpn, tx_req, phead, hlen);
+		       address->ah, dqpn, tx_req, phead, hlen);
 	if (unlikely(rc)) {
 		ipoib_warn(priv, "post_send failed, error %d\n", rc);
 		++dev->stats.tx_errors;
-- 
1.8.3.1
