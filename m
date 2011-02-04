From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Decouple mac address registration and
	deregistration from port profile set operation
Date: Fri, 04 Feb 2011 14:57:16 -0800
Message-ID: <20110204225716.6497.20918.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:1778 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab1BDW5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 17:57:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch removes VM mac address registration and deregistration code during
port profile set operation. We can delay mac address registration until
enic_open.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    6 ------
 2 files changed, 1 insertions(+), 7 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index ca3be4f..44865bb 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.2"
+#define DRV_VERSION		"2.1.1.2a"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 89664c6..37f907b 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1381,9 +1381,6 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 
 		if (is_zero_ether_addr(netdev->dev_addr))
 			random_ether_addr(netdev->dev_addr);
-	} else if (new_pp.request == PORT_REQUEST_DISASSOCIATE) {
-		if (!is_zero_ether_addr(enic->pp.mac_addr))
-			enic_dev_del_addr(enic, enic->pp.mac_addr);
 	}
 
 	memcpy(&enic->pp, &new_pp, sizeof(struct enic_port_profile));
@@ -1392,9 +1389,6 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 	if (err)
 		goto set_port_profile_cleanup;
 
-	if (!is_zero_ether_addr(enic->pp.mac_addr))
-		enic_dev_add_addr(enic, enic->pp.mac_addr);
-
 set_port_profile_cleanup:
 	memset(enic->pp.vf_mac, 0, ETH_ALEN);
 

