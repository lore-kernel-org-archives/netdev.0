From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: ipv6: minor: use in6addr_any in token init
Date: Tue,  9 Apr 2013 15:47:14 +0200
Message-ID: <1365515236-7154-2-git-send-email-dborkman@redhat.com>
References: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761303Ab3DINrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 09:47:22 -0400
In-Reply-To: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we check for !ipv6_addr_any(&in6_dev->token) in
addrconf_prefix_rcv(), make the token initialization on
device setup more intuitive by using in6addr_any as an
initializer.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/addrconf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 65d8139..645bf31 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -422,7 +422,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		ipv6_regen_rndid((unsigned long) ndev);
 	}
 #endif
-	memset(ndev->token.s6_addr, 0, sizeof(ndev->token.s6_addr));
+	ndev->token = in6addr_any;
 
 	if (netif_running(dev) && addrconf_qdisc_ok(dev))
 		ndev->if_flags |= IF_READY;
-- 
1.7.1
