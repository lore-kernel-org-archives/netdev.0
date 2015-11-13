From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 01/12] ip{,6}tunnel: get rid of extraneous whitespace when printing
Date: Fri, 13 Nov 2015 18:08:54 +0100
Message-ID: <1447434545-32182-2-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51423 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933386AbbKMRJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:07 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put whitespace in the beginning of optional parts, not as suffix
anywhere. Also drop double whitespaces in between words.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c |  4 ++--
 ip/iptunnel.c  | 16 ++++++++--------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 9884efd..07010d3 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -111,9 +111,9 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 			printf(" key %u", ntohl(p->i_key));
 		else if ((p->i_flags|p->o_flags)&GRE_KEY) {
 			if (p->i_flags&GRE_KEY)
-				printf(" ikey %u ", ntohl(p->i_key));
+				printf(" ikey %u", ntohl(p->i_key));
 			if (p->o_flags&GRE_KEY)
-				printf(" okey %u ", ntohl(p->o_key));
+				printf(" okey %u", ntohl(p->o_key));
 		}
 
 		if (p->i_flags&GRE_SEQ)
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 78fa988..36534f2 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -343,7 +343,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	/* Do not use format_host() for local addr,
 	 * symbolic name will not be useful.
 	 */
-	printf("%s: %s/ip  remote %s  local %s ",
+	printf("%s: %s/ip remote %s local %s",
 	       p->name,
 	       tnl_strproto(p->iph.protocol),
 	       p->iph.daddr ? format_host(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1)) : "any",
@@ -371,13 +371,13 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	if (p->link) {
 		const char *n = ll_index_to_name(p->link);
 		if (n)
-			printf(" dev %s ", n);
+			printf(" dev %s", n);
 	}
 
 	if (p->iph.ttl)
-		printf(" ttl %d ", p->iph.ttl);
+		printf(" ttl %d", p->iph.ttl);
 	else
-		printf(" ttl inherit ");
+		printf(" ttl inherit");
 
 	if (p->iph.tos) {
 		SPRINT_BUF(b1);
@@ -393,11 +393,11 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 		printf(" nopmtudisc");
 
 	if (p->iph.protocol == IPPROTO_IPV6 && !tnl_ioctl_get_6rd(p->name, &ip6rd) && ip6rd.prefixlen) {
-		printf(" 6rd-prefix %s/%u ",
+		printf(" 6rd-prefix %s/%u",
 		       inet_ntop(AF_INET6, &ip6rd.prefix, s1, sizeof(s1)),
 		       ip6rd.prefixlen);
 		if (ip6rd.relay_prefix) {
-			printf("6rd-relay_prefix %s/%u ",
+			printf(" 6rd-relay_prefix %s/%u",
 			       format_host(AF_INET, 4, &ip6rd.relay_prefix, s1, sizeof(s1)),
 			       ip6rd.relay_prefixlen);
 		}
@@ -407,9 +407,9 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 		printf(" key %u", ntohl(p->i_key));
 	else if ((p->i_flags|p->o_flags)&GRE_KEY) {
 		if (p->i_flags&GRE_KEY)
-			printf(" ikey %u ", ntohl(p->i_key));
+			printf(" ikey %u", ntohl(p->i_key));
 		if (p->o_flags&GRE_KEY)
-			printf(" okey %u ", ntohl(p->o_key));
+			printf(" okey %u", ntohl(p->o_key));
 	}
 
 	if (p->i_flags&GRE_SEQ)
-- 
2.1.2
