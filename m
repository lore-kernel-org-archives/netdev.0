From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 1/2] sched: introduce nr_running_this_cpu()
Date: Thu, 21 Aug 2014 16:05:09 +0800
Message-ID: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces a helper nr_running_this_cpu() to return the
number of runnable processes in current cpu.

The first user will be net rx busy polling. It will use this to exit
the busy loop when it finds more than one processes is runnable in
current cpu. This can give us better performance of busy polling under
heavy load.

Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/sched.h | 1 +
 kernel/sched/core.c   | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5c2c885..e34020a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -167,6 +167,7 @@ extern int nr_threads;
 DECLARE_PER_CPU(unsigned long, process_counts);
 extern int nr_processes(void);
 extern unsigned long nr_running(void);
+extern unsigned long nr_running_this_cpu(void);
 extern unsigned long nr_iowait(void);
 extern unsigned long nr_iowait_cpu(int cpu);
 extern void get_iowait_load(unsigned long *nr_waiters, unsigned long *load);
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index ec1a286..87fa7b5 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2366,6 +2366,12 @@ unsigned long nr_running(void)
 	return sum;
 }
 
+unsigned long nr_running_this_cpu(void)
+{
+	return this_rq()->nr_running;
+}
+EXPORT_SYMBOL(nr_running_this_cpu);
+
 unsigned long long nr_context_switches(void)
 {
 	int i;
-- 
1.8.3.1
