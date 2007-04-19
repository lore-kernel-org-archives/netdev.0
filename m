From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/3] [AF_IUCV/IUCV]: Add missing section annotations
Date: Thu, 19 Apr 2007 11:12:33 +0200
Message-ID: <20070419091233.GE14586@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:50772 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993216AbXDSJKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 05:10:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Add missing section annotations and found and fixed some
Coding Style issues.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 af_iucv.c |   44 +++++++++++++++++++++++---------------------
 iucv.c    |   49 ++++++++++++++++++++++---------------------------
 2 files changed, 45 insertions(+), 48 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 0c2e4a8..7f1672d 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -45,7 +45,8 @@ static struct proto iucv_proto = {
 static void iucv_callback_rx(struct iucv_path *, struct iucv_message *);
 static void iucv_callback_txdone(struct iucv_path *, struct iucv_message *);
 static void iucv_callback_connack(struct iucv_path *, u8 ipuser[16]);
-static int iucv_callback_connreq(struct iucv_path *, u8 ipvmid[8], u8 ipuser[16]);
+static int iucv_callback_connreq(struct iucv_path *, u8 ipvmid[8],
+				 u8 ipuser[16]);
 static void iucv_callback_connrej(struct iucv_path *, u8 ipuser[16]);
 
 static struct iucv_sock_list iucv_sk_list = {
@@ -152,7 +153,7 @@ static void iucv_sock_close(struct sock *sk)
 	iucv_sock_clear_timer(sk);
 	lock_sock(sk);
 
-	switch(sk->sk_state) {
+	switch (sk->sk_state) {
 	case IUCV_LISTEN:
 		iucv_sock_cleanup_listen(sk);
 		break;
@@ -164,7 +165,7 @@ static void iucv_sock_close(struct sock *sk)
 		sk->sk_state = IUCV_CLOSING;
 		sk->sk_state_change(sk);
 
-		if(!skb_queue_empty(&iucv->send_skb_q)) {
+		if (!skb_queue_empty(&iucv->send_skb_q)) {
 			if (sock_flag(sk, SOCK_LINGER) && sk->sk_lingertime)
 				timeo = sk->sk_lingertime;
 			else
@@ -292,7 +293,7 @@ struct sock *iucv_accept_dequeue(struct sock *parent, struct socket *newsock)
 	struct iucv_sock *isk, *n;
 	struct sock *sk;
 
-	list_for_each_entry_safe(isk, n, &iucv_sk(parent)->accept_q, accept_q){
+	list_for_each_entry_safe(isk, n, &iucv_sk(parent)->accept_q, accept_q) {
 		sk = (struct sock *) isk;
 		lock_sock(sk);
 
@@ -537,7 +538,7 @@ static int iucv_sock_accept(struct socket *sock, struct socket *newsock,
 
 	/* Wait for an incoming connection */
 	add_wait_queue_exclusive(sk->sk_sleep, &wait);
-	while (!(nsk = iucv_accept_dequeue(sk, newsock))){
+	while (!(nsk = iucv_accept_dequeue(sk, newsock))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (!timeo) {
 			err = -EAGAIN;
@@ -618,13 +619,13 @@ static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 	}
 
-	if (sk->sk_state == IUCV_CONNECTED){
-		if(!(skb = sock_alloc_send_skb(sk, len,
-				       msg->msg_flags & MSG_DONTWAIT,
-				       &err)))
+	if (sk->sk_state == IUCV_CONNECTED) {
+		if (!(skb = sock_alloc_send_skb(sk, len,
+						msg->msg_flags & MSG_DONTWAIT,
+						&err)))
 			goto out;
 
-		if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)){
+		if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
 			err = -EFAULT;
 			goto fail;
 		}
@@ -710,7 +711,7 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		/* Queue backlog skbs */
 		rskb = skb_dequeue(&iucv_sk(sk)->backlog_skb_q);
-		while(rskb) {
+		while (rskb) {
 			if (sock_queue_rcv_skb(sk, rskb)) {
 				skb_queue_head(&iucv_sk(sk)->backlog_skb_q,
 						rskb);
@@ -731,7 +732,7 @@ static inline unsigned int iucv_accept_poll(struct sock *parent)
 	struct iucv_sock *isk, *n;
 	struct sock *sk;
 
-	list_for_each_entry_safe(isk, n, &iucv_sk(parent)->accept_q, accept_q){
+	list_for_each_entry_safe(isk, n, &iucv_sk(parent)->accept_q, accept_q) {
 		sk = (struct sock *) isk;
 
 		if (sk->sk_state == IUCV_CONNECTED)
@@ -762,7 +763,7 @@ unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 		mask |= POLLHUP;
 
 	if (!skb_queue_empty(&sk->sk_receive_queue) ||
-			(sk->sk_shutdown & RCV_SHUTDOWN))
+	    (sk->sk_shutdown & RCV_SHUTDOWN))
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sk->sk_state == IUCV_CLOSED)
@@ -793,7 +794,7 @@ static int iucv_sock_shutdown(struct socket *sock, int how)
 		return -EINVAL;
 
 	lock_sock(sk);
-	switch(sk->sk_state) {
+	switch (sk->sk_state) {
 	case IUCV_CLOSED:
 		err = -ENOTCONN;
 		goto fail;
@@ -809,7 +810,7 @@ static int iucv_sock_shutdown(struct socket *sock, int how)
 		err = iucv_message_send(iucv->path, &txmsg, IUCV_IPRMDATA, 0,
 					(void *) prmmsg, 8);
 		if (err) {
-			switch(err) {
+			switch (err) {
 			case 1:
 				err = -ENOTCONN;
 				break;
@@ -912,7 +913,7 @@ static int iucv_callback_connreq(struct iucv_path *path,
 
 	/* Create the new socket */
 	nsk = iucv_sock_alloc(NULL, SOCK_STREAM, GFP_ATOMIC);
-	if (!nsk){
+	if (!nsk) {
 		err = iucv_path_sever(path, user_data);
 		goto fail;
 	}
@@ -935,7 +936,7 @@ static int iucv_callback_connreq(struct iucv_path *path,
 
 	path->msglim = IUCV_QUEUELEN_DEFAULT;
 	err = iucv_path_accept(path, &af_iucv_handler, nuser_data, nsk);
-	if (err){
+	if (err) {
 		err = iucv_path_sever(path, user_data);
 		goto fail;
 	}
@@ -966,7 +967,7 @@ static int iucv_fragment_skb(struct sock *sk, struct sk_buff *skb, int len,
 	struct sk_buff *nskb;
 
 	dataleft = len;
-	while(dataleft) {
+	while (dataleft) {
 		if (dataleft >= sk->sk_rcvbuf / 4)
 			size = sk->sk_rcvbuf / 4;
 		else
@@ -989,6 +990,7 @@ static int iucv_fragment_skb(struct sock *sk, struct sk_buff *skb, int len,
 
 	return 0;
 }
+
 static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 {
 	struct sock *sk = path->private;
@@ -1037,7 +1039,7 @@ static void iucv_callback_rx(struct iucv_path *path, struct iucv_message *msg)
 
 	/* Queue the fragmented skb */
 	fskb = skb_dequeue(&fragmented_skb_q);
-	while(fskb) {
+	while (fskb) {
 		if (!skb_queue_empty(&iucv->backlog_skb_q))
 			skb_queue_tail(&iucv->backlog_skb_q, fskb);
 		else if (sock_queue_rcv_skb(sk, fskb))
@@ -1077,7 +1079,7 @@ static void iucv_callback_txdone(struct iucv_path *path,
 		kfree_skb(this);
 	}
 
-	if (sk->sk_state == IUCV_CLOSING){
+	if (sk->sk_state == IUCV_CLOSING) {
 		if (skb_queue_empty(&iucv_sk(sk)->send_skb_q)) {
 			sk->sk_state = IUCV_CLOSED;
 			sk->sk_state_change(sk);
@@ -1124,7 +1126,7 @@ static struct net_proto_family iucv_sock_family_ops = {
 	.create	= iucv_sock_create,
 };
 
-static int afiucv_init(void)
+static int __init afiucv_init(void)
 {
 	int err;
 
diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
index 903bdb6..fb3faf7 100644
--- a/net/iucv/iucv.c
+++ b/net/iucv/iucv.c
@@ -32,7 +32,6 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-
 #include <linux/spinlock.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
@@ -69,7 +68,7 @@
 #define IUCV_IPNORPY	0x10
 #define IUCV_IPALL	0x80
 
-static int iucv_bus_match (struct device *dev, struct device_driver *drv)
+static int iucv_bus_match(struct device *dev, struct device_driver *drv)
 {
 	return 0;
 }
@@ -78,8 +77,11 @@ struct bus_type iucv_bus = {
 	.name = "iucv",
 	.match = iucv_bus_match,
 };
+EXPORT_SYMBOL(iucv_bus);
 
 struct device *iucv_root;
+EXPORT_SYMBOL(iucv_root);
+
 static int iucv_available;
 
 /* General IUCV interrupt structure */
@@ -405,7 +407,7 @@ static void iucv_declare_cpu(void *data)
 	rc = iucv_call_b2f0(IUCV_DECLARE_BUFFER, parm);
 	if (rc) {
 		char *err = "Unknown";
-		switch(rc) {
+		switch (rc) {
 		case 0x03:
 			err = "Directory error";
 			break;
@@ -588,7 +590,7 @@ static int __cpuinit iucv_cpu_notify(struct notifier_block *self,
 	return NOTIFY_OK;
 }
 
-static struct notifier_block iucv_cpu_notifier = {
+static struct notifier_block __cpuinitdata iucv_cpu_notifier = {
 	.notifier_call = iucv_cpu_notify,
 };
 
@@ -691,6 +693,7 @@ out_mutex:
 	mutex_unlock(&iucv_register_mutex);
 	return rc;
 }
+EXPORT_SYMBOL(iucv_register);
 
 /**
  * iucv_unregister
@@ -723,6 +726,7 @@ void iucv_unregister(struct iucv_handler *handler, int smp)
 		iucv_setmask_mp();
 	mutex_unlock(&iucv_register_mutex);
 }
+EXPORT_SYMBOL(iucv_unregister);
 
 /**
  * iucv_path_accept
@@ -761,6 +765,7 @@ int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_path_accept);
 
 /**
  * iucv_path_connect
@@ -824,6 +829,7 @@ int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
 	spin_unlock_bh(&iucv_table_lock);
 	return rc;
 }
+EXPORT_SYMBOL(iucv_path_connect);
 
 /**
  * iucv_path_quiesce:
@@ -850,6 +856,7 @@ int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16])
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_path_quiesce);
 
 /**
  * iucv_path_resume:
@@ -890,7 +897,6 @@ int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
 {
 	int rc;
 
-
 	preempt_disable();
 	if (iucv_active_cpu != smp_processor_id())
 		spin_lock_bh(&iucv_table_lock);
@@ -904,6 +910,7 @@ int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
 	preempt_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_path_sever);
 
 /**
  * iucv_message_purge
@@ -936,6 +943,7 @@ int iucv_message_purge(struct iucv_path *path, struct iucv_message *msg,
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_message_purge);
 
 /**
  * iucv_message_receive
@@ -1006,6 +1014,7 @@ int iucv_message_receive(struct iucv_path *path, struct iucv_message *msg,
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_message_receive);
 
 /**
  * iucv_message_reject
@@ -1034,6 +1043,7 @@ int iucv_message_reject(struct iucv_path *path, struct iucv_message *msg)
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_message_reject);
 
 /**
  * iucv_message_reply
@@ -1077,6 +1087,7 @@ int iucv_message_reply(struct iucv_path *path, struct iucv_message *msg,
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_message_reply);
 
 /**
  * iucv_message_send
@@ -1125,6 +1136,7 @@ int iucv_message_send(struct iucv_path *path, struct iucv_message *msg,
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_message_send);
 
 /**
  * iucv_message_send2way
@@ -1181,6 +1193,7 @@ int iucv_message_send2way(struct iucv_path *path, struct iucv_message *msg,
 	local_bh_enable();
 	return rc;
 }
+EXPORT_SYMBOL(iucv_message_send2way);
 
 /**
  * iucv_path_pending
@@ -1572,7 +1585,7 @@ static void iucv_external_interrupt(u16 code)
  *
  * Allocates and initializes various data structures.
  */
-static int iucv_init(void)
+static int __init iucv_init(void)
 {
 	int rc;
 
@@ -1583,7 +1596,7 @@ static int iucv_init(void)
 	rc = iucv_query_maxconn();
 	if (rc)
 		goto out;
-	rc = register_external_interrupt (0x4000, iucv_external_interrupt);
+	rc = register_external_interrupt(0x4000, iucv_external_interrupt);
 	if (rc)
 		goto out;
 	rc = bus_register(&iucv_bus);
@@ -1594,7 +1607,7 @@ static int iucv_init(void)
 		rc = PTR_ERR(iucv_root);
 		goto out_bus;
 	}
-	/* Note: GFP_DMA used used to get memory below 2G */
+	/* Note: GFP_DMA used to get memory below 2G */
 	iucv_irq_data = percpu_alloc(sizeof(struct iucv_irq_data),
 				     GFP_KERNEL|GFP_DMA);
 	if (!iucv_irq_data) {
@@ -1632,7 +1645,7 @@ out:
  *
  * Frees everything allocated from iucv_init.
  */
-static void iucv_exit(void)
+static void __exit iucv_exit(void)
 {
 	struct iucv_irq_list *p, *n;
 
@@ -1653,24 +1666,6 @@ static void iucv_exit(void)
 subsys_initcall(iucv_init);
 module_exit(iucv_exit);
 
-/**
- * Export all public stuff
- */
-EXPORT_SYMBOL (iucv_bus);
-EXPORT_SYMBOL (iucv_root);
-EXPORT_SYMBOL (iucv_register);
-EXPORT_SYMBOL (iucv_unregister);
-EXPORT_SYMBOL (iucv_path_accept);
-EXPORT_SYMBOL (iucv_path_connect);
-EXPORT_SYMBOL (iucv_path_quiesce);
-EXPORT_SYMBOL (iucv_path_sever);
-EXPORT_SYMBOL (iucv_message_purge);
-EXPORT_SYMBOL (iucv_message_receive);
-EXPORT_SYMBOL (iucv_message_reject);
-EXPORT_SYMBOL (iucv_message_reply);
-EXPORT_SYMBOL (iucv_message_send);
-EXPORT_SYMBOL (iucv_message_send2way);
-
 MODULE_AUTHOR("(C) 2001 IBM Corp. by Fritz Elfert (felfert@millenux.com)");
 MODULE_DESCRIPTION("Linux for S/390 IUCV lowlevel driver");
 MODULE_LICENSE("GPL");
-- 
1.5.0.1

