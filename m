From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] benet: remove bogus "unlikely" on vlan check
Date: Thu, 25 Aug 2011 14:50:51 +0200
Message-ID: <1314276651-9138-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951Ab1HYMu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 08:50:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of unlikely in this place is wrong. Remove it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fb2eda0..3d55b47 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1139,7 +1139,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 		skb->rxhash = rxcp->rss_hash;
 
 
-	if (unlikely(rxcp->vlanf))
+	if (rxcp->vlanf)
 		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
 
 	netif_receive_skb(skb);
@@ -1196,7 +1196,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 	if (adapter->netdev->features & NETIF_F_RXHASH)
 		skb->rxhash = rxcp->rss_hash;
 
-	if (unlikely(rxcp->vlanf))
+	if (rxcp->vlanf)
 		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
 
 	napi_gro_frags(&eq_obj->napi);
-- 
1.7.6
