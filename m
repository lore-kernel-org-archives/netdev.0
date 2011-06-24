From: John (Jay) Hernandez <jay@chelsio.com>
Subject: [PATCH net-2.6] cxgb3: skb_record_rx_queue now records the queue
	index relative to the net_device.
Date: Thu, 23 Jun 2011 17:39:12 -0700
Message-ID: <20110624003912.14349.62988.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, jay@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16057 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760005Ab1FXBaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 21:30:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John (Jay) Hernandez <jay@chelsio.com>

Fixed call to skb_record_rx_queue where we were passing the queue index
relative to the adapter when it should have been relative to the net_device.

Signed-off-by: John (Jay) Hernandez <jay@chelsio.com>
Signed-off-by: Divy Le Ray <divy@chelsio.com>

---

 drivers/net/cxgb3/sge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 3f562ba..76bf589 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2026,7 +2026,7 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
 		skb_checksum_none_assert(skb);
-	skb_record_rx_queue(skb, qs - &adap->sge.qs[0]);
+	skb_record_rx_queue(skb, qs - &adap->sge.qs[pi->first_qset]);
 
 	if (unlikely(p->vlan_valid)) {
 		struct vlan_group *grp = pi->vlan_grp;
@@ -2145,7 +2145,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	if (!complete)
 		return;
 
-	skb_record_rx_queue(skb, qs - &adap->sge.qs[0]);
+	skb_record_rx_queue(skb, qs - &adap->sge.qs[pi->first_qset]);
 
 	if (unlikely(cpl->vlan_valid)) {
 		struct vlan_group *grp = pi->vlan_grp;

