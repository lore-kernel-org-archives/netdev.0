From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 26/41: conntrack: increase drop stats if sequence adjustment fails
Date: Tue, 24 Mar 2009 15:03:41 +0100 (MET)
Message-ID: <20090324140337.31401.64697.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 1db7a748dfd50d7615913730763c024444900030
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 16 15:18:50 2009 +0100

    netfilter: conntrack: increase drop stats if sequence adjustment fails
    
    This patch increases the statistics of packets drop if the sequence
    adjustment fails in ipv4_confirm().
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 4beb04f..8b681f2 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -120,8 +120,10 @@ static unsigned int ipv4_confirm(unsigned int hooknum,
 		typeof(nf_nat_seq_adjust_hook) seq_adjust;
 
 		seq_adjust = rcu_dereference(nf_nat_seq_adjust_hook);
-		if (!seq_adjust || !seq_adjust(skb, ct, ctinfo))
+		if (!seq_adjust || !seq_adjust(skb, ct, ctinfo)) {
+			NF_CT_STAT_INC_ATOMIC(nf_ct_net(ct), drop);
 			return NF_DROP;
+		}
 	}
 out:
 	/* We've seen it coming out the other side: confirm it */
