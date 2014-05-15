From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] ip_tunnel: Initialize the fallback device properly
Date: Thu, 15 May 2014 09:43:11 +0200
Message-ID: <20140515074311.GB32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45569 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751345AbaEOHnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:43:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to initialize the fallback device to have a correct mtu
set on this device. Otherwise the mtu is set to null and the device
is unusable.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_tunnel.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b3f8597..25b8997 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -882,6 +882,7 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 	 */
 	if (!IS_ERR(itn->fb_tunnel_dev)) {
 		itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
+		itn->fb_tunnel_dev->mtu = ip_tunnel_bind_dev(itn->fb_tunnel_dev);
 		ip_tunnel_add(itn, netdev_priv(itn->fb_tunnel_dev));
 	}
 	rtnl_unlock();
-- 
1.7.9.5
