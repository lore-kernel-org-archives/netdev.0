From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 06/12] ip6tunnel: print local/remote addresses like iptunnel does
Date: Fri, 13 Nov 2015 18:08:59 +0100
Message-ID: <1447434545-32182-7-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53660 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933384AbbKMRJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:10 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes output consistent with iptunnel, also supporting reverse DNS
lookup for remote address if requested.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index ba92518..9eb5b2f 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -68,14 +68,17 @@ static void usage(void)
 
 static void print_tunnel(struct ip6_tnl_parm2 *p)
 {
-	char remote[64];
-	char local[64];
-
-	inet_ntop(AF_INET6, &p->raddr, remote, sizeof(remote));
-	inet_ntop(AF_INET6, &p->laddr, local, sizeof(local));
+	char s1[1024];
+	char s2[1024];
 
+	/* Do not use format_host() for local addr,
+	 * symbolic name will not be useful.
+	 */
 	printf("%s: %s/ipv6 remote %s local %s",
-	       p->name, tnl_strproto(p->proto), remote, local);
+	       p->name,
+	       tnl_strproto(p->proto),
+	       format_host(AF_INET6, 16, &p->raddr, s1, sizeof(s1)),
+	       rt_addr_n2a(AF_INET6, 16, &p->laddr, s2, sizeof(s2)));
 	if (p->link) {
 		const char *n = ll_index_to_name(p->link);
 		if (n)
-- 
2.1.2
