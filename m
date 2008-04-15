From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 7/7][IP6TUNNEL]: Allow to create IP6 tunnels in
 net namespaces.
Date: Tue, 15 Apr 2008 18:10:36 +0400
Message-ID: <4804B75C.7090608@openvz.org>
References: <4804B478.3040606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33534 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757257AbYDONgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:36:18 -0400
In-Reply-To: <4804B478.3040606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And no need in some IPPROTO_XXX enabling, since ipv6 code
doesn't have any filtering.

So, just set proper net and mark device with NETNS_LOCAL.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/ip6_tunnel.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index d9b2721..2bda3ba 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -243,6 +243,8 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
 	if (dev == NULL)
 		goto failed;
 
+	dev_net_set(dev, net);
+
 	if (strchr(name, '%')) {
 		if (dev_alloc_name(dev, name) < 0)
 			goto failed_free;
@@ -1341,6 +1343,7 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->mtu = ETH_DATA_LEN - sizeof (struct ipv6hdr);
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
+	dev->features |= NETIF_F_NETNS_LOCAL;
 }
 
 
-- 
1.5.3.4

