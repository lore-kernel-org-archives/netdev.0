From: Somnath Kotur <Somnath.Kotur@emulex.com>
Subject: [PATCH net-next 4/5] be2net: Record receive queue index in skb to aid RPS.
Date: Thu, 26 Apr 2012 19:58:14 +0530
Message-ID: <b91776da-9750-4a4a-ae96-288676637651@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:47286 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757111Ab2DZOhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 10:37:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c9f757c..602ba6c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1259,6 +1259,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo,
 		skb_checksum_none_assert(skb);
 
 	skb->protocol = eth_type_trans(skb, netdev);
+	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
 
@@ -1315,6 +1316,7 @@ void be_rx_compl_process_gro(struct be_rx_obj *rxo, struct napi_struct *napi,
 	skb->len = rxcp->pkt_size;
 	skb->data_len = rxcp->pkt_size;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
 
-- 
1.5.6.1
