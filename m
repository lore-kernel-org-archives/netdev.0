From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/3] sit: fix tunnel update via netlink
Date: Wed,  3 Jul 2013 17:00:34 +0200
Message-ID: <1372863636-8866-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20130627.223621.1852663736303796496.davem@davemloft.net>
 <1372863636-8866-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60404 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109Ab3GCPDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 11:03:19 -0400
In-Reply-To: <1372863636-8866-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device can stand in another netns, hence we need to do the lookup in netns
tunnel->net.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 85ff37b..a3437a4 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1426,9 +1426,9 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 			  struct nlattr *data[])
 {
-	struct ip_tunnel *t;
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
-	struct net *net = dev_net(dev);
+	struct net *net = t->net;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd ip6rd;
-- 
1.8.2.1
