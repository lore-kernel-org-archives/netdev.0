From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Fix more per-cpu typos
Date: Wed, 2 Aug 2006 03:23:33 +0400
Message-ID: <20060801232333.GC14863@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:61988 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750732AbWHAXXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 19:23:37 -0400
Received: by ug-out-1314.google.com with SMTP id m3so2249ugc
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2006 16:23:35 -0700 (PDT)
To: netdev@vger.kernel.org, Andi Kleen <ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/x86_64/kernel/smp.c |    2 +-
 include/net/netdma.h     |    2 +-
 net/core/dev.c           |    4 ++--
 net/ipv4/tcp.c           |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

--- a/arch/x86_64/kernel/smp.c
+++ b/arch/x86_64/kernel/smp.c
@@ -203,7 +203,7 @@ int __cpuinit init_smp_flush(void)
 {
 	int i;
 	for_each_cpu_mask(i, cpu_possible_map) {
-		spin_lock_init(&per_cpu(flush_state.tlbstate_lock, i));
+		spin_lock_init(&per_cpu(flush_state, i).tlbstate_lock);
 	}
 	return 0;
 }
--- a/include/net/netdma.h
+++ b/include/net/netdma.h
@@ -29,7 +29,7 @@ static inline struct dma_chan *get_softn
 {
 	struct dma_chan *chan;
 	rcu_read_lock();
-	chan = rcu_dereference(__get_cpu_var(softnet_data.net_dma));
+	chan = rcu_dereference(__get_cpu_var(softnet_data).net_dma);
 	if (chan)
 		dma_chan_get(chan);
 	rcu_read_unlock();
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3433,7 +3433,7 @@ static void net_dma_rebalance(void)
 
 	if (net_dma_count == 0) {
 		for_each_online_cpu(cpu)
-			rcu_assign_pointer(per_cpu(softnet_data.net_dma, cpu), NULL);
+			rcu_assign_pointer(per_cpu(softnet_data, cpu).net_dma, NULL);
 		unlock_cpu_hotplug();
 		return;
 	}
@@ -3447,7 +3447,7 @@ static void net_dma_rebalance(void)
 		   + (i < (num_online_cpus() % net_dma_count) ? 1 : 0));
 
 		while(n) {
-			per_cpu(softnet_data.net_dma, cpu) = chan;
+			per_cpu(softnet_data, cpu).net_dma = chan;
 			cpu = next_cpu(cpu, cpu_online_map);
 			n--;
 		}
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1132,7 +1132,7 @@ #ifdef CONFIG_NET_DMA
 	tp->ucopy.dma_chan = NULL;
 	preempt_disable();
 	if ((len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
-	    !sysctl_tcp_low_latency && __get_cpu_var(softnet_data.net_dma)) {
+	    !sysctl_tcp_low_latency && __get_cpu_var(softnet_data).net_dma) {
 		preempt_enable_no_resched();
 		tp->ucopy.pinned_list = dma_pin_iovec_pages(msg->msg_iov, len);
 	} else

