From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/26] netfilter: x_tables: simplify ip{6}table_mangle_hook()
Date: Wed,  6 Jul 2016 16:24:04 +0200
Message-ID: <1467815048-2240-23-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34331 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932316AbcGFO1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:27:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id EF2B117DB6F
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:27:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E0C03EBADB
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:27:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E41566446A
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:56 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for a special case to handle NF_INET_POST_ROUTING, this is
basically the same handling as for prerouting, input, forward.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/iptable_mangle.c  | 4 ----
 net/ipv6/netfilter/ip6table_mangle.c | 4 ----
 2 files changed, 8 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 57fc97c..aebdb33 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -87,10 +87,6 @@ iptable_mangle_hook(void *priv,
 {
 	if (state->hook == NF_INET_LOCAL_OUT)
 		return ipt_mangle_out(skb, state);
-	if (state->hook == NF_INET_POST_ROUTING)
-		return ipt_do_table(skb, state,
-				    state->net->ipv4.iptable_mangle);
-	/* PREROUTING/INPUT/FORWARD: */
 	return ipt_do_table(skb, state, state->net->ipv4.iptable_mangle);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index cb2b288..2b1a9dc 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -83,10 +83,6 @@ ip6table_mangle_hook(void *priv, struct sk_buff *skb,
 {
 	if (state->hook == NF_INET_LOCAL_OUT)
 		return ip6t_mangle_out(skb, state);
-	if (state->hook == NF_INET_POST_ROUTING)
-		return ip6t_do_table(skb, state,
-				     state->net->ipv6.ip6table_mangle);
-	/* INPUT/FORWARD */
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_mangle);
 }
 
-- 
2.1.4
