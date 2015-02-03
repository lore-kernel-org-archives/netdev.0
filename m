From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] veth: set iflink to the peer veth
Date: Tue,  3 Feb 2015 16:41:46 +0100
Message-ID: <1422978106-4744-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49609 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965647AbbBCPly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 10:41:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the peer netns is advertised in rtnl messages, we can set this property
so that IFLA_LINK will advertise the peer ifindex. It allows the userland to get
the full veth configuration.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/veth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 4cca36ebc4fb..02d1f798a371 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -427,9 +427,11 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	priv = netdev_priv(dev);
 	rcu_assign_pointer(priv->peer, peer);
+	dev->iflink = peer->ifindex;
 
 	priv = netdev_priv(peer);
 	rcu_assign_pointer(priv->peer, dev);
+	peer->iflink = dev->ifindex;
 	return 0;
 
 err_register_dev:
-- 
2.2.2
