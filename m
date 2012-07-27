From: brenohl@br.ibm.com
Subject: [PATCH] cxgb3: Set vlan_feature on net_device
Date: Fri, 27 Jul 2012 13:22:31 -0500
Message-ID: <1343413351-48710-1-git-send-email-brenohl@br.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <brenohl@br.ibm.com>
To: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:50950 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441Ab2G0SWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 14:22:46 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brenohl@br.ibm.com>;
	Fri, 27 Jul 2012 15:22:43 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 16C433520044
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 14:22:39 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RIJ6O82973880
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 15:19:06 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RIMena005297
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 15:22:41 -0300
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
