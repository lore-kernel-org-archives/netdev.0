From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 4/4] ip_tunnel: Remove double unregister of the fallback
 device
Date: Tue, 1 Oct 2013 11:37:37 +0200
Message-ID: <20131001093737.GJ7660@secunet.com>
References: <20131001093359.GG7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34204 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364Ab3JAJhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 05:37:41 -0400
Content-Disposition: inline
In-Reply-To: <20131001093359.GG7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When queueing the netdevices for removal, we queue the
fallback device twice in ip_tunnel_destroy(). The first
time when we queue all netdevices in the namespace and
then again explicitly. Fix this by removing the explicit
queueing of the fallback device.

Bug was introduced when network namespace support was added
with commit 6c742e714d8 ("ipip: add x-netns support").

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_tunnel.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 895a353..63a6d6d 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -886,8 +886,6 @@ static void ip_tunnel_destroy(struct ip_tunnel_net *itn, struct list_head *head,
 			if (!net_eq(dev_net(t->dev), net))
 				unregister_netdevice_queue(t->dev, head);
 	}
-	if (itn->fb_tunnel_dev)
-		unregister_netdevice_queue(itn->fb_tunnel_dev, head);
 }
 
 void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops)
-- 
1.7.9.5
