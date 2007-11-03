From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 09/11] netpoll: ethernet devices only
Date: Sat, 03 Nov 2007 11:43:23 -0700
Message-ID: <20071103184338.929307786@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40986 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757987AbXKCXgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:39 -0400
Content-Disposition: inline; filename=netpoll-ether-only.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netpoll only works on Ethernet devices, so check during setup
rather than just failing silently later.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/core/netpoll.c	2007-11-03 11:05:33.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 11:08:23.000000000 -0700
@@ -653,6 +653,12 @@ int netpoll_setup(struct netpoll *np, st
 	unsigned long flags;
 	int err;
 
+	if (ndev->type != ARPHRD_ETHER) {
+		printk(KERN_ERR "netpoll: %s is not an ethernet device\n",
+		       ndev->name);
+		return -EINVAL;
+	}
+
 	np->dev = ndev;
 	if (!ndev->npinfo) {
 		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

