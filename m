From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/07: fix compilation error with NAT=n
Date: Mon, 20 Oct 2008 11:54:16 +0200 (MEST)
Message-ID: <20081020095416.25670.24763.sendpatchset@x2.localnet>
References: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4cad11733aa8e182d7cfe39f9983940f2a7d0dc3
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Oct 20 11:47:30 2008 +0200

    netfilter: fix compilation error with NAT=n
    
    This patch fixes the compilation of ctnetlink when the NAT support
    is not enabled.
    
    /home/benh/kernels/linux-powerpc/net/netfilter/nf_conntrack_netlink.c:819: warning: enum nf_nat_manip_type\u2019 declared inside parameter list
    /home/benh/kernels/linux-powerpc/net/netfilter/nf_conntrack_netlink.c:819: warning: its scope is only this definition or declaration, which is probably not what you want
    
    Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
    Reported by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2e4ad96..a040d46 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -813,6 +813,7 @@ out:
 	return err;
 }
 
+#ifdef CONFIG_NF_NAT_NEEDED
 static int
 ctnetlink_parse_nat_setup(struct nf_conn *ct,
 			  enum nf_nat_manip_type manip,
@@ -840,6 +841,7 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 
 	return parse_nat_setup(ct, manip, attr);
 }
+#endif
 
 static int
 ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
