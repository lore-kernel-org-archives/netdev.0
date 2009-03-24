From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/41: log invalid new icmpv6 packet with nf_log_packet()
Date: Tue, 24 Mar 2009 15:03:14 +0100 (MET)
Message-ID: <20090324140310.31401.69352.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757315AbZCXODQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:16 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 55df4ac0c927c7f1f84e6d75532f0ca45d391e64
Author: Eric Leblond <eric@inl.fr>
Date:   Wed Feb 18 16:30:56 2009 +0100

    netfilter: log invalid new icmpv6 packet with nf_log_packet()
    
    This patch adds a logging message for invalid new icmpv6 packet.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index c323643..165b256 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -126,6 +126,10 @@ static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
 		pr_debug("icmpv6: can't create new conn with type %u\n",
 			 type + 128);
 		nf_ct_dump_tuple_ipv6(&ct->tuplehash[0].tuple);
+		if (LOG_INVALID(nf_ct_net(ct), IPPROTO_ICMPV6))
+			nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
+				      "nf_ct_icmpv6: invalid new with type %d ",
+				      type + 128);
 		return false;
 	}
 	atomic_set(&ct->proto.icmp.count, 0);
