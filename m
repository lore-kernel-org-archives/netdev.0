From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 7/8][IPIP]: Allow to create IPIP tunnels in net
 namespaces.
Date: Tue, 15 Apr 2008 16:39:54 +0400
Message-ID: <4804A21A.3050303@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47755 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752548AbYDOMFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:05:35 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the proper net before calling register_netdev and disable 
the tunnel device netns changing.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 1de39e1..149111f 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -239,6 +239,8 @@ static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
 	if (dev == NULL)
 		return NULL;
 
+	dev_net_set(dev, net);
+
 	if (strchr(name, '%')) {
 		if (dev_alloc_name(dev, name) < 0)
 			goto failed_free;
@@ -839,6 +841,7 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
 static int ipip_tunnel_init(struct net_device *dev)
-- 
1.5.3.4

