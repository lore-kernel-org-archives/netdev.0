From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4/cxgb4vf: Display 25G and 100G link speed
Date: Fri,  6 Jan 2017 16:51:46 +0530
Message-ID: <1483701706-11882-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, hariprasad@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:29054 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754687AbdAFME7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 07:04:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to report 25G and 100G links, which was missed
as part of commit "eb97ad99f9ed".

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 20 +++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 21 ++++++++++++---------
 2 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6f95187..db436ae 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -188,18 +188,24 @@ static void link_report(struct net_device *dev)
 		const struct port_info *p = netdev_priv(dev);
 
 		switch (p->link_cfg.speed) {
-		case 10000:
-			s = "10Gbps";
+		case 100:
+			s = "100Mbps";
 			break;
 		case 1000:
-			s = "1000Mbps";
+			s = "1Gbps";
 			break;
-		case 100:
-			s = "100Mbps";
+		case 10000:
+			s = "10Gbps";
+			break;
+		case 25000:
+			s = "25Gbps";
 			break;
 		case 40000:
 			s = "40Gbps";
 			break;
+		case 100000:
+			s = "100Gbps";
+			break;
 		default:
 			pr_info("%s: unsupported speed: %d\n",
 				dev->name, p->link_cfg.speed);
@@ -4397,9 +4403,9 @@ static void print_port_info(const struct net_device *dev)
 		spd = " 8 GT/s";
 
 	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_100M)
-		bufp += sprintf(bufp, "100/");
+		bufp += sprintf(bufp, "100M/");
 	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_1G)
-		bufp += sprintf(bufp, "1000/");
+		bufp += sprintf(bufp, "1G/");
 	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_10G)
 		bufp += sprintf(bufp, "10G/");
 	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_25G)
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 0d1a134..ac7a150 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -158,20 +158,23 @@ void t4vf_os_link_changed(struct adapter *adapter, int pidx, int link_ok)
 		netif_carrier_on(dev);
 
 		switch (pi->link_cfg.speed) {
-		case 40000:
-			s = "40Gbps";
+		case 100:
+			s = "100Mbps";
+			break;
+		case 1000:
+			s = "1Gbps";
 			break;
-
 		case 10000:
 			s = "10Gbps";
 			break;
-
-		case 1000:
-			s = "1000Mbps";
+		case 25000:
+			s = "25Gbps";
 			break;
-
-		case 100:
-			s = "100Mbps";
+		case 40000:
+			s = "40Gbps";
+			break;
+		case 100000:
+			s = "100Gbps";
 			break;
 
 		default:
-- 
2.1.0
