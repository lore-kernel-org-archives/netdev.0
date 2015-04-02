From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 11/12] dev: set iflink to 0 for virtual interfaces
Date: Thu,  2 Apr 2015 17:07:10 +0200
Message-ID: <1427987231-3669-12-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56631 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbbDBPH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:27 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Virtual interfaces are supposed to set an iflink value != of their ifindex.
It was not the case for some of them, like vxlan, bond or bridge.
Let's set iflink to 0 when dev->rtnl_link_ops is set.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/dev.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3be107e0bc93..26622d614f81 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -672,6 +672,10 @@ int dev_get_iflink(const struct net_device *dev)
 	if (dev->netdev_ops && dev->netdev_ops->ndo_get_iflink)
 		return dev->netdev_ops->ndo_get_iflink(dev);
 
+	/* If dev->rtnl_link_ops is set, it's a virtual interface. */
+	if (dev->rtnl_link_ops)
+		return 0;
+
 	return dev->ifindex;
 }
 EXPORT_SYMBOL(dev_get_iflink);
-- 
2.2.2
