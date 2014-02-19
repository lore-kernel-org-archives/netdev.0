From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nft_meta: fix typo "CONFIG_NET_CLS_ROUTE"
Date: Wed, 19 Feb 2014 12:41:38 +0100
Message-ID: <1392810102-13877-3-git-send-email-pablo@netfilter.org>
References: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44986 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811AbaBSLlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 06:41:55 -0500
In-Reply-To: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>

There are two checks for CONFIG_NET_CLS_ROUTE, but the corresponding
Kconfig symbol was dropped in v2.6.39. Since the code guards access to
dst_entry.tclassid it seems CONFIG_IP_ROUTE_CLASSID should be used
instead.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_meta.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index e8254ad..425cf39 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -116,7 +116,7 @@ static void nft_meta_get_eval(const struct nft_expr *expr,
 				 skb->sk->sk_socket->file->f_cred->fsgid);
 		read_unlock_bh(&skb->sk->sk_callback_lock);
 		break;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	case NFT_META_RTCLASSID: {
 		const struct dst_entry *dst = skb_dst(skb);
 
@@ -199,7 +199,7 @@ static int nft_meta_init_validate_get(uint32_t key)
 	case NFT_META_OIFTYPE:
 	case NFT_META_SKUID:
 	case NFT_META_SKGID:
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	case NFT_META_RTCLASSID:
 #endif
 #ifdef CONFIG_NETWORK_SECMARK
-- 
1.7.10.4
