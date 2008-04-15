From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 7/8][SIT]: Allow to create SIT tunnels in net namespaces.
Date: Tue, 15 Apr 2008 17:37:44 +0400
Message-ID: <4804AFA8.8070605@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55799 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbYDONDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:03:30 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set proper net and mark a new device as NETNS_LOCAL before registering.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 7badac6..4b2f103 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -182,6 +182,8 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
 	if (dev == NULL)
 		return NULL;
 
+	dev_net_set(dev, net);
+
 	if (strchr(name, '%')) {
 		if (dev_alloc_name(dev, name) < 0)
 			goto failed_free;
@@ -1029,6 +1031,7 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
+	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
 static int ipip6_tunnel_init(struct net_device *dev)
-- 
1.5.3.4

