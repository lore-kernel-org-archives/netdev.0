From: Tom Herbert <therbert@google.com>
Subject: [PATCH 07/17] net: emulex-benet calls skb_get_rxhash
Date: Mon, 25 Nov 2013 21:51:42 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311252150170.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:52269 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab3KZFvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 00:51:43 -0500
Received: by mail-qa0-f74.google.com with SMTP id i13so1065813qae.5
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 21:51:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_get_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 741d3bf..4678858 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1581,7 +1581,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
 	skb->protocol = eth_type_trans(skb, netdev);
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = rxcp->rss_hash;
+		skb_set_rxhash(skb, rxcp->rss_hash, RXHASH_TYPE_L3);
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
@@ -1639,7 +1639,7 @@ static void be_rx_compl_process_gro(struct be_rx_obj *rxo,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxo - &adapter->rx_obj[0]);
 	if (adapter->netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = rxcp->rss_hash;
+		skb_set_rxhash(skb, rxcp->rss_hash, RXHASH_TYPE_L3);
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
-- 
1.8.4.1
