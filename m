From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH] ip6_tunnel: set rtnl_link_ops before calling register_netdevice
Date: Fri,  1 Apr 2016 17:17:50 -0300
Message-ID: <1459541870-26938-1-git-send-email-cascardo@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbcDAUR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2016 16:17:59 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7AA31AACE0
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 20:17:59 +0000 (UTC)
Received: from indiana.gru.redhat.com (ovpn-113-95.phx2.redhat.com [10.3.113.95])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u31KHv9x005433
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2016 16:17:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating an ip6tnl tunnel with ip tunnel, rtnl_link_ops is not set
before ip6_tnl_create2 is called. When register_netdevice is called, there
is no linkinfo attribute in the NEWLINK message because of that.

Setting rtnl_link_ops before calling register_netdevice fixes that.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
---
 net/ipv6/ip6_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index eb2ac4b..1f20345 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -252,12 +252,12 @@ static int ip6_tnl_create2(struct net_device *dev)
 
 	t = netdev_priv(dev);
 
+	dev->rtnl_link_ops = &ip6_link_ops;
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out;
 
 	strcpy(t->parms.name, dev->name);
-	dev->rtnl_link_ops = &ip6_link_ops;
 
 	dev_hold(dev);
 	ip6_tnl_link(ip6n, t);
-- 
2.5.0
