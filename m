From: Tom Herbert <therbert@google.com>
Subject: [PATCH 04/15] net: cisco-enic calls skb_set_hash
Date: Tue, 17 Dec 2013 23:23:42 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172319450.24772@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f73.google.com ([209.85.128.73]:35600 "EHLO
	mail-qe0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab3LRHXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:23:43 -0500
Received: by mail-qe0-f73.google.com with SMTP id 5so735844qeb.0
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:23:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ff78dfa..b740bfc 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1036,11 +1036,12 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, q_number);
 		if (netdev->features & NETIF_F_RXHASH) {
-			skb->rxhash = rss_hash;
-			if (rss_type & (NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX |
-					NIC_CFG_RSS_HASH_TYPE_TCP_IPV6 |
-					NIC_CFG_RSS_HASH_TYPE_TCP_IPV4))
-				skb->l4_rxhash = true;
+			skb_set_hash(skb, rss_hash,
+				     (rss_type &
+				      (NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX |
+				       NIC_CFG_RSS_HASH_TYPE_TCP_IPV6 |
+				       NIC_CFG_RSS_HASH_TYPE_TCP_IPV4)) ?
+				     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 		}
 
 		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
-- 
1.8.5.1
