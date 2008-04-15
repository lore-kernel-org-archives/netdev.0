From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 7/8][GRE]: Allow to create IPGRE tunnels in net
 namespaces.
Date: Tue, 15 Apr 2008 17:01:49 +0400
Message-ID: <4804A73D.4010701@openvz.org>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43673 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752944AbYDOM1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:27:35 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I.e. set the proper net and mark as NETNS_LOCAL.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index aa97381..7ff5262 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -278,6 +278,8 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct net *net,
 	if (!dev)
 	  return NULL;
 
+	dev_net_set(dev, net);
+
 	if (strchr(name, '%')) {
 		if (dev_alloc_name(dev, name) < 0)
 			goto failed_free;
@@ -1236,6 +1238,7 @@ static void ipgre_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
 static int ipgre_tunnel_init(struct net_device *dev)
-- 
1.5.3.4

