From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: remove unused comefrom hookmask argument
Date: Fri, 29 May 2015 01:44:52 +0200
Message-ID: <1432856695-23831-2-git-send-email-pablo@netfilter.org>
References: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40647 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932401AbbE1Xj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 19:39:59 -0400
In-Reply-To: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ip_tables.c  |    4 +---
 net/ipv6/netfilter/ip6_tables.c |    4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index c69db7f..583779f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1441,7 +1441,6 @@ static int
 compat_find_calc_match(struct xt_entry_match *m,
 		       const char *name,
 		       const struct ipt_ip *ip,
-		       unsigned int hookmask,
 		       int *size)
 {
 	struct xt_match *match;
@@ -1510,8 +1509,7 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	entry_offset = (void *)e - (void *)base;
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
-		ret = compat_find_calc_match(ematch, name,
-					     &e->ip, e->comefrom, &off);
+		ret = compat_find_calc_match(ematch, name, &e->ip, &off);
 		if (ret != 0)
 			goto release_matches;
 		++j;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1a732a1..d54f049 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1456,7 +1456,6 @@ static int
 compat_find_calc_match(struct xt_entry_match *m,
 		       const char *name,
 		       const struct ip6t_ip6 *ipv6,
-		       unsigned int hookmask,
 		       int *size)
 {
 	struct xt_match *match;
@@ -1525,8 +1524,7 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	entry_offset = (void *)e - (void *)base;
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
-		ret = compat_find_calc_match(ematch, name,
-					     &e->ipv6, e->comefrom, &off);
+		ret = compat_find_calc_match(ematch, name, &e->ipv6, &off);
 		if (ret != 0)
 			goto release_matches;
 		++j;
-- 
1.7.10.4
