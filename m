From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] netfilter: ipv6: nf_defrag: constify nf_hook_ops
Date: Sat, 26 Aug 2017 16:12:50 +0530
Message-ID: <02532da07efae2110ccf47724ee5670533fa3d60.1503743910.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_hook_ops are not supposed to change at runtime. nf_register_net_hooks
and nf_unregister_net_hooks are working with const nf_hook_ops.
So mark the non-const nf_hook_ops structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index ada60d1..b326da5 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -74,7 +74,7 @@ static unsigned int ipv6_defrag(void *priv,
 	return err == 0 ? NF_ACCEPT : NF_DROP;
 }
 
-static struct nf_hook_ops ipv6_defrag_ops[] = {
+static const struct nf_hook_ops ipv6_defrag_ops[] = {
 	{
 		.hook		= ipv6_defrag,
 		.pf		= NFPROTO_IPV6,
-- 
2.7.4
