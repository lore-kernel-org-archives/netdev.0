From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix some __vlan_hwaccel_put_tag() callers.
Date: Mon, 22 Apr 2013 19:25:07 -0400 (EDT)
Message-ID: <20130422.192507.622812516214918827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967Ab3DVXZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 19:25:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several call sites were missed when the protocol argument was added to
__vlan_hwaccel_put_tag() in commit
86a9bad3ab6b6f858fd4443b48738cabbb6d094c ("net: vlan: add protocol
argument to packet tagging functions").

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/freescale/gianfar.c  | 2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 5155544..2375a01 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2731,7 +2731,7 @@ static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	 */
 	if (dev->features & NETIF_F_HW_VLAN_CTAG_RX &&
 	    fcb->flags & RXFCB_VLN)
-		__vlan_hwaccel_put_tag(skb, fcb->vlctl);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), fcb->vlctl);
 
 	/* Send the packet up the stack */
 	napi_gro_receive(napi, skb);
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index d1812aa..1901ceb 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -725,7 +725,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 			processed_bytes += skb->len;
 
 			if (cqe->status & EHEA_CQE_VLAN_TAG_XTRACT)
-				__vlan_hwaccel_put_tag(skb, cqe->vlan_tag);
+				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+						       cqe->vlan_tag);
 
 			napi_gro_receive(&pr->napi, skb);
 		} else {
-- 
1.7.11.7
