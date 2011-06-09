From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 1/4] enic: Pass 802.1p bits for packets tagged
	with vlan zero
Date: Thu, 09 Jun 2011 13:36:52 -0700
Message-ID: <20110609203651.31838.26971.stgit@savbu-pc100.cisco.com>
References: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:56778 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609Ab1FIUgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:36:53 -0400
In-Reply-To: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

enic driver currently passes 802.1p bits to the upper layers for packets
tagged with non-zero vlan ids only. This patch extends such behaviour to
zero vlan tagged packets also.

The patch is dependant on the following kernel patches:

1) vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p packet)
   - net-next-2.6 git commit: ad1afb00393915a51c21b1ae8704562bf036855f
   - Available 2.6.36 and later
2) vlan: Centralize handling of hardware acceleration.
  - net-next-2.6 git commit: 3701e51382a026cba10c60b03efabe534fba4ca4
  - Available 2.6.37 and later

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)


diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 9600f43..e990988 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1266,8 +1266,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		skb->dev = netdev;
 
-		if (enic->vlan_group && vlan_stripped &&
-			(vlan_tci & CQ_ENET_RQ_DESC_VLAN_TCI_VLAN_MASK)) {
+		if (vlan_stripped) {
 
 			if (netdev->features & NETIF_F_GRO)
 				vlan_gro_receive(&enic->napi[q_number],

