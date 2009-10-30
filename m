From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] veth: Fix veth_dellink method
Date: Fri, 30 Oct 2009 08:00:31 +0100
Message-ID: <4AEA8F0F.4030100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54557 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756100AbZJ3HAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 03:00:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 23289a37e2b127dfc4de1313fba15bb4c9f0cd5b
(net: add a list_head parameter to dellink() method),
I forgot to actually use this parameter in veth_dellink.

I remember feeling a bit uncomfortable about veth_close(),
because it does :

netif_carrier_off(dev);
netif_carrier_off(priv->peer);


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index ffb502d..9bed694 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -450,8 +450,8 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
 	priv = netdev_priv(dev);
 	peer = priv->peer;
 
-	unregister_netdevice(dev);
-	unregister_netdevice(peer);
+	unregister_netdevice_queue(dev, head);
+	unregister_netdevice_queue(peer, head);
 }
 
 static const struct nla_policy veth_policy[VETH_INFO_MAX + 1];

