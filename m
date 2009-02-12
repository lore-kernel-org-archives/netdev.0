From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/02: fix tuple inversion for Node information request
Date: Thu, 12 Feb 2009 08:07:37 +0100 (MET)
Message-ID: <20090212070734.4876.53101.sendpatchset@x2.localnet>
References: <20090212070732.4876.43180.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090212070732.4876.43180.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 796b5d184b4df1aae55894bf476959da83e25324
Author: Eric Leblond <eric@inl.fr>
Date:   Thu Feb 12 08:00:35 2009 +0100

    netfilter: fix tuple inversion for Node information request
    
    Upstream commit: a51f42f3c
    
    The patch fixes a typo in the inverse mapping of Node Information
    request. Following draft-ietf-ipngwg-icmp-name-lookups-09, "Querier"
    sends a type 139 (ICMPV6_NI_QUERY) packet to "Responder" which answer
    with a type 140 (ICMPV6_NI_REPLY) packet.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 7cd13e5..15caac6 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -49,8 +49,8 @@ static bool icmpv6_pkt_to_tuple(const struct sk_buff *skb,
 static const u_int8_t invmap[] = {
 	[ICMPV6_ECHO_REQUEST - 128]	= ICMPV6_ECHO_REPLY + 1,
 	[ICMPV6_ECHO_REPLY - 128]	= ICMPV6_ECHO_REQUEST + 1,
-	[ICMPV6_NI_QUERY - 128]		= ICMPV6_NI_QUERY + 1,
-	[ICMPV6_NI_REPLY - 128]		= ICMPV6_NI_REPLY +1
+	[ICMPV6_NI_QUERY - 128]		= ICMPV6_NI_REPLY + 1,
+	[ICMPV6_NI_REPLY - 128]		= ICMPV6_NI_QUERY +1
 };
 
 static bool icmpv6_invert_tuple(struct nf_conntrack_tuple *tuple,
