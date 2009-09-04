From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 04/11] enic: use netdev_alloc_skb
Date: Thu, 03 Sep 2009 20:02:08 -0700
Message-ID: <20090904030208.5047.72911.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:32043 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932905AbZIDDLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:11:35 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: use netdev_alloc_skb

Use netdev_alloc_skb rather than dev_alloc_skb

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a9e9be1..d77119a 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -868,11 +868,12 @@ static void enic_free_rq_buf(struct vnic_rq *rq, struct vnic_rq_buf *buf)
 	dev_kfree_skb_any(buf->os_buf);
 }
 
-static inline struct sk_buff *enic_rq_alloc_skb(unsigned int size)
+static inline struct sk_buff *enic_rq_alloc_skb(struct net_device *netdev,
+	unsigned int size)
 {
 	struct sk_buff *skb;
 
-	skb = dev_alloc_skb(size + NET_IP_ALIGN);
+	skb = netdev_alloc_skb(netdev, size + NET_IP_ALIGN);
 
 	if (skb)
 		skb_reserve(skb, NET_IP_ALIGN);
@@ -883,12 +884,13 @@ static inline struct sk_buff *enic_rq_alloc_skb(unsigned int size)
 static int enic_rq_alloc_buf(struct vnic_rq *rq)
 {
 	struct enic *enic = vnic_dev_priv(rq->vdev);
+	struct net_device *netdev = enic->netdev;
 	struct sk_buff *skb;
-	unsigned int len = enic->netdev->mtu + ETH_HLEN;
+	unsigned int len = netdev->mtu + ETH_HLEN;
 	unsigned int os_buf_index = 0;
 	dma_addr_t dma_addr;
 
-	skb = enic_rq_alloc_skb(len);
+	skb = enic_rq_alloc_skb(netdev, len);
 	if (!skb)
 		return -ENOMEM;
 

