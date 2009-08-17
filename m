From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 1/3] be2net: Set mac addr in hw regardless of
	netif_running()
Date: Mon, 17 Aug 2009 16:28:04 +0530
Message-ID: <20090817105803.GA10217@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:41076 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756895AbZHQK6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 06:58:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_mac_addr_set() currently is broken when netif_running() is false.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 45507d8..3623460 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -117,23 +117,18 @@ void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm, u16 num_popped)
 	iowrite32(val, adapter->db + DB_CQ_OFFSET);
 }
 
-
 static int be_mac_addr_set(struct net_device *netdev, void *p)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 	int status = 0;
 
-	if (netif_running(netdev)) {
-		status = be_cmd_pmac_del(adapter, adapter->if_handle,
-				adapter->pmac_id);
-		if (status)
-			return status;
-
-		status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
-				adapter->if_handle, &adapter->pmac_id);
-	}
+	status = be_cmd_pmac_del(adapter, adapter->if_handle, adapter->pmac_id);
+	if (status)
+		return status;
 
+	status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
+			adapter->if_handle, &adapter->pmac_id);
 	if (!status)
 		memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
-- 
1.6.0.4

