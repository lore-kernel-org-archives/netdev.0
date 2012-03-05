From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] IPv6: Fix not join all-router mcast group when forwarding
 set.
Date: Mon, 05 Mar 2012 17:54:33 +0800
Message-ID: <4F548D59.1060600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1289 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756387Ab2CEJye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 04:54:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When forwarding was set and a new net device is register,
we need add this device to the all-router mcast group.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv6/addrconf.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c02280a..1e09591 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -434,6 +434,10 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	/* Join all-node multicast group */
 	ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
 
+	/* Join all-router multicast group if forwarding is set */
+        if (ndev->cnf.forwarding && dev && (dev->flags & IFF_MULTICAST))
+		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
+
 	return ndev;
 }
 
-- 
1.7.1
