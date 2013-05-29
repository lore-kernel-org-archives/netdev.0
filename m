From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] ipvs: ip_vs_sh: fix build
Date: Wed, 29 May 2013 18:03:13 +0200
Message-ID: <1369843394-24251-6-git-send-email-pablo@netfilter.org>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Beulich <JBeulich@suse.com>

kfree_rcu() requires offsetof(..., rcu_head) < 4096, which can
get violated with a sufficiently high CONFIG_IP_VS_SH_TAB_BITS.

Signed-off-by: Jan Beulich <jbeulich@suse.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_sh.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 0df269d..a65edfe4 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -67,8 +67,8 @@ struct ip_vs_sh_bucket {
 #define IP_VS_SH_TAB_MASK               (IP_VS_SH_TAB_SIZE - 1)
 
 struct ip_vs_sh_state {
-	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
 	struct rcu_head			rcu_head;
+	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
 };
 
 /*
-- 
1.7.10.4

