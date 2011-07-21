From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next] vmxnet3: fix publicity of NETIF_F_HIGHDMA
Date: Wed, 20 Jul 2011 20:21:51 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1107202019060.27135@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:38504 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751713Ab1GUDVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 23:21:48 -0400
Received: from mailhost3.vmware.com (mailhost3.vmware.com [10.16.27.45])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id A5A3E38019
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 20:21:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_HIGHDMA is being disabled even when dma64 is true. This patch fixes it.

CC: Michal Miroslaw <mirq-linux@rere.qmqm.pl>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
--

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 009277e..b46d101 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2647,7 +2647,7 @@ vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
 		NETIF_F_HW_VLAN_RX | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_LRO;
 	if (dma64)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->hw_features |= NETIF_F_HIGHDMA;
 	netdev->vlan_features = netdev->hw_features &
 				~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 	netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_FILTER;
