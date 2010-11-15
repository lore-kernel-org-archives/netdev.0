From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/5] netdev: add rcu annotations to receive handler hook
Date: Mon, 15 Nov 2010 08:38:12 -0800
Message-ID: <20101115163828.277901297@vyatta.com>
References: <20101115163809.215552143@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38453 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757935Ab0KOQln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 11:41:43 -0500
Content-Disposition: inline; filename=rx_handler_rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested by Eric's bridge RCU changes.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/netdevice.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/include/linux/netdevice.h	2010-11-14 11:41:53.224298362 -0800
+++ b/include/linux/netdevice.h	2010-11-14 11:42:42.546359900 -0800
@@ -995,8 +995,8 @@ struct net_device {
 	unsigned int		real_num_rx_queues;
 #endif
 
-	rx_handler_func_t	*rx_handler;
-	void			*rx_handler_data;
+	rx_handler_func_t __rcu	*rx_handler;
+	void __rcu		*rx_handler_data;
 
 	struct netdev_queue __rcu *ingress_queue;
 


