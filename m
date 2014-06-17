From: Jeff Liu <jeff.liu@oracle.com>
Subject: [PATCH 23/24] net: return actual error on register_queue_kobjects
Date: Tue, 17 Jun 2014 22:32:42 +0800
Message-ID: <53A0518A.7020300@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50321 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932696AbaFQOd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 10:33:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Liu <jeff.liu@oracle.com>

Return the actual error code if call kset_create_and_add() failed

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 net/core/net-sysfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1cac29e..5c1c1e5 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1200,8 +1200,8 @@ static int register_queue_kobjects(struct net_device *net)
 #ifdef CONFIG_SYSFS
 	net->queues_kset = kset_create_and_add("queues",
 	    NULL, &net->dev.kobj);
-	if (!net->queues_kset)
-		return -ENOMEM;
+	if (IS_ERR(net->queues_kset))
+		return PTR_ERR(net->queues_kset);
 	real_rx = net->real_num_rx_queues;
 #endif
 	real_tx = net->real_num_tx_queues;
-- 
1.8.3.2
