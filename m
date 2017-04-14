From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 9/9] netfilter: ipt_CLUSTERIP: Fix wrong conntrack netns refcnt usage
Date: Fri, 14 Apr 2017 02:26:51 +0200
Message-ID: <1492129611-29336-10-git-send-email-pablo@netfilter.org>
References: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

Current codes invoke wrongly nf_ct_netns_get in the destroy routine,
it should use nf_ct_netns_put, not nf_ct_netns_get.
It could cause some modules could not be unloaded.

Fixes: ecb2421b5ddf ("netfilter: add and use nf_ct_netns_get/put")
Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 52f26459efc3..9b8841316e7b 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -461,7 +461,7 @@ static void clusterip_tg_destroy(const struct xt_tgdtor_param *par)
 
 	clusterip_config_put(cipinfo->config);
 
-	nf_ct_netns_get(par->net, par->family);
+	nf_ct_netns_put(par->net, par->family);
 }
 
 #ifdef CONFIG_COMPAT
-- 
2.1.4

