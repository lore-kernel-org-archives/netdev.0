From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 5/9] benet: Set skb->csum_level for encapsulated
 checksum
Date: Wed, 27 Aug 2014 21:27:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272109510.32270@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:40151 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933663AbaH1Efh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 00:35:37 -0400
Received: by mail-oa0-f73.google.com with SMTP id g18so214251oah.2
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 21:35:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set skb->csum_level instead of skb->encapsulation when indicating
CHECKSUM_UNNECESSARY for an encapsulated checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 93ff8ef..f69fa99 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1683,7 +1683,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
 	if (netdev->features & NETIF_F_RXHASH)
 		skb_set_hash(skb, rxcp->rss_hash, PKT_HASH_TYPE_L3);
 
-	skb->encapsulation = rxcp->tunneled;
+	skb->csum_level = rxcp->tunneled;
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
@@ -1741,7 +1741,7 @@ static void be_rx_compl_process_gro(struct be_rx_obj *rxo,
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb_set_hash(skb, rxcp->rss_hash, PKT_HASH_TYPE_L3);
 
-	skb->encapsulation = rxcp->tunneled;
+	skb->csum_level = rxcp->tunneled;
 	skb_mark_napi_id(skb, napi);
 
 	if (rxcp->vlanf)
-- 
2.1.0.rc2.206.gedb03e5
