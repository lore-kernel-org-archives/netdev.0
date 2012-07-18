From: brenohl@br.ibm.com
Subject: [PATCH] cxgb3: Set vlan_feature on net_device
Date: Wed, 18 Jul 2012 14:29:08 -0500
Message-ID: <1342639748-16276-1-git-send-email-brenohl@br.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <brenohl@br.ibm.com>
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:32796 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab2GRT3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:29:17 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brenohl@br.ibm.com>;
	Wed, 18 Jul 2012 16:29:15 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 0A17C352004C
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 15:29:11 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6IJSQrM38993978
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 16:28:26 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6IHT1u1029178
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:29:01 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cxgb3 interface has a bad performance when VLAN is set. On my current
setup, a PowerLinux 7R2, I am able to get around 7 Gbps on a TCP_STREAM
(8 instances, 4k message).
With this patch, I am able to reach 9.5 Gbps.

Signed-off-by: Breno Leitao <brenohl@br.ibm.com>

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index abb6ce7..fcf4b31 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3173,6 +3173,9 @@ static void __devinit cxgb3_init_iscsi_mac(struct net_device *dev)
 	pi->iscsic.mac_addr[3] |= 0x80;
 }
 
+#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
+#define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
+			NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
 static int __devinit init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
@@ -3293,6 +3296,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_TSO | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX;
 		netdev->features |= netdev->hw_features | NETIF_F_HW_VLAN_TX;
+		netdev->vlan_features |= netdev->features & VLAN_FEAT;
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
 
-- 
1.7.1
