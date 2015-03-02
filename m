From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: nft_compat: add support for arptables extensions
Date: Mon,  2 Mar 2015 12:43:47 +0100
Message-ID: <1425296627-16391-6-git-send-email-pablo@netfilter.org>
References: <1425296627-16391-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56216 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161AbbCBLl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 06:41:27 -0500
In-Reply-To: <1425296627-16391-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arturo Borrero <arturo.borrero.glez@gmail.com>

This patch adds support to arptables extensions from nft_compat.

Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index c598f74..a990df2 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -20,6 +20,7 @@
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_arp/arp_tables.h>
 #include <net/netfilter/nf_tables.h>
 
 static int nft_compat_chain_validate_dependency(const char *tablename,
@@ -42,6 +43,7 @@ union nft_entry {
 	struct ipt_entry e4;
 	struct ip6t_entry e6;
 	struct ebt_entry ebt;
+	struct arpt_entry arp;
 };
 
 static inline void
@@ -140,6 +142,8 @@ nft_target_set_tgchk_param(struct xt_tgchk_param *par,
 		entry->ebt.ethproto = proto;
 		entry->ebt.invflags = inv ? EBT_IPROTO : 0;
 		break;
+	case NFPROTO_ARP:
+		break;
 	}
 	par->entryinfo	= entry;
 	par->target	= target;
@@ -351,6 +355,8 @@ nft_match_set_mtchk_param(struct xt_mtchk_param *par, const struct nft_ctx *ctx,
 		entry->ebt.ethproto = proto;
 		entry->ebt.invflags = inv ? EBT_IPROTO : 0;
 		break;
+	case NFPROTO_ARP:
+		break;
 	}
 	par->entryinfo	= entry;
 	par->match	= match;
@@ -537,6 +543,9 @@ nfnl_compat_get(struct sock *nfnl, struct sk_buff *skb,
 	case NFPROTO_BRIDGE:
 		fmt = "ebt_%s";
 		break;
+	case NFPROTO_ARP:
+		fmt = "arpt_%s";
+		break;
 	default:
 		pr_err("nft_compat: unsupported protocol %d\n",
 			nfmsg->nfgen_family);
-- 
1.7.10.4
