From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/35] ipvs: Don't protect ip_vs_addr_is_unicast with CONFIG_SYSCTL
Date: Sat, 17 Oct 2015 13:32:36 +0200
Message-ID: <1445081590-2924-2-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48318 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbbJQL0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:12 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

I arranged the code so that the compiler can remove the unecessary bits
in ip_vs_leave when CONFIG_SYSCTL is unset, and removed an explicit
CONFIG_SYSCTL.

Unfortunately when rebasing my work on top of that of Alex Gartrell I
missed the fact that the newly added function ip_vs_addr_is_unicast was
surrounded by CONFIG_SYSCTL.

So remove the now unnecessary CONFIG_SYSCTL guards around
ip_vs_addr_is_unicast.  It is causing build failures today when
CONFIG_SYSCTL is not selected and any self respecting compiler will
notice that sysctl_cache_bypass is always false without CONFIG_SYSCTL
and not include the logic from the function ip_vs_addr_is_unicast in
the compiled code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 37dd77a..d08df43 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -547,7 +547,6 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	return cp;
 }
 
-#ifdef CONFIG_SYSCTL
 static inline int ip_vs_addr_is_unicast(struct net *net, int af,
 					union nf_inet_addr *addr)
 {
@@ -557,7 +556,6 @@ static inline int ip_vs_addr_is_unicast(struct net *net, int af,
 #endif
 	return (inet_addr_type(net, addr->ip) == RTN_UNICAST);
 }
-#endif
 
 /*
  *  Pass or drop the packet.
-- 
2.1.4
