From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2]: softirq: Define and use NR_SOFTIRQ
Date: Fri, 19 Sep 2008 23:48:27 -0700 (PDT)
Message-ID: <20080919.234827.23142568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35479
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751065AbYITGsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 02:48:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


softirq: Define and use NR_SOFTIRQ

The softirq tables use a magic value "32" for sizing.

Define a proper NR_SOFTIRQ value instead.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/interrupt.h |    1 +
 kernel/softirq.c          |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 58ff4e7..fdd7b90 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -252,6 +252,7 @@ enum
 	HRTIMER_SOFTIRQ,
 #endif
 	RCU_SOFTIRQ, 	/* Preferable RCU should always be the last softirq */
+	NR_SOFTIRQ
 };
 
 /* softirq mask and active fields moved to irq_cpustat_t in
diff --git a/kernel/softirq.c b/kernel/softirq.c
index c506f26..27642a2 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -46,7 +46,7 @@ irq_cpustat_t irq_stat[NR_CPUS] ____cacheline_aligned;
 EXPORT_SYMBOL(irq_stat);
 #endif
 
-static struct softirq_action softirq_vec[32] __cacheline_aligned_in_smp;
+static struct softirq_action softirq_vec[NR_SOFTIRQ] __cacheline_aligned_in_smp;
 
 static DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
 
-- 
1.5.6.5

