From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/05: fix tuple inversion for Node information request
Date: Mon,  9 Feb 2009 17:39:28 +0100 (MET)
Message-ID: <20090209163927.13918.28969.sendpatchset@x2.localnet>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 21c87b35badcae15fe48335bd5985c9fb3d152c8
Author: Eric Leblond <eric@inl.fr>
Date:   Mon Feb 9 14:24:43 2009 +0100

    netfilter: fix tuple inversion for Node information request
    
    The patch fixes a typo in the inverse mapping of Node Information
    request. Following draft-ietf-ipngwg-icmp-name-lookups-09, "Querier"
    sends a type 139 (ICMPV6_NI_QUERY) packet to "Responder" which answer
    with a type 140 (ICMPV6_NI_REPLY) packet.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index c455cf4..114a92e 100644
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
