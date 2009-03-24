From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 19/41: nf_conntrack: account packets drop by tcp_packet()
Date: Tue, 24 Mar 2009 15:03:32 +0100 (MET)
Message-ID: <20090324140328.31401.90560.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 7d1e04598e5e92527840b6889fb75b4b30fdd33b
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Feb 24 14:48:01 2009 +0100

    netfilter: nf_conntrack: account packets drop by tcp_packet()
    
    Since tcp_packet() may return -NF_DROP in two situations, the
    packet-drop stats must be increased.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 2235432..ebc2756 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -734,6 +734,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		nf_conntrack_put(skb->nfct);
 		skb->nfct = NULL;
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
+		if (ret == -NF_DROP)
+			NF_CT_STAT_INC_ATOMIC(net, drop);
 		return -ret;
 	}
 
