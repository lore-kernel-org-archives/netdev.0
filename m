From: Valentin Ilie <valentin.ilie@gmail.com>
Subject: [PATCH] drivers: connector: fixed coding style issues
Date: Sat, 14 Jul 2012 23:26:48 +0300
Message-ID: <1342297608-6872-1-git-send-email-valentin.ilie@gmail.com>
Cc: netdev@vger.kernel.org, Valentin Ilie <valentin.ilie@gmail.com>
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62042 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab2GNU07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 16:26:59 -0400
Received: by weyx8 with SMTP id x8so3187965wey.19
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2012 13:26:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed checkpatch warnings.

Signed-off-by: Valentin Ilie <valentin.ilie@gmail.com>
---
 drivers/connector/cn_proc.c   |   30 +++++++++++++++---------------
 drivers/connector/cn_queue.c  |    6 +++---
 drivers/connector/connector.c |    2 +-
 3 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 77e1e6c..a76801c 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -46,7 +46,7 @@ static DEFINE_PER_CPU(__u32, proc_event_counts) = { 0 };
 static inline void get_seq(__u32 *ts, int *cpu)
 {
 	preempt_disable();
-	*ts = __this_cpu_inc_return(proc_event_counts) -1;
+	*ts = __this_cpu_inc_return(proc_event_counts) - 1;
 	*cpu = smp_processor_id();
 	preempt_enable();
 }
@@ -62,8 +62,8 @@ void proc_fork_connector(struct task_struct *task)
 	if (atomic_read(&proc_event_num_listeners) < 1)
 		return;
 
-	msg = (struct cn_msg*)buffer;
-	ev = (struct proc_event*)msg->data;
+	msg = (struct cn_msg *)buffer;
+	ev = (struct proc_event *)msg->data;
 	get_seq(&msg->seq, &ev->cpu);
 	ktime_get_ts(&ts); /* get high res monotonic timestamp */
 	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
@@ -93,8 +93,8 @@ void proc_exec_connector(struct task_struct *task)
 	if (atomic_read(&proc_event_num_listeners) < 1)
 		return;
 
-	msg = (struct cn_msg*)buffer;
-	ev = (struct proc_event*)msg->data;
+	msg = (struct cn_msg *)buffer;
+	ev = (struct proc_event *)msg->data;
 	get_seq(&msg->seq, &ev->cpu);
 	ktime_get_ts(&ts); /* get high res monotonic timestamp */
 	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
@@ -119,8 +119,8 @@ void proc_id_connector(struct task_struct *task, int which_id)
 	if (atomic_read(&proc_event_num_listeners) < 1)
 		return;
 
-	msg = (struct cn_msg*)buffer;
-	ev = (struct proc_event*)msg->data;
+	msg = (struct cn_msg *)buffer;
+	ev = (struct proc_event *)msg->data;
 	ev->what = which_id;
 	ev->event_data.id.process_pid = task->pid;
 	ev->event_data.id.process_tgid = task->tgid;
@@ -134,7 +134,7 @@ void proc_id_connector(struct task_struct *task, int which_id)
 		ev->event_data.id.e.egid = cred->egid;
 	} else {
 		rcu_read_unlock();
-	     	return;
+		return;
 	}
 	rcu_read_unlock();
 	get_seq(&msg->seq, &ev->cpu);
@@ -241,8 +241,8 @@ void proc_exit_connector(struct task_struct *task)
 	if (atomic_read(&proc_event_num_listeners) < 1)
 		return;
 
-	msg = (struct cn_msg*)buffer;
-	ev = (struct proc_event*)msg->data;
+	msg = (struct cn_msg *)buffer;
+	ev = (struct proc_event *)msg->data;
 	get_seq(&msg->seq, &ev->cpu);
 	ktime_get_ts(&ts); /* get high res monotonic timestamp */
 	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
@@ -276,8 +276,8 @@ static void cn_proc_ack(int err, int rcvd_seq, int rcvd_ack)
 	if (atomic_read(&proc_event_num_listeners) < 1)
 		return;
 
-	msg = (struct cn_msg*)buffer;
-	ev = (struct proc_event*)msg->data;
+	msg = (struct cn_msg *)buffer;
+	ev = (struct proc_event *)msg->data;
 	msg->seq = rcvd_seq;
 	ktime_get_ts(&ts); /* get high res monotonic timestamp */
 	put_unaligned(timespec_to_ns(&ts), (__u64 *)&ev->timestamp_ns);
@@ -303,7 +303,7 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
 	if (msg->len != sizeof(*mc_op))
 		return;
 
-	mc_op = (enum proc_cn_mcast_op*)msg->data;
+	mc_op = (enum proc_cn_mcast_op *)msg->data;
 	switch (*mc_op) {
 	case PROC_CN_MCAST_LISTEN:
 		atomic_inc(&proc_event_num_listeners);
@@ -328,8 +328,8 @@ static int __init cn_proc_init(void)
 	int err;
 
 	if ((err = cn_add_callback(&cn_proc_event_id, "cn_proc",
-	 			   &cn_proc_mcast_ctl))) {
-		printk(KERN_WARNING "cn_proc failed to register\n");
+					&cn_proc_mcast_ctl))) {
+		pr_warn("cn_proc failed to register\n");
 		return err;
 	}
 	return 0;
diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index c42c9d5..cd3bd7d 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -1,5 +1,5 @@
 /*
- * 	cn_queue.c
+ *	cn_queue.c
  *
  * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
  * All rights reserved.
@@ -40,7 +40,7 @@ cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
 
 	cbq = kzalloc(sizeof(*cbq), GFP_KERNEL);
 	if (!cbq) {
-		printk(KERN_ERR "Failed to create new callback queue.\n");
+		pr_err("Failed to create new callback queue.\n");
 		return NULL;
 	}
 
@@ -149,7 +149,7 @@ void cn_queue_free_dev(struct cn_queue_dev *dev)
 	spin_unlock_bh(&dev->queue_lock);
 
 	while (atomic_read(&dev->refcnt)) {
-		printk(KERN_INFO "Waiting for %s to become free: refcnt=%d.\n",
+		pr_info("Waiting for %s to become free: refcnt=%d.\n",
 		       dev->name, atomic_read(&dev->refcnt));
 		msleep(1000);
 	}
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index dde6a0f..36e89ae 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -1,5 +1,5 @@
 /*
- * 	connector.c
+ *	connector.c
  *
  * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
  * All rights reserved.
-- 
1.7.10.4
