From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 1/4] xen-netfront: remove unused variable `extra'
Date: Mon, 18 Mar 2013 10:35:52 +0000
Message-ID: <1363602955-24790-2-git-send-email-wei.liu2@citrix.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50325 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab3CRKgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 06:36:15 -0400
In-Reply-To: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 7ffa43b..5527663 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -537,7 +537,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct netfront_info *np = netdev_priv(dev);
 	struct netfront_stats *stats = this_cpu_ptr(np->stats);
 	struct xen_netif_tx_request *tx;
-	struct xen_netif_extra_info *extra;
 	char *data = skb->data;
 	RING_IDX i;
 	grant_ref_t ref;
@@ -581,7 +580,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx->gref = np->grant_tx_ref[id] = ref;
 	tx->offset = offset;
 	tx->size = len;
-	extra = NULL;
 
 	tx->flags = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
@@ -597,10 +595,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		gso = (struct xen_netif_extra_info *)
 			RING_GET_REQUEST(&np->tx, ++i);
 
-		if (extra)
-			extra->flags |= XEN_NETIF_EXTRA_FLAG_MORE;
-		else
-			tx->flags |= XEN_NETTXF_extra_info;
+		tx->flags |= XEN_NETTXF_extra_info;
 
 		gso->u.gso.size = skb_shinfo(skb)->gso_size;
 		gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
@@ -609,7 +604,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		gso->type = XEN_NETIF_EXTRA_TYPE_GSO;
 		gso->flags = 0;
-		extra = gso;
 	}
 
 	np->tx.req_prod_pvt = i + 1;
-- 
1.7.10.4
