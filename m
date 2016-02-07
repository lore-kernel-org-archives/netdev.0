From: Anton Protopopov <a.s.protopopov@gmail.com>
Subject: [PATCH] netfilter: nft_counter: fix erroneous return values
Date: Sat,  6 Feb 2016 23:31:19 -0500
Message-ID: <1454819479-6833-1-git-send-email-a.s.protopopov@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anton Protopopov <a.s.protopopov@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nft_counter_init() and nft_counter_clone() functions should return
negative error value -ENOMEM instead of positive ENOMEM.

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
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
