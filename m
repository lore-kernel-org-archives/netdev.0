From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 06/17] net: cisco-enic calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:27:34 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260923000.21138@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:43759 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab3KZRfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:35:31 -0500
Received: by mail-oa0-f74.google.com with SMTP id o6so1256991oag.5
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:35:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ff78dfa..ea30551 100644
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
+			skb_set_rxhash(skb, rss_hash,
+			    (rss_type & (NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX |
+					 NIC_CFG_RSS_HASH_TYPE_TCP_IPV6 |
+					 NIC_CFG_RSS_HASH_TYPE_TCP_IPV4)) ?
+			     RXHASH_TYPE_L4 : RXHASH_TYPE_L3);
+
 		}
 
 		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
-- 
1.8.4.1
