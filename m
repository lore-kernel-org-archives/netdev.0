From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/04: ctnetlink: fix crash during expectation creation
Date: Mon, 16 Mar 2009 17:08:44 +0100 (MET)
Message-ID: <20090316160844.3567.90992.sendpatchset@x2.localnet>
References: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090316160841.3567.94089.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 626ba8fbac9156a94a80be46ffd2f2ce9e4e89a0
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 16 15:50:51 2009 +0100

    netfilter: ctnetlink: fix crash during expectation creation
    
    This patch fixes a possible crash due to the missing initialization
    of the expectation class when nf_ct_expect_related() is called.
    
    Reported-by: BORBELY Zoltan <bozo@andrews.hu>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index cb78aa0..ed6d873 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1780,6 +1780,7 @@ ctnetlink_create_expect(struct nlattr *cda[], u_int8_t u3, u32 pid, int report)
 		goto out;
 	}
 
+	exp->class = 0;
 	exp->expectfn = NULL;
 	exp->flags = 0;
 	exp->master = ct;
