From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Fix addr valid check in enic_set_vf_mac
Date: Wed, 07 Mar 2012 05:50:44 -0800
Message-ID: <20120307135044.17957.92254.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:65002 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab2CGNup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 08:50:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

zero mac address is a valid address for VIC dynamic vnic and sriov Vf's.
Fix the check in enic_set_vf_mac appropriately

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index cf1fb4b..afe9b16 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.38"
+#define DRV_VERSION		"2.1.1.39"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 9080ed6..77b4e87 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1069,7 +1069,7 @@ static int enic_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (err)
 		return err;
 
-	if (is_valid_ether_addr(mac)) {
+	if (is_valid_ether_addr(mac) || is_zero_ether_addr(mac)) {
 		if (vf == PORT_SELF_VF) {
 			memcpy(pp->vf_mac, mac, ETH_ALEN);
 			return 0;
