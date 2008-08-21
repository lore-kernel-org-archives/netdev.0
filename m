From: adobriyan@gmail.com
Subject: [PATCH 36/38] netns nat: skip every NOTRACKed connection
Date: Fri, 22 Aug 2008 02:10:25 +0400
Message-ID: <20080821221025.GJ31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/nf_nat_core.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -588,6 +588,10 @@ static int __net_init nf_nat_net_init(struct net *net)
 						      &net->ipv4.nat_vmalloced);
 	if (!net->ipv4.nat_bysource)
 		return -ENOMEM;
+
+	/* Initialize fake conntrack so that NAT will skip it */
+	net->ct.untracked.status |= IPS_NAT_DONE_MASK;
+
 	return 0;
 }
 
@@ -645,9 +649,6 @@ static int __init nf_nat_init(void)
 	rcu_assign_pointer(nf_nat_protos[IPPROTO_ICMP], &nf_nat_protocol_icmp);
 	spin_unlock_bh(&nf_nat_lock);
 
-	/* Initialize fake conntrack so that NAT will skip it */
-	init_net.ct.untracked.status |= IPS_NAT_DONE_MASK;
-
 	l3proto = nf_ct_l3proto_find_get((u_int16_t)AF_INET);
 
 	BUG_ON(nf_nat_seq_adjust_hook != NULL);
-- 
1.5.6.3


