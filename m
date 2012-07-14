From: Valentin Ilie <valentin.ilie@gmail.com>
Subject: [PATCH V2] drivers: connector: fixed coding style issues
Date: Sun, 15 Jul 2012 02:08:29 +0300
Message-ID: <1342307309-8280-1-git-send-email-valentin.ilie@gmail.com>
References: <1342297608-6872-1-git-send-email-valentin.ilie@gmail.com>
Cc: netdev@vger.kernel.org, Valentin Ilie <valentin.ilie@gmail.com>
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48122 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab2GNXJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 19:09:05 -0400
Received: by wgbdr13 with SMTP id dr13so4187946wgb.1
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2012 16:09:04 -0700 (PDT)
In-Reply-To: <1342297608-6872-1-git-send-email-valentin.ilie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2: Replaced assignment in if statement.
Fixed coding style issues.

Signed-off-by: Valentin Ilie <valentin.ilie@gmail.com>
---
 drivers/connector/cn_proc.c   |   36 ++++++++++++++++++------------------
 drivers/connector/cn_queue.c  |   12 +++++++-----
 drivers/connector/connector.c |    5 +++--
 3 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index 77e1e6c..3e92b7d 100644
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
@@ -325,11 +325,11 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
  */
 static int __init cn_proc_init(void)
 {
-	int err;
-
-	if ((err = cn_add_callback(&cn_proc_event_id, "cn_proc",
-	 			   &cn_proc_mcast_ctl))) {
-		printk(KERN_WARNING "cn_proc failed to register\n");
+	int err = cn_add_callback(&cn_proc_event_id,
+				  "cn_proc",
+				  &cn_proc_mcast_ctl);
+	if (err) {
+		pr_warn("cn_proc failed to register\n");
 		return err;
 	}
 	return 0;
diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index c42c9d5..1f8bf05 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -1,5 +1,5 @@
 /*
- * 	cn_queue.c
+ *	cn_queue.c
  *
  * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
  * All rights reserved.
@@ -34,13 +34,14 @@
 static struct cn_callback_entry *
 cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
 			      struct cb_id *id,
-			      void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
+			      void (*callback)(struct cn_msg *,
+					       struct netlink_skb_parms *))
 {
 	struct cn_callback_entry *cbq;
 
 	cbq = kzalloc(sizeof(*cbq), GFP_KERNEL);
 	if (!cbq) {
-		printk(KERN_ERR "Failed to create new callback queue.\n");
+		pr_err("Failed to create new callback queue.\n");
 		return NULL;
 	}
 
@@ -71,7 +72,8 @@ int cn_cb_equal(struct cb_id *i1, struct cb_id *i2)
 
 int cn_queue_add_callback(struct cn_queue_dev *dev, const char *name,
 			  struct cb_id *id,
-			  void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
+			  void (*callback)(struct cn_msg *,
+					   struct netlink_skb_parms *))
 {
 	struct cn_callback_entry *cbq, *__cbq;
 	int found = 0;
@@ -149,7 +151,7 @@ void cn_queue_free_dev(struct cn_queue_dev *dev)
 	spin_unlock_bh(&dev->queue_lock);
 
 	while (atomic_read(&dev->refcnt)) {
-		printk(KERN_INFO "Waiting for %s to become free: refcnt=%d.\n",
+		pr_info("Waiting for %s to become free: refcnt=%d.\n",
 		       dev->name, atomic_read(&dev->refcnt));
 		msleep(1000);
 	}
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index dde6a0f..32174f0 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -1,5 +1,5 @@
 /*
- * 	connector.c
+ *	connector.c
  *
  * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
  * All rights reserved.
@@ -185,7 +185,8 @@ static void cn_rx_skb(struct sk_buff *__skb)
  * May sleep.
  */
 int cn_add_callback(struct cb_id *id, const char *name,
-		    void (*callback)(struct cn_msg *, struct netlink_skb_parms *))
+		    void (*callback)(struct cn_msg *,
+				     struct netlink_skb_parms *))
 {
 	int err;
 	struct cn_dev *dev = &cdev;
-- 
1.7.10.4
