From: brenohl@br.ibm.com
Subject: [PATCH] qlge: Add offload features to vlan interfaces
Date: Fri, 27 Jul 2012 13:54:52 -0500
Message-ID: <1343415292-49323-1-git-send-email-brenohl@br.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <brenohl@br.ibm.com>
To: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:44729 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab2G0SzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 14:55:10 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brenohl@br.ibm.com>;
	Fri, 27 Jul 2012 15:55:05 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 622DD3520044
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 14:54:54 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RIs7ZH33882246
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 15:54:07 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RGsjTi007145
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 13:54:45 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fills the net_device vlan_features with the proper hardware features,
thus, improving the vlan interface performance.

With the patch applied, I can see around 148% improvement on a TCP_STREAM test,
from 3.5 Gb/s to 8.7 Gb/s. On TCP_RR, I see a 11% improvement, from 18k
to 20. The CPU utilization is almost the same on both cases, from the comparison
above.

Signed-off-by: Breno Leitao <brenohl@br.ibm.com>

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 3769f57..b53a3b6 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4682,6 +4682,7 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 		NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
 	ndev->features = ndev->hw_features |
 		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+	ndev->vlan_features = ndev->hw_features;
 
 	if (test_bit(QL_DMA64, &qdev->flags))
 		ndev->features |= NETIF_F_HIGHDMA;
-- 
1.7.1
