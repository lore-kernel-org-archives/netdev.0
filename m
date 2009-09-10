From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 22/31: nf_nat: fix inverted logic for persistent NAT mappings
Date: Thu, 10 Sep 2009 18:12:15 +0200 (MEST)
Message-ID: <20090910161210.31179.59980.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit cce5a5c3029f731b5ea17a8a9a953ff742abf0d6
Author: Maximilian Engelhardt <maxi@daemonizer.de>
Date:   Mon Aug 24 19:24:54 2009 +0200

    netfilter: nf_nat: fix inverted logic for persistent NAT mappings
    
    Kernel 2.6.30 introduced a patch [1] for the persistent option in the
    netfilter SNAT target. This is exactly what we need here so I had a quick look
    at the code and noticed that the patch is wrong. The logic is simply inverted.
    The patch below fixes this.
    
    Also note that because of this the default behavior of the SNAT target has
    changed since kernel 2.6.30 as it now ignores the destination IP in choosing
    the source IP for nating (which should only be the case if the persistent
    option is set).
    
    [1] http://git.eu.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=98d500d66cb7940747b424b245fc6a51ecfbf005
    
    Signed-off-by: Maximilian Engelhardt <maxi@daemonizer.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 3229e0a..b6ddd56 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -212,7 +212,7 @@ find_best_ips_proto(struct nf_conntrack_tuple *tuple,
 	maxip = ntohl(range->max_ip);
 	j = jhash_2words((__force u32)tuple->src.u3.ip,
 			 range->flags & IP_NAT_RANGE_PERSISTENT ?
-				(__force u32)tuple->dst.u3.ip : 0, 0);
+				0 : (__force u32)tuple->dst.u3.ip, 0);
 	j = ((u64)j * (maxip - minip + 1)) >> 32;
 	*var_ipp = htonl(minip + j);
 }
