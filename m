From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/19] netfilter: tproxy: fix build with IP6_NF_IPTABLES=n
Date: Tue, 20 Aug 2013 12:54:44 +0200
Message-ID: <1376996091-3964-13-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60101 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213Ab3HTKzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:13 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

after commit 93742cf (netfilter: tproxy: remove nf_tproxy_core.h)

CONFIG_IPV6=y
CONFIG_IP6_NF_IPTABLES=n

gives us:

net/netfilter/xt_TPROXY.c: In function 'nf_tproxy_get_sock_v6':
net/netfilter/xt_TPROXY.c:178:4: error: implicit declaration of function 'inet6_lookup_listener'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TPROXY.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 851383a..5d8a3a3 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -161,7 +161,7 @@ nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 	return sk;
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
+#ifdef XT_TPROXY_HAVE_IPV6
 static inline struct sock *
 nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
 		      const struct in6_addr *saddr, const struct in6_addr *daddr,
-- 
1.7.10.4
