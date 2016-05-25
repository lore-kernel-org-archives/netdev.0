From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] ipv6: hide ip6_encap_hlen/ip6_tnl_encap definitions
Date: Wed, 25 May 2016 16:50:45 +0200
Message-ID: <1464187873-219087-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:65076 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551AbcEYOv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 10:51:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent cleanup moved MAX_IPTUN_ENCAP_OPS along with some other
definitions, but it is now invisible when CONFIG_INET is
not defined, but still referenced from ip6_tunnel.h:

In file included from net/xfrm/xfrm_input.c:17:0:
include/net/ip6_tunnel.h:67:17: error: 'MAX_IPTUN_ENCAP_OPS' undeclared here (not in a function)
   ip6tun_encaps[MAX_IPTUN_ENCAP_OPS];
                 ^~~~~~~~~~~~~~~~~~~

This hides the ip6_encap_hlen and ip6_tnl_encap functions inside
of CONFIG_INET so we don't run into the the problem.

Alternatively we could move the macro out of the #ifdef again to
restore the previous behavior

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 55c2bc143224 ("net: Cleanup encap items in ip_tunnels.h")
---
 include/net/ip6_tunnel.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index d325c81332e3..43a5a0e4524c 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -63,6 +63,8 @@ struct ip6_tnl_encap_ops {
 			    u8 *protocol, struct flowi6 *fl6);
 };
 
+#ifdef CONFIG_INET
+
 extern const struct ip6_tnl_encap_ops __rcu *
 		ip6tun_encaps[MAX_IPTUN_ENCAP_OPS];
 
@@ -138,7 +140,6 @@ struct net *ip6_tnl_get_link_net(const struct net_device *dev);
 int ip6_tnl_get_iflink(const struct net_device *dev);
 int ip6_tnl_change_mtu(struct net_device *dev, int new_mtu);
 
-#ifdef CONFIG_INET
 static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 				  struct net_device *dev)
 {
-- 
2.7.0
