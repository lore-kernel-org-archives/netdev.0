From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ip6_gre: release cached dst on tunnel removal
Date: Tue, 25 Aug 2015 16:20:34 +0200
Message-ID: <1440512434-4488-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, huaibin Wang <huaibin.wang@6wind.com>,
	Dmitry Kozlov <xeb@mail.ru>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:41319 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbHYOVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 10:21:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: huaibin Wang <huaibin.wang@6wind.com>

When a tunnel is deleted, the cached dst entry should be released.

This problem may prevent the removal of a netns (seen with a x-netns IPv6
gre tunnel):
  unregister_netdevice: waiting for lo to become free. Usage count = 3

CC: Dmitry Kozlov <xeb@mail.ru>
Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Signed-off-by: huaibin Wang <huaibin.wang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index a38d3ac0f18f..69f4f689f06a 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -361,6 +361,7 @@ static void ip6gre_tunnel_uninit(struct net_device *dev)
 	struct ip6gre_net *ign = net_generic(t->net, ip6gre_net_id);
 
 	ip6gre_tunnel_unlink(ign, t);
+	ip6_tnl_dst_reset(t);
 	dev_put(dev);
 }
 
-- 
2.4.2
