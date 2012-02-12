From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Fix address deregistration for sriov vf
	during port profile disassociate
Date: Sat, 11 Feb 2012 23:37:37 -0800
Message-ID: <20120212073737.7768.99208.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:10433 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab2BLHhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 02:37:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch fixes erroneous PF address deregistration in cases where
a port profile disassociate is called on an already disassociated interface.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: sujith sankar <ssujith@cisco.com>
Signed-off-by: ChingWei Chang <cwchang@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h    |    2 +-
 drivers/net/ethernet/cisco/enic/enic_pp.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 54fd9c3..e65d431 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.33"
+#define DRV_VERSION		"2.1.1.34"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c b/drivers/net/ethernet/cisco/enic/enic_pp.c
index 22bf03a..c758674 100644
--- a/drivers/net/ethernet/cisco/enic/enic_pp.c
+++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
@@ -207,7 +207,7 @@ static int enic_pp_disassociate(struct enic *enic, int vf,
 	if (!is_zero_ether_addr(pp->mac_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_del_addr,
 			pp->mac_addr);
-	else if (!is_zero_ether_addr(netdev->dev_addr))
+	else if (vf == PORT_SELF_VF && !is_zero_ether_addr(netdev->dev_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_del_addr,
 			netdev->dev_addr);
 
@@ -294,7 +294,7 @@ static int enic_pp_associate(struct enic *enic, int vf,
 	if (!is_zero_ether_addr(pp->mac_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_add_addr,
 			pp->mac_addr);
-	else if (!is_zero_ether_addr(netdev->dev_addr))
+	else if (vf == PORT_SELF_VF && !is_zero_ether_addr(netdev->dev_addr))
 		ENIC_DEVCMD_PROXY_BY_INDEX(vf, err, enic, vnic_dev_add_addr,
 			netdev->dev_addr);
 
