From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nft_counter: fix erroneous return values
Date: Tue, 16 Feb 2016 18:02:37 +0100
Message-ID: <1455642157-6864-7-git-send-email-pablo@netfilter.org>
References: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Protopopov <a.s.protopopov@gmail.com>

The nft_counter_init() and nft_counter_clone() functions should return
negative error value -ENOMEM instead of positive ENOMEM.

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_counter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index c7808fc..c9743f7 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -100,7 +100,7 @@ static int nft_counter_init(const struct nft_ctx *ctx,
 
 	cpu_stats = netdev_alloc_pcpu_stats(struct nft_counter_percpu);
 	if (cpu_stats == NULL)
-		return ENOMEM;
+		return -ENOMEM;
 
 	preempt_disable();
 	this_cpu = this_cpu_ptr(cpu_stats);
@@ -138,7 +138,7 @@ static int nft_counter_clone(struct nft_expr *dst, const struct nft_expr *src)
 	cpu_stats = __netdev_alloc_pcpu_stats(struct nft_counter_percpu,
 					      GFP_ATOMIC);
 	if (cpu_stats == NULL)
-		return ENOMEM;
+		return -ENOMEM;
 
 	preempt_disable();
 	this_cpu = this_cpu_ptr(cpu_stats);
-- 
2.1.4

