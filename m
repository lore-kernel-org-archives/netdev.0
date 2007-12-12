From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] netns: network namespace was passed into
	dev_getbyhwaddr but not used
Date: Wed, 12 Dec 2007 14:05:17 +0300
Message-ID: <20071212110517.GA11626@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:62596 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759427AbXLLLDu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 06:03:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netns: network namespace was passed into dev_getbyhwaddr but not used

Signed-off-by: Denis V. Lunev <den@openvz.org>
diff --git a/net/core/dev.c b/net/core/dev.c
index 06615df..677f35b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -675,7 +675,7 @@ struct net_device *dev_getbyhwaddr(struct net *net, unsigned short type, char *h
 
 	ASSERT_RTNL();
 
-	for_each_netdev(&init_net, dev)
+	for_each_netdev(net, dev)
 		if (dev->type == type &&
 		    !memcmp(dev->dev_addr, ha, dev->addr_len))
 			return dev;
