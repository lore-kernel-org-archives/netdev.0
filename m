From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/8] benet: Set skb->csum_level for encapsulated
 checksum
Date: Mon, 25 Aug 2014 17:56:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408251736420.4982@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:59143 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZA4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:56:20 -0400
Received: by mail-vc0-f202.google.com with SMTP id hq11so1666374vcb.1
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 17:56:19 -0700 (PDT)
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
