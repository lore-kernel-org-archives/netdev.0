From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/9] tipc: optimize the initialization of network device notifier
Date: Thu, 16 Aug 2012 18:09:06 -0400
Message-ID: <1345154954-12526-2-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57494 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab2HPWOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:51 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Ethernet media initialization is only done when TIPC is started or
switched to network mode. So the initialization of the network device
notifier structure can be moved out of this function and done
statically instead.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 90ac9bf..0f312c2 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -58,7 +58,16 @@ struct eth_bearer {
 static struct tipc_media eth_media_info;
 static struct eth_bearer eth_bearers[MAX_ETH_BEARERS];
 static int eth_started;
-static struct notifier_block notifier;
+
+static int recv_notification(struct notifier_block *nb, unsigned long evt,
+			      void *dv);
+/*
+ * Network device notifier info
+ */
+static struct notifier_block notifier = {
+	.notifier_call	= recv_notification,
+	.priority	= 0
+};
 
 /**
  * eth_media_addr_set - initialize Ethernet media address structure
@@ -357,8 +366,6 @@ int tipc_eth_media_start(void)
 	if (res)
 		return res;
 
-	notifier.notifier_call = &recv_notification;
-	notifier.priority = 0;
 	res = register_netdevice_notifier(&notifier);
 	if (!res)
 		eth_started = 1;
-- 
1.7.11.1
