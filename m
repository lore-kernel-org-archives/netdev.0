From: kaber@trash.net
Subject: [PATCH 07/37] netfilter:ipvs: use kmemdup
Date: Tue, 15 Mar 2011 20:43:47 +0100
Message-ID: <1300218257-26953-8-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49427 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758434Ab1COTo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:27 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

The semantic patch that makes this output is available
in scripts/coccinelle/api/memdup.cocci.

More information about semantic patching is available at
http://coccinelle.lip6.fr/

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c |    9 ++++-----
 net/netfilter/ipvs/ip_vs_sync.c   |    3 +--
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 0d83bc0..13d607a 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -92,14 +92,13 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
 		return -EINVAL;
 
-	p->pe_data = kmalloc(matchlen, GFP_ATOMIC);
-	if (!p->pe_data)
-		return -ENOMEM;
-
 	/* N.B: pe_data is only set on success,
 	 * this allows fallback to the default persistence logic on failure
 	 */
-	memcpy(p->pe_data, dptr + matchoff, matchlen);
+	p->pe_data = kmemdup(dptr + matchoff, matchlen, GFP_ATOMIC);
+	if (!p->pe_data)
+		return -ENOMEM;
+
 	p->pe_data_len = matchlen;
 
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index fecf24d..c5d13b0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -697,13 +697,12 @@ ip_vs_conn_fill_param_sync(struct net *net, int af, union ip_vs_sync_conn *sc,
 			return 1;
 		}
 
-		p->pe_data = kmalloc(pe_data_len, GFP_ATOMIC);
+		p->pe_data = kmemdup(pe_data, pe_data_len, GFP_ATOMIC);
 		if (!p->pe_data) {
 			if (p->pe->module)
 				module_put(p->pe->module);
 			return -ENOMEM;
 		}
-		memcpy(p->pe_data, pe_data, pe_data_len);
 		p->pe_data_len = pe_data_len;
 	}
 	return 0;
-- 
1.7.2.3

