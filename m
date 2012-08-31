From: pablo@netfilter.org
Subject: [PATCH 3/6] netfilter: ctnetlink: fix error return code in init path
Date: Fri, 31 Aug 2012 16:03:06 +0200
Message-ID: <1346421789-3449-4-git-send-email-pablo@netfilter.org>
References: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Initialize return variable before exiting on an error path.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}

// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index da4fc37..9807f32 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2790,7 +2790,8 @@ static int __init ctnetlink_init(void)
 		goto err_unreg_subsys;
 	}
 
-	if (register_pernet_subsys(&ctnetlink_net_ops)) {
+	ret = register_pernet_subsys(&ctnetlink_net_ops);
+	if (ret < 0) {
 		pr_err("ctnetlink_init: cannot register pernet operations\n");
 		goto err_unreg_exp_subsys;
 	}
-- 
1.7.10.4

