From: Jon Paul Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 1/1] [TIPC]: Fixed erroneous introduction of for_each_netdev
Date: Tue, 15 May 2007 20:21:14 -0400
Message-ID: <11792748743802-git-send-email-jon.maloy@ericsson.com>
References: <1>
Cc: netdev@vger.kernel.org, Jon Paul Maloy <jon.maloy@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr2.ericy.com ([198.24.6.3]:44130 "EHLO imr2.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759457AbXEPAVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 20:21:17 -0400
In-Reply-To: <1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>
---
 net/tipc/eth_media.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 0ee6ded..c73c206 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -120,18 +120,20 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 
 static int enable_bearer(struct tipc_bearer *tb_ptr)
 {
-	struct net_device *dev, *pdev;
+	struct net_device *dev = NULL;
+	struct net_device *pdev = NULL;
 	struct eth_bearer *eb_ptr = &eth_bearers[0];
 	struct eth_bearer *stop = &eth_bearers[MAX_ETH_BEARERS];
 	char *driver_name = strchr((const char *)tb_ptr->name, ':') + 1;
 
 	/* Find device with specified name */
-	dev = NULL;
-	for_each_netdev(pdev)
-		if (!strncmp(dev->name, driver_name, IFNAMSIZ)) {
+
+	for_each_netdev(pdev){
+		if (!strncmp(pdev->name, driver_name, IFNAMSIZ)) {
 			dev = pdev;
 			break;
 		}
+        }
 	if (!dev)
 		return -ENODEV;
 
-- 
1.5.0.5

