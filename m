From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH net] sit: set rtnl_link_ops before calling register_netdevice
Date: Mon, 25 Jan 2016 11:29:19 -0200
Message-ID: <1453728559-4903-1-git-send-email-cascardo@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293AbcAYN33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 08:29:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a SIT tunnel with ip tunnel, rtnl_link_ops is not set before
ipip6_tunnel_create is called. When register_netdevice is called, there is
no linkinfo attribute in the NEWLINK message because of that.

Setting rtnl_link_ops before calling register_netdevice fixes that.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
---
 net/ipv6/sit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e794ef6..2066d1c 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -201,14 +201,14 @@ static int ipip6_tunnel_create(struct net_device *dev)
 	if ((__force u16)t->parms.i_flags & SIT_ISATAP)
 		dev->priv_flags |= IFF_ISATAP;
 
+	dev->rtnl_link_ops = &sit_link_ops;
+
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out;
 
 	ipip6_tunnel_clone_6rd(dev, sitn);
 
-	dev->rtnl_link_ops = &sit_link_ops;
-
 	dev_hold(dev);
 
 	ipip6_tunnel_link(sitn, t);
-- 
2.5.0
