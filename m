From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 2/5] ipv6: move IPV6_TCLASS_MASK definition in ipv6.h
Date: Sun,  8 Dec 2013 15:46:58 +0100
Message-ID: <1386514021-11646-2-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57309 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758861Ab3LHOrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 09:47:12 -0500
In-Reply-To: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 include/net/ipv6.h    | 1 +
 net/ipv6/ip6_gre.c    | 1 -
 net/ipv6/ip6_tunnel.c | 1 -
 3 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index eb198ac..f0edf00 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -237,6 +237,7 @@ struct ip6_flowlabel {
 
 #define IPV6_FLOWINFO_MASK	cpu_to_be32(0x0FFFFFFF)
 #define IPV6_FLOWLABEL_MASK	cpu_to_be32(0x000FFFFF)
+#define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
 
 struct ipv6_fl_socklist {
 	struct ipv6_fl_socklist	__rcu	*next;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 8acb286..c50de06 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -61,7 +61,6 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
-#define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
 #define IPV6_TCLASS_SHIFT 20
 
 #define HASH_SIZE_SHIFT  5
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index d606232..f5e8a98 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -70,7 +70,6 @@ MODULE_ALIAS_NETDEV("ip6tnl0");
 #define IP6_TNL_TRACE(x...) do {;} while(0)
 #endif
 
-#define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
 #define IPV6_TCLASS_SHIFT 20
 
 #define HASH_SIZE_SHIFT  5
-- 
1.8.4.3
