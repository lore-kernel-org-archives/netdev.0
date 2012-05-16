From: pablo@netfilter.org
Subject: [PATCH 4/7] netfilter: nf_ct_tcp: extend log message for invalid ignored packets
Date: Thu, 17 May 2012 01:06:41 +0200
Message-ID: <1337209604-3412-5-git-send-email-pablo@netfilter.org>
References: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39170 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760753Ab2EPXHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 19:07:23 -0400
In-Reply-To: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Extend log message if packets are ignored to include the TCP state, ie.
replace:

[ 3968.070196] nf_ct_tcp: invalid packet ignored IN= OUT= SRC=...

by:

[ 3968.070196] nf_ct_tcp: invalid packet ignored in state ESTABLISHED IN= OUT= SRC=...

This information is useful to know in what state we were while ignoring the
packet.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 4dfbfa8..21ff1a9 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -952,7 +952,8 @@ static int tcp_packet(struct nf_conn *ct,
 		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
 			nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
-				  "nf_ct_tcp: invalid packet ignored ");
+				  "nf_ct_tcp: invalid packet ignored in "
+				  "state %s ", tcp_conntrack_names[old_state]);
 		return NF_ACCEPT;
 	case TCP_CONNTRACK_MAX:
 		/* Invalid packet */
-- 
1.7.10
