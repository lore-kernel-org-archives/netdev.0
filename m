From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/23] netfilter: x_tables: remove obsolete check
Date: Fri, 22 Apr 2016 15:39:47 +0200
Message-ID: <1461332394-3994-17-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45274 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846AbcDVNkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:21 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B00BF4B9F3
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 99C35FAB48
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D0C349D10E
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:15 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Since 'netfilter: x_tables: validate targets of jumps' change we
validate that the target aligns exactly with beginning of a rule,
so offset test is now redundant.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 8 --------
 net/ipv4/netfilter/ip_tables.c  | 7 -------
 net/ipv6/netfilter/ip6_tables.c | 7 -------
 3 files changed, 22 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 668c5dc..8cefb7a 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -461,14 +461,6 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				if (strcmp(t->target.u.user.name,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
-					if (newpos > newinfo->size -
-						sizeof(struct arpt_entry)) {
-						duprintf("mark_source_chains: "
-							"bad verdict (%i)\n",
-								newpos);
-						return 0;
-					}
-
 					/* This a jump; chase it. */
 					duprintf("Jump rule %u -> %u\n",
 						 pos, newpos);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 4585aa7..9340ce0 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -542,13 +542,6 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				if (strcmp(t->target.u.user.name,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
-					if (newpos > newinfo->size -
-						sizeof(struct ipt_entry)) {
-						duprintf("mark_source_chains: "
-							"bad verdict (%i)\n",
-								newpos);
-						return 0;
-					}
 					/* This a jump; chase it. */
 					duprintf("Jump rule %u -> %u\n",
 						 pos, newpos);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index fd06251..aa01085 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -554,13 +554,6 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				if (strcmp(t->target.u.user.name,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
-					if (newpos > newinfo->size -
-						sizeof(struct ip6t_entry)) {
-						duprintf("mark_source_chains: "
-							"bad verdict (%i)\n",
-								newpos);
-						return 0;
-					}
 					/* This a jump; chase it. */
 					duprintf("Jump rule %u -> %u\n",
 						 pos, newpos);
-- 
2.1.4
