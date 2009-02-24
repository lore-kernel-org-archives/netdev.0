From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/06: nf_conntrack_ipv6: fix nf_log_packet message in icmpv6 conntrack
Date: Tue, 24 Feb 2009 15:52:45 +0100 (MET)
Message-ID: <20090224145244.9789.94103.sendpatchset@x2.localnet>
References: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4aa3b2ee1945ed082430ae1fb988d60eef64ca07
Author: Eric Leblond <eric@inl.fr>
Date:   Wed Feb 18 15:28:46 2009 +0100

    netfilter: nf_conntrack_ipv6: fix nf_log_packet message in icmpv6 conntrack
    
    This patch fixes a trivial typo that was adding a new line at end of
    the nf_log_packet() prefix. It also make the logging conditionnal by
    adding a LOG_INVALID test.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index c323643..72dbb6d 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -201,8 +201,9 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 
 	if (net->ct.sysctl_checksum && hooknum == NF_INET_PRE_ROUTING &&
 	    nf_ip6_checksum(skb, hooknum, dataoff, IPPROTO_ICMPV6)) {
-		nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
-			      "nf_ct_icmpv6: ICMPv6 checksum failed\n");
+		if (LOG_INVALID(net, IPPROTO_ICMPV6))
+			nf_log_packet(PF_INET6, 0, skb, NULL, NULL, NULL,
+				      "nf_ct_icmpv6: ICMPv6 checksum failed ");
 		return -NF_ACCEPT;
 	}
 
