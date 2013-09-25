From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 2/2] ip_tunnel: Add fallback tunnels to the hash lists
Date: Wed, 25 Sep 2013 07:55:19 +0200
Message-ID: <20130925055519.GW7660@secunet.com>
References: <20130925055418.GV7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49293 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135Ab3IYFzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 01:55:21 -0400
Content-Disposition: inline
In-Reply-To: <20130925055418.GV7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we can not update the tunnel parameters of
the fallback tunnels because we don't find them in the
hash lists. Fix this by adding them on initialization.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_tunnel.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b8ce640..f2348f2 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -853,8 +853,10 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 	/* FB netdevice is special: we have one, and only one per netns.
 	 * Allowing to move it to another netns is clearly unsafe.
 	 */
-	if (!IS_ERR(itn->fb_tunnel_dev))
+	if (!IS_ERR(itn->fb_tunnel_dev)) {
 		itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
+		ip_tunnel_add(itn, netdev_priv(itn->fb_tunnel_dev));
+	}
 	rtnl_unlock();
 
 	return PTR_RET(itn->fb_tunnel_dev);
-- 
1.7.9.5
