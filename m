From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH v2 1/9] net: core: use this_cpu_ptr per-cpu helper
Date: Sat, 03 Nov 2012 00:01:11 +0800
Message-ID: <5093EE47.20700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	steffen.klassert@secunet.com, NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	cl@linux-foundation.org, Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <davidshan@tencent.com>

Signed-off-by: Shan Wei <davidshan@tencent.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
---
 net/core/flow.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index e318c7e..3bad824 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -327,11 +327,9 @@ static void flow_cache_flush_tasklet(unsigned long data)
 static void flow_cache_flush_per_cpu(void *data)
 {
 	struct flow_flush_info *info = data;
-	int cpu;
 	struct tasklet_struct *tasklet;
 
-	cpu = smp_processor_id();
-	tasklet = &per_cpu_ptr(info->cache->percpu, cpu)->flush_tasklet;
+	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet;
 	tasklet->data = (unsigned long)info;
 	tasklet_schedule(tasklet);
 }
-- 
1.7.1
