From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv6: Fix for adding multicast route for loopback device
 automatically.
Date: Wed, 07 Dec 2011 15:23:45 +0800
Message-ID: <4EDF1481.1080106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, yoshfuji@linux-ipv6.org
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63022 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751799Ab1LGHXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 02:23:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no obvious reason to add a default multicast route for loopback
devices, otherwise there would be a route entry whose dst.error set to
-ENETUNREACH that would blocking all multicast packets.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv6/addrconf.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cf88df8..36806de 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1805,7 +1805,8 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 		return ERR_PTR(-EACCES);
 
 	/* Add default multicast route */
-	addrconf_add_mroute(dev);
+	if (!(dev->flags & IFF_LOOPBACK))
+		addrconf_add_mroute(dev);
 
 	/* Add link local route */
 	addrconf_add_lroute(dev);
-- 
1.7.3.2
