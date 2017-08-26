From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] netfilter: ipv4: nf_defrag: constify nf_hook_ops
Date: Sat, 26 Aug 2017 16:11:04 +0530
Message-ID: <7859bbf3c48bf4dc16bc3e55067e01f72aceb71f.1503743850.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_hook_ops are not supposed to change at runtime. nf_register_net_hooks
and nf_unregister_net_hooks are working with const nf_hook_ops.
So mark the non-const nf_hook_ops structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 346bf7c..37fe1616 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -90,7 +90,7 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
 	return NF_ACCEPT;
 }
 
-static struct nf_hook_ops ipv4_defrag_ops[] = {
+static const struct nf_hook_ops ipv4_defrag_ops[] = {
 	{
 		.hook		= ipv4_conntrack_defrag,
 		.pf		= NFPROTO_IPV4,
-- 
2.7.4

