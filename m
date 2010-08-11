From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/7] enic: Add set mac address
Date: Tue, 10 Aug 2010 21:54:55 -0700
Message-ID: <20100811045455.3877.96963.stgit@savbu-pc100.cisco.com>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:13215 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab0HKEy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:54:56 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch implements the ndo_set_mac_address netdev operation for an enic device

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index f239aa8..75869ed 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.1"
+#define DRV_VERSION		"1.4.1.2"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 77a7f87..07aa033 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -911,7 +911,9 @@ static int enic_set_mac_address_dynamic(struct net_device *netdev, void *p)
 
 static int enic_set_mac_address(struct net_device *netdev, void *p)
 {
-	return -EOPNOTSUPP;
+	struct sockaddr *saddr = p;
+
+	return enic_set_mac_addr(netdev, (char *)saddr->sa_data);
 }
 
 static int enic_dev_packet_filter(struct enic *enic, int directed,

