From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/3] netfilter: nf_conntrack_dccp: use %s format string for buffer
Date: Wed,  8 Jan 2014 20:13:23 +0100
Message-ID: <1389208404-3956-3-git-send-email-pablo@netfilter.org>
References: <1389208404-3956-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54767 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756008AbaAHTNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 14:13:42 -0500
In-Reply-To: <1389208404-3956-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

Some invocations of nf_log_packet() use arg buffer directly instead of
"%s" format string with follow-up buffer pointer. Currently, these two
usages are not really critical, but we should fix this up nevertheless
so that we don't run into trouble if that changes one day.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_dccp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a99b6c3..3841268 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -457,7 +457,7 @@ static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 out_invalid:
 	if (LOG_INVALID(net, IPPROTO_DCCP))
 		nf_log_packet(net, nf_ct_l3num(ct), 0, skb, NULL, NULL,
-			      NULL, msg);
+			      NULL, "%s", msg);
 	return false;
 }
 
@@ -614,7 +614,7 @@ static int dccp_error(struct net *net, struct nf_conn *tmpl,
 
 out_invalid:
 	if (LOG_INVALID(net, IPPROTO_DCCP))
-		nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL, msg);
+		nf_log_packet(net, pf, 0, skb, NULL, NULL, NULL, "%s", msg);
 	return -NF_ACCEPT;
 }
 
-- 
1.7.10.4
