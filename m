From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 12/29: ctnetlink: use nf_conntrack_get instead of atomic_inc
Date: Thu, 27 Nov 2008 17:15:19 +0100 (MET)
Message-ID: <20081127161519.13891.13341.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 238ede8160443a32379fd8f9eb88d00456a09bb4
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Nov 17 15:53:33 2008 +0100

    netfilter: ctnetlink: use nf_conntrack_get instead of atomic_inc
    
    Use nf_conntrack_get instead of the direct call to atomic_inc.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a040d46..80a3f13 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1209,7 +1209,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 				goto out_unlock;
 			}
 			master_ct = nf_ct_tuplehash_to_ctrack(master_h);
-			atomic_inc(&master_ct->ct_general.use);
+			nf_conntrack_get(&master_ct->ct_general);
 		}
 
 		spin_unlock_bh(&nf_conntrack_lock);
