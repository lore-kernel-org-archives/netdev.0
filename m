From: Tom Herbert <therbert@google.com>
Subject: [PATCH 06/17] net: cisco-enic calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:51:35 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252150050.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:36662 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab3KZF5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:57:03 -0500
Received: by mail-ve0-f201.google.com with SMTP id jw12so557459veb.4
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:57:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
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
