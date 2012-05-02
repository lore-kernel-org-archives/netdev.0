From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 3/5] be2net: Record receive queue index in skb to aid RPS.
Date: Wed, 2 May 2012 19:10:49 +0530
Message-ID: <d1bf7d36-9c55-407f-8087-6d1af05b5011@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>,
	Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:19202 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752939Ab2EBNmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 09:42:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sarveshwar Bandi <Sarveshwar.Bandi@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c8f7b3a..b7bc905 100644
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
