From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 2/5] qlcnic: vlan gro support
Date: Thu, 16 Sep 2010 22:14:40 -0700
Message-ID: <1284700483-16397-3-git-send-email-amit.salecha@qlogic.com>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:26757 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751124Ab0IQFOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 01:14:44 -0400
In-Reply-To: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO support + vlan rx accleration, boost around 9%
performance and reduces 25% of cpu utilization on vlan
interface.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    2 +-
 drivers/net/qlcnic/qlcnic_main.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 10cebb1..9f994b9 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1455,7 +1455,7 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	if ((vid != 0xffff) && adapter->vlgrp)
-		vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vid);
+		vlan_gro_receive(&sds_ring->napi, adapter->vlgrp, vid, skb);
 	else
 		napi_gro_receive(&sds_ring->napi, skb);
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 9eb0ced..f7eb30b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -796,7 +796,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 	features = (NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
-			NETIF_F_IPV6_CSUM);
+			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
 		features |= (NETIF_F_TSO | NETIF_F_TSO6);
@@ -1456,7 +1456,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
 		NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_HW_VLAN_RX);
 	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM);
+		NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
 		netdev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
-- 
1.6.0.2

