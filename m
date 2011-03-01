From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] vhost: Cleanup vhost.c and net.c
Date: Tue, 01 Mar 2011 17:06:37 +0530
Message-ID: <20110301113637.4130.38439.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:54058 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756197Ab1CALgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 06:36:43 -0500
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p21BVWTl012876
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 22:31:32 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p21BadiL2306080
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 22:36:39 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p21BadEl003765
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 22:36:39 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor cleanup of vhost.c and net.c to match coding style.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/vhost/net.c   |   19 +++++++++-----
 drivers/vhost/vhost.c |   53 +++++++++++++++++++++++++++-------------
 2 files changed, 49 insertions(+), 23 deletions(-)

diff -ruNp org/drivers/vhost/net.c new/drivers/vhost/net.c
--- org/drivers/vhost/net.c	2011-03-01 13:33:25.000000000 +0530
+++ new/drivers/vhost/net.c	2011-03-01 13:36:44.000000000 +0530
@@ -60,6 +60,7 @@ static int move_iovec_hdr(struct iovec *
 {
 	int seg = 0;
 	size_t size;
+
 	while (len && seg < iov_count) {
 		size = min(from->iov_len, len);
 		to->iov_base = from->iov_base;
@@ -79,6 +80,7 @@ static void copy_iovec_hdr(const struct 
 {
 	int seg = 0;
 	size_t size;
+
 	while (len && seg < iovcount) {
 		size = min(from->iov_len, len);
 		to->iov_base = from->iov_base;
@@ -296,17 +298,16 @@ static void handle_rx_big(struct vhost_n
 		.msg_iov = vq->iov,
 		.msg_flags = MSG_DONTWAIT,
 	};
-
 	struct virtio_net_hdr hdr = {
 		.flags = 0,
 		.gso_type = VIRTIO_NET_HDR_GSO_NONE
 	};
-
 	size_t len, total_len = 0;
 	int err;
 	size_t hdr_size;
 	/* TODO: check that we are running from vhost_worker? */
 	struct socket *sock = rcu_dereference_check(vq->private_data, 1);
+
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
@@ -405,18 +406,17 @@ static void handle_rx_mergeable(struct v
 		.msg_iov = vq->iov,
 		.msg_flags = MSG_DONTWAIT,
 	};
-
 	struct virtio_net_hdr_mrg_rxbuf hdr = {
 		.hdr.flags = 0,
 		.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE
 	};
-
 	size_t total_len = 0;
 	int err, headcount;
 	size_t vhost_hlen, sock_hlen;
 	size_t vhost_len, sock_len;
 	/* TODO: check that we are running from vhost_worker? */
 	struct socket *sock = rcu_dereference_check(vq->private_data, 1);
+
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
@@ -654,6 +654,7 @@ static struct socket *get_raw_socket(int
 	} uaddr;
 	int uaddr_len = sizeof uaddr, r;
 	struct socket *sock = sockfd_lookup(fd, &r);
+
 	if (!sock)
 		return ERR_PTR(-ENOTSOCK);
 
@@ -682,6 +683,7 @@ static struct socket *get_tap_socket(int
 {
 	struct file *file = fget(fd);
 	struct socket *sock;
+
 	if (!file)
 		return ERR_PTR(-EBADF);
 	sock = tun_get_socket(file);
@@ -696,6 +698,7 @@ static struct socket *get_tap_socket(int
 static struct socket *get_socket(int fd)
 {
 	struct socket *sock;
+
 	/* special case to disable backend */
 	if (fd == -1)
 		return NULL;
@@ -741,9 +744,9 @@ static long vhost_net_set_backend(struct
 	oldsock = rcu_dereference_protected(vq->private_data,
 					    lockdep_is_held(&vq->mutex));
 	if (sock != oldsock) {
-                vhost_net_disable_vq(n, vq);
-                rcu_assign_pointer(vq->private_data, sock);
-                vhost_net_enable_vq(n, vq);
+		vhost_net_disable_vq(n, vq);
+		rcu_assign_pointer(vq->private_data, sock);
+		vhost_net_enable_vq(n, vq);
 	}
 
 	mutex_unlock(&vq->mutex);
@@ -768,6 +771,7 @@ static long vhost_net_reset_owner(struct
 	struct socket *tx_sock = NULL;
 	struct socket *rx_sock = NULL;
 	long err;
+
 	mutex_lock(&n->dev.mutex);
 	err = vhost_dev_check_owner(&n->dev);
 	if (err)
@@ -829,6 +833,7 @@ static long vhost_net_ioctl(struct file 
 	struct vhost_vring_file backend;
 	u64 features;
 	int r;
+
 	switch (ioctl) {
 	case VHOST_NET_SET_BACKEND:
 		if (copy_from_user(&backend, argp, sizeof backend))
diff -ruNp org/drivers/vhost/vhost.c new/drivers/vhost/vhost.c
--- org/drivers/vhost/vhost.c	2011-01-19 20:01:29.000000000 +0530
+++ new/drivers/vhost/vhost.c	2011-03-01 13:36:58.000000000 +0530
@@ -41,8 +41,8 @@ static void vhost_poll_func(struct file 
 			    poll_table *pt)
 {
 	struct vhost_poll *poll;
-	poll = container_of(pt, struct vhost_poll, table);
 
+	poll = container_of(pt, struct vhost_poll, table);
 	poll->wqh = wqh;
 	add_wait_queue(wqh, &poll->wait);
 }
@@ -85,6 +85,7 @@ void vhost_poll_init(struct vhost_poll *
 void vhost_poll_start(struct vhost_poll *poll, struct file *file)
 {
 	unsigned long mask;
+
 	mask = file->f_op->poll(file, &poll->table);
 	if (mask)
 		vhost_poll_wakeup(&poll->wait, 0, 0, (void *)mask);
@@ -101,6 +102,7 @@ static bool vhost_work_seq_done(struct v
 				unsigned seq)
 {
 	int left;
+
 	spin_lock_irq(&dev->work_lock);
 	left = seq - work->done_seq;
 	spin_unlock_irq(&dev->work_lock);
@@ -222,6 +224,7 @@ static int vhost_worker(void *data)
 static long vhost_dev_alloc_iovecs(struct vhost_dev *dev)
 {
 	int i;
+
 	for (i = 0; i < dev->nvqs; ++i) {
 		dev->vqs[i].indirect = kmalloc(sizeof *dev->vqs[i].indirect *
 					       UIO_MAXIOV, GFP_KERNEL);
@@ -235,6 +238,7 @@ static long vhost_dev_alloc_iovecs(struc
 			goto err_nomem;
 	}
 	return 0;
+
 err_nomem:
 	for (; i >= 0; --i) {
 		kfree(dev->vqs[i].indirect);
@@ -247,6 +251,7 @@ err_nomem:
 static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 {
 	int i;
+
 	for (i = 0; i < dev->nvqs; ++i) {
 		kfree(dev->vqs[i].indirect);
 		dev->vqs[i].indirect = NULL;
@@ -296,26 +301,28 @@ long vhost_dev_check_owner(struct vhost_
 }
 
 struct vhost_attach_cgroups_struct {
-        struct vhost_work work;
-        struct task_struct *owner;
-        int ret;
+	struct vhost_work work;
+	struct task_struct *owner;
+	int ret;
 };
 
 static void vhost_attach_cgroups_work(struct vhost_work *work)
 {
-        struct vhost_attach_cgroups_struct *s;
-        s = container_of(work, struct vhost_attach_cgroups_struct, work);
-        s->ret = cgroup_attach_task_all(s->owner, current);
+	struct vhost_attach_cgroups_struct *s;
+
+	s = container_of(work, struct vhost_attach_cgroups_struct, work);
+	s->ret = cgroup_attach_task_all(s->owner, current);
 }
 
 static int vhost_attach_cgroups(struct vhost_dev *dev)
 {
-        struct vhost_attach_cgroups_struct attach;
-        attach.owner = current;
-        vhost_work_init(&attach.work, vhost_attach_cgroups_work);
-        vhost_work_queue(dev, &attach.work);
-        vhost_work_flush(dev, &attach.work);
-        return attach.ret;
+	struct vhost_attach_cgroups_struct attach;
+
+	attach.owner = current;
+	vhost_work_init(&attach.work, vhost_attach_cgroups_work);
+	vhost_work_queue(dev, &attach.work);
+	vhost_work_flush(dev, &attach.work);
+	return attach.ret;
 }
 
 /* Caller should have device mutex */
@@ -323,11 +330,13 @@ static long vhost_dev_set_owner(struct v
 {
 	struct task_struct *worker;
 	int err;
+
 	/* Is there an owner already? */
 	if (dev->mm) {
 		err = -EBUSY;
 		goto err_mm;
 	}
+
 	/* No owner, become one */
 	dev->mm = get_task_mm(current);
 	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
@@ -380,6 +389,7 @@ long vhost_dev_reset_owner(struct vhost_
 void vhost_dev_cleanup(struct vhost_dev *dev)
 {
 	int i;
+
 	for (i = 0; i < dev->nvqs; ++i) {
 		if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
 			vhost_poll_stop(&dev->vqs[i].poll);
@@ -421,6 +431,7 @@ void vhost_dev_cleanup(struct vhost_dev 
 static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
 {
 	u64 a = addr / VHOST_PAGE_SIZE / 8;
+
 	/* Make sure 64 bit math will not overflow. */
 	if (a > ULONG_MAX - (unsigned long)log_base ||
 	    a + (unsigned long)log_base > ULONG_MAX)
@@ -461,6 +472,7 @@ static int memory_access_ok(struct vhost
 			    int log_all)
 {
 	int i;
+
 	for (i = 0; i < d->nvqs; ++i) {
 		int ok;
 		mutex_lock(&d->vqs[i].mutex);
@@ -527,6 +539,7 @@ static long vhost_set_memory(struct vhos
 {
 	struct vhost_memory mem, *newmem, *oldmem;
 	unsigned long size = offsetof(struct vhost_memory, regions);
+
 	if (copy_from_user(&mem, m, size))
 		return -EFAULT;
 	if (mem.padding)
@@ -544,7 +557,8 @@ static long vhost_set_memory(struct vhos
 		return -EFAULT;
 	}
 
-	if (!memory_access_ok(d, newmem, vhost_has_feature(d, VHOST_F_LOG_ALL))) {
+	if (!memory_access_ok(d, newmem,
+			      vhost_has_feature(d, VHOST_F_LOG_ALL))) {
 		kfree(newmem);
 		return -EFAULT;
 	}
@@ -560,6 +574,7 @@ static int init_used(struct vhost_virtqu
 		     struct vring_used __user *used)
 {
 	int r = put_user(vq->used_flags, &used->flags);
+
 	if (r)
 		return r;
 	return get_user(vq->last_used_idx, &used->idx);
@@ -849,6 +864,7 @@ static const struct vhost_memory_region 
 {
 	struct vhost_memory_region *reg;
 	int i;
+
 	/* linear search is not brilliant, but we really have on the order of 6
 	 * regions in practice */
 	for (i = 0; i < mem->nregions; ++i) {
@@ -871,6 +887,7 @@ static int set_bit_to_user(int nr, void 
 	void *base;
 	int bit = nr + (log % PAGE_SIZE) * 8;
 	int r;
+
 	r = get_user_pages_fast(log, 1, 1, &page);
 	if (r < 0)
 		return r;
@@ -888,6 +905,7 @@ static int log_write(void __user *log_ba
 {
 	u64 write_page = write_address / VHOST_PAGE_SIZE;
 	int r;
+
 	if (!write_length)
 		return 0;
 	write_length += write_address % VHOST_PAGE_SIZE;
@@ -1037,8 +1055,8 @@ static int get_indirect(struct vhost_dev
 			       i, count);
 			return -EINVAL;
 		}
-		if (unlikely(memcpy_fromiovec((unsigned char *)&desc, vq->indirect,
-					      sizeof desc))) {
+		if (unlikely(memcpy_fromiovec((unsigned char *)&desc,
+					      vq->indirect, sizeof desc))) {
 			vq_err(vq, "Failed indirect descriptor: idx %d, %zx\n",
 			       i, (size_t)indirect->addr + i * sizeof desc);
 			return -EINVAL;
@@ -1317,6 +1335,7 @@ int vhost_add_used_n(struct vhost_virtqu
 void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 {
 	__u16 flags;
+
 	/* Flush out used index updates. This is paired
 	 * with the barrier that the Guest executes when enabling
 	 * interrupts. */
@@ -1361,6 +1380,7 @@ bool vhost_enable_notify(struct vhost_vi
 {
 	u16 avail_idx;
 	int r;
+
 	if (!(vq->used_flags & VRING_USED_F_NO_NOTIFY))
 		return false;
 	vq->used_flags &= ~VRING_USED_F_NO_NOTIFY;
@@ -1387,6 +1407,7 @@ bool vhost_enable_notify(struct vhost_vi
 void vhost_disable_notify(struct vhost_virtqueue *vq)
 {
 	int r;
+
 	if (vq->used_flags & VRING_USED_F_NO_NOTIFY)
 		return;
 	vq->used_flags |= VRING_USED_F_NO_NOTIFY;
