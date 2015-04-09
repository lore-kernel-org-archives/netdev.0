From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] vti6: fix uninit when using x-netns
Date: Thu, 9 Apr 2015 12:32:11 +0200
Message-ID: <1428575531-24870-3-git-send-email-steffen.klassert@secunet.com>
References: <1428575531-24870-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43775 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933011AbbDIKcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 06:32:31 -0400
In-Reply-To: <1428575531-24870-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yao Xiwei <xiwei.yao@6wind.com>

When the kernel deleted a vti6 interface, this interface was not removed from
the tunnels list. Thus, when the ip6_vti module was removed, this old interface
was found and the kernel tried to delete it again. This was leading to a kernel
panic.

Fixes: 61220ab34948 ("vti6: Enable namespace changing")
Signed-off-by: Yao Xiwei <xiwei.yao@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 5fb9e21..a4ac850 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -288,8 +288,7 @@ static struct ip6_tnl *vti6_locate(struct net *net, struct __ip6_tnl_parm *p,
 static void vti6_dev_uninit(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	struct net *net = dev_net(dev);
-	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
+	struct vti6_net *ip6n = net_generic(t->net, vti6_net_id);
 
 	if (dev == ip6n->fb_tnl_dev)
 		RCU_INIT_POINTER(ip6n->tnls_wc[0], NULL);
-- 
1.9.1
