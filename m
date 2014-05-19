From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net v2] ip_tunnel: Initialize the fallback device properly
Date: Mon, 19 May 2014 11:36:56 +0200
Message-ID: <20140519093656.GE32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39753 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803AbaESJhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 05:37:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to initialize the fallback device to have a correct mtu
set on this device. Otherwise the mtu is set to null and the device
is unusable.

Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---

v2: Add a reference to the commit that added the bug.
    No code changes since v1.

 net/ipv4/ip_tunnel.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 49721d7..2acc233 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -883,6 +883,7 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 	 */
 	if (!IS_ERR(itn->fb_tunnel_dev)) {
 		itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
+		itn->fb_tunnel_dev->mtu = ip_tunnel_bind_dev(itn->fb_tunnel_dev);
 		ip_tunnel_add(itn, netdev_priv(itn->fb_tunnel_dev));
 	}
 	rtnl_unlock();
-- 
1.7.9.5
