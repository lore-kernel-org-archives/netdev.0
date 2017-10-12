From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 03/10] staging/irda/net: Adjust 385 checks for null pointers
Date: Thu, 12 Oct 2017 12:42:08 +0200
Message-ID: <56031778-6c76-acab-6365-fe2af38e6221@users.sourceforge.net>
References: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Georgiana Chelu <georgiana.chelu93@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Samuel Ortiz <samuel@sortiz.org>,
        Srishti Sharma <srishtishar@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 11 Oct 2017 22:10:26 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written …

Thus fix the affected source code places.


Use space characters at some places according to the Linux coding
style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/irda/net/af_irda.c      |  56 ++++++-------
 drivers/staging/irda/net/discovery.c    |  31 ++++---
 drivers/staging/irda/net/irda_device.c  |   2 +-
 drivers/staging/irda/net/iriap.c        |  61 +++++++-------
 drivers/staging/irda/net/iriap_event.c  |  34 ++++----
 drivers/staging/irda/net/irias_object.c |  62 +++++++-------
 drivers/staging/irda/net/irlap.c        |  73 ++++++++--------
 drivers/staging/irda/net/irlap_event.c  |  77 +++++++++--------
 drivers/staging/irda/net/irlap_frame.c  |  51 +++++------
 drivers/staging/irda/net/irlmp.c        | 144 +++++++++++++++-----------------
 drivers/staging/irda/net/irlmp_event.c  |  50 ++++++-----
 drivers/staging/irda/net/irlmp_frame.c  |  24 +++---
 drivers/staging/irda/net/irnetlink.c    |   2 +-
 drivers/staging/irda/net/irproc.c       |   2 +-
 drivers/staging/irda/net/irqueue.c      |  32 +++----
 drivers/staging/irda/net/irsysctl.c     |   4 +-
 drivers/staging/irda/net/irttp.c        |  68 +++++++--------
 drivers/staging/irda/net/parameters.c   |  12 +--
 drivers/staging/irda/net/qos.c          |  20 ++---
 drivers/staging/irda/net/timer.c        |  12 +--
 drivers/staging/irda/net/wrapper.c      |   3 +-
 21 files changed, 396 insertions(+), 424 deletions(-)

diff --git a/drivers/staging/irda/net/af_irda.c b/drivers/staging/irda/net/af_irda.c
index 23fa7c8b09a5..cb60b89053dd 100644
--- a/drivers/staging/irda/net/af_irda.c
+++ b/drivers/staging/irda/net/af_irda.c
@@ -121,7 +121,7 @@ static void irda_disconnect_indication(void *instance, void *sap,
 		dev_kfree_skb(skb);
 
 	sk = instance;
-	if (sk == NULL) {
+	if (!sk) {
 		pr_debug("%s(%p) : BUG : sk is NULL\n",
 			 __func__, self);
 		return;
@@ -182,7 +182,7 @@ static void irda_connect_confirm(void *instance, void *sap,
 	pr_debug("%s(%p)\n", __func__, self);
 
 	sk = instance;
-	if (sk == NULL) {
+	if (!sk) {
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -246,7 +246,7 @@ static void irda_connect_indication(void *instance, void *sap,
 	pr_debug("%s(%p)\n", __func__, self);
 
 	sk = instance;
-	if (sk == NULL) {
+	if (!sk) {
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -301,7 +301,7 @@ static void irda_connect_response(struct irda_sock *self)
 	struct sk_buff *skb;
 
 	skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER, GFP_KERNEL);
-	if (skb == NULL) {
+	if (!skb) {
 		pr_debug("%s() Unable to allocate sk_buff!\n",
 			 __func__);
 		return;
@@ -326,7 +326,7 @@ static void irda_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 
 	self = instance;
 	sk = instance;
-	BUG_ON(sk == NULL);
+	BUG_ON(!sk);
 
 	switch (flow) {
 	case FLOW_STOP:
@@ -434,7 +434,7 @@ static void irda_discovery_timeout(u_long priv)
 	struct irda_sock *self;
 
 	self = (struct irda_sock *) priv;
-	BUG_ON(self == NULL);
+	BUG_ON(!self);
 
 	/* Nothing for the caller */
 	self->cachelog = NULL;
@@ -473,7 +473,7 @@ static int irda_open_tsap(struct irda_sock *self, __u8 tsap_sel, char *name)
 
 	self->tsap = irttp_open_tsap(tsap_sel, DEFAULT_INITIAL_CREDIT,
 				     &notify);
-	if (self->tsap == NULL) {
+	if (!self->tsap) {
 		pr_debug("%s(), Unable to allocate TSAP!\n",
 			 __func__);
 		return -ENOMEM;
@@ -507,7 +507,7 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
 	strncpy(notify.name, "Ultra", NOTIFY_MAX_NAME);
 
 	self->lsap = irlmp_open_lsap(LSAP_CONNLESS, &notify, pid);
-	if (self->lsap == NULL) {
+	if (!self->lsap) {
 		pr_debug("%s(), Unable to allocate LSAP!\n", __func__);
 		return -ENOMEM;
 	}
@@ -539,7 +539,7 @@ static int irda_find_lsap_sel(struct irda_sock *self, char *name)
 
 	self->iriap = iriap_open(LSAP_ANY, IAS_CLIENT, self,
 				 irda_getvalue_confirm);
-	if(self->iriap == NULL)
+	if (!self->iriap)
 		return -ENOMEM;
 
 	/* Treat unexpected wakeup as disconnect */
@@ -625,7 +625,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 	discoveries = irlmp_get_discoveries(&number, self->mask.word,
 					    self->nslots);
 	/* Check if the we got some results */
-	if (discoveries == NULL)
+	if (!discoveries)
 		return -ENETUNREACH;	/* No nodes discovered */
 
 	/*
@@ -801,7 +801,7 @@ static int irda_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	self->ias_obj = irias_new_object(addr->sir_name, jiffies);
 	err = -ENOMEM;
-	if (self->ias_obj == NULL)
+	if (!self->ias_obj)
 		goto out;
 
 	err = irda_open_tsap(self, addr->sir_lsap_sel, addr->sir_name);
@@ -887,7 +887,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags,
 
 	newsk = newsock->sk;
 	err = -EIO;
-	if (newsk == NULL)
+	if (!newsk)
 		goto out;
 
 	newsk->sk_state = TCP_ESTABLISHED;
@@ -1105,7 +1105,7 @@ static int irda_create(struct net *net, struct socket *sock, int protocol,
 
 	/* Allocate networking socket */
 	sk = sk_alloc(net, PF_IRDA, GFP_KERNEL, &irda_proto, kern);
-	if (sk == NULL)
+	if (!sk)
 		return -ENOMEM;
 
 	self = irda_sk(sk);
@@ -1208,7 +1208,7 @@ static int irda_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	if (sk == NULL)
+	if (!sk)
 		return 0;
 
 	lock_sock(sk);
@@ -1431,7 +1431,7 @@ static int irda_recvmsg_stream(struct socket *sock, struct msghdr *msg,
 		int chunk;
 		struct sk_buff *skb = skb_dequeue(&sk->sk_receive_queue);
 
-		if (skb == NULL) {
+		if (!skb) {
 			DEFINE_WAIT(wait);
 			err = 0;
 
@@ -1454,7 +1454,7 @@ static int irda_recvmsg_stream(struct socket *sock, struct msghdr *msg,
 				err = sock_intr_errno(timeo);
 			else if (sk->sk_state != TCP_ESTABLISHED)
 				err = -ENOTCONN;
-			else if (skb_peek(&sk->sk_receive_queue) == NULL)
+			else if (!skb_peek(&sk->sk_receive_queue))
 				/* Wait process until data arrives */
 				schedule();
 
@@ -1649,8 +1649,7 @@ static int irda_sendmsg_ultra(struct socket *sock, struct msghdr *msg,
 	} else {
 		/* Check that the socket is properly bound to an Ultra
 		 * port. Jean II */
-		if ((self->lsap == NULL) ||
-		    (sk->sk_state != TCP_ESTABLISHED)) {
+		if (!self->lsap || sk->sk_state != TCP_ESTABLISHED) {
 			pr_debug("%s(), socket not bound to Ultra PID.\n",
 				 __func__);
 			err = -ENOTCONN;
@@ -1828,7 +1827,7 @@ static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	}
 
 	case SIOCGSTAMP:
-		if (sk != NULL)
+		if (sk)
 			err = sock_get_timestamp(sk, (struct timeval __user *)arg);
 		break;
 
@@ -1913,7 +1912,7 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 		 * associated with this socket. This will workaround
 		 * duplicated class name - Jean II */
 		if(ias_opt->irda_class_name[0] == '\0') {
-			if(self->ias_obj == NULL) {
+			if (!self->ias_obj) {
 				kfree(ias_opt);
 				err = -EINVAL;
 				goto out;
@@ -1925,19 +1924,19 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 		/* Only ROOT can mess with the global IAS database.
 		 * Users can only add attributes to the object associated
 		 * with the socket they own - Jean II */
-		if((!capable(CAP_NET_ADMIN)) &&
-		   ((ias_obj == NULL) || (ias_obj != self->ias_obj))) {
+		if (!capable(CAP_NET_ADMIN) &&
+		    (!ias_obj || ias_obj != self->ias_obj)) {
 			kfree(ias_opt);
 			err = -EPERM;
 			goto out;
 		}
 
 		/* If the object doesn't exist, create it */
-		if(ias_obj == (struct ias_object *) NULL) {
+		if (!ias_obj) {
 			/* Create a new object */
 			ias_obj = irias_new_object(ias_opt->irda_class_name,
 						   jiffies);
-			if (ias_obj == NULL) {
+			if (!ias_obj) {
 				kfree(ias_opt);
 				err = -ENOMEM;
 				goto out;
@@ -2050,8 +2049,8 @@ static int irda_setsockopt(struct socket *sock, int level, int optname,
 		/* Only ROOT can mess with the global IAS database.
 		 * Users can only del attributes from the object associated
 		 * with the socket they own - Jean II */
-		if((!capable(CAP_NET_ADMIN)) &&
-		   ((ias_obj == NULL) || (ias_obj != self->ias_obj))) {
+		if (!capable(CAP_NET_ADMIN) &&
+		    (!ias_obj || ias_obj != self->ias_obj)) {
 			kfree(ias_opt);
 			err = -EPERM;
 			goto out;
@@ -2253,7 +2252,7 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 		discoveries = irlmp_get_discoveries(&list.len, self->mask.word,
 						    self->nslots);
 		/* Check if the we got some results */
-		if (discoveries == NULL) {
+		if (!discoveries) {
 			err = -EAGAIN;
 			goto out;		/* Didn't find any devices */
 		}
@@ -2404,8 +2403,7 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 
 		self->iriap = iriap_open(LSAP_ANY, IAS_CLIENT, self,
 					 irda_getvalue_confirm);
-
-		if (self->iriap == NULL) {
+		if (!self->iriap) {
 			kfree(ias_opt);
 			err = -ENOMEM;
 			goto out;
diff --git a/drivers/staging/irda/net/discovery.c b/drivers/staging/irda/net/discovery.c
index 1e54954a4081..7469d7c537a8 100644
--- a/drivers/staging/irda/net/discovery.c
+++ b/drivers/staging/irda/net/discovery.c
@@ -74,7 +74,7 @@ void irlmp_add_discovery(hashbin_t *cachelog, discovery_t *new)
 	 * their device address between every discovery.
 	 */
 	discovery = (discovery_t *) hashbin_get_first(cachelog);
-	while (discovery != NULL ) {
+	while (discovery) {
 		node = discovery;
 
 		/* Be sure to stay one item ahead */
@@ -118,7 +118,7 @@ void irlmp_add_discovery_log(hashbin_t *cachelog, hashbin_t *log)
 	 *  of the normal one.
 	 */
 	/* Well... It means that there was nobody out there - Jean II */
-	if (log == NULL) {
+	if (!log) {
 		/* irlmp_start_discovery_timer(irlmp, 150); */
 		return;
 	}
@@ -129,7 +129,7 @@ void irlmp_add_discovery_log(hashbin_t *cachelog, hashbin_t *log)
 	 * We just need to lock the global log in irlmp_add_discovery().
 	 */
 	discovery = (discovery_t *) hashbin_remove_first(log);
-	while (discovery != NULL) {
+	while (discovery) {
 		irlmp_add_discovery(cachelog, discovery);
 
 		discovery = (discovery_t *) hashbin_remove_first(log);
@@ -156,11 +156,11 @@ void irlmp_expire_discoveries(hashbin_t *log, __u32 saddr, int force)
 	int			n;		/* Size of the full log */
 	int			i = 0;		/* How many we expired */
 
-	IRDA_ASSERT(log != NULL, return;);
+	IRDA_ASSERT(log, return;);
 	spin_lock_irqsave(&log->hb_spinlock, flags);
 
 	discovery = (discovery_t *) hashbin_get_first(log);
-	while (discovery != NULL) {
+	while (discovery) {
 		/* Be sure to be one item ahead */
 		curr = discovery;
 		discovery = (discovery_t *) hashbin_get_next(log);
@@ -175,7 +175,7 @@ void irlmp_expire_discoveries(hashbin_t *log, __u32 saddr, int force)
 			 * we don't have anything to put in the log (we are
 			 * quite picky), we can save a lot of overhead
 			 * by not calling kmalloc. Jean II */
-			if(buffer == NULL) {
+			if (!buffer) {
 				/* Create the client specific buffer */
 				n = HASHBIN_GET_SIZE(log);
 				buffer = kmalloc(n * sizeof(struct irda_device_info), GFP_ATOMIC);
@@ -203,7 +203,7 @@ void irlmp_expire_discoveries(hashbin_t *log, __u32 saddr, int force)
 	 * don't care to be interrupted. - Jean II */
 	spin_unlock_irqrestore(&log->hb_spinlock, flags);
 
-	if(buffer == NULL)
+	if (!buffer)
 		return;
 
 	/* Tell IrLMP and registered clients about it */
@@ -224,10 +224,10 @@ void irlmp_dump_discoveries(hashbin_t *log)
 {
 	discovery_t *discovery;
 
-	IRDA_ASSERT(log != NULL, return;);
+	IRDA_ASSERT(log, return;);
 
 	discovery = (discovery_t *) hashbin_get_first(log);
-	while (discovery != NULL) {
+	while (discovery) {
 		pr_debug("Discovery:\n");
 		pr_debug("  daddr=%08x\n", discovery->data.daddr);
 		pr_debug("  saddr=%08x\n", discovery->data.saddr);
@@ -268,14 +268,14 @@ struct irda_device_info *irlmp_copy_discoveries(hashbin_t *log, int *pn,
 	int			n;		/* Size of the full log */
 	int			i = 0;		/* How many we picked */
 
-	IRDA_ASSERT(pn != NULL, return NULL;);
-	IRDA_ASSERT(log != NULL, return NULL;);
+	IRDA_ASSERT(pn, return NULL;);
+	IRDA_ASSERT(log, return NULL;);
 
 	/* Save spin lock */
 	spin_lock_irqsave(&log->hb_spinlock, flags);
 
 	discovery = (discovery_t *) hashbin_get_first(log);
-	while (discovery != NULL) {
+	while (discovery) {
 		/* Mask out the ones we don't want :
 		 * We want to match the discovery mask, and to get only
 		 * the most recent one (unless we want old ones) */
@@ -287,7 +287,7 @@ struct irda_device_info *irlmp_copy_discoveries(hashbin_t *log, int *pn,
 			 * we don't have anything to put in the log (we are
 			 * quite picky), we can save a lot of overhead
 			 * by not calling kmalloc. Jean II */
-			if(buffer == NULL) {
+			if (!buffer) {
 				/* Create the client specific buffer */
 				n = HASHBIN_GET_SIZE(log);
 				buffer = kmalloc(n * sizeof(struct irda_device_info), GFP_ATOMIC);
@@ -320,7 +320,7 @@ static inline discovery_t *discovery_seq_idx(loff_t pos)
 	discovery_t *discovery;
 
 	for (discovery = (discovery_t *) hashbin_get_first(irlmp->cachelog);
-	     discovery != NULL;
+	     discovery;
 	     discovery = (discovery_t *) hashbin_get_next(irlmp->cachelog)) {
 		if (pos-- == 0)
 			break;
@@ -402,8 +402,7 @@ static const struct seq_operations discovery_seq_ops = {
 
 static int discovery_seq_open(struct inode *inode, struct file *file)
 {
-	IRDA_ASSERT(irlmp != NULL, return -EINVAL;);
-
+	IRDA_ASSERT(irlmp, return -EINVAL;);
 	return seq_open(file, &discovery_seq_ops);
 }
 
diff --git a/drivers/staging/irda/net/irda_device.c b/drivers/staging/irda/net/irda_device.c
index d33de8a8762a..f06bf24341f9 100644
--- a/drivers/staging/irda/net/irda_device.c
+++ b/drivers/staging/irda/net/irda_device.c
@@ -190,7 +190,7 @@ static int irda_task_kick(struct irda_task *task)
 	int count = 0;
 	int timeout;
 
-	IRDA_ASSERT(task != NULL, return -1;);
+	IRDA_ASSERT(task, return -1;);
 	IRDA_ASSERT(task->magic == IRDA_TASK_MAGIC, return -1;);
 
 	/* Execute task until it's finished, or askes for a timeout */
diff --git a/drivers/staging/irda/net/iriap.c b/drivers/staging/irda/net/iriap.c
index 1138eaf5c682..2a6ffb468128 100644
--- a/drivers/staging/irda/net/iriap.c
+++ b/drivers/staging/irda/net/iriap.c
@@ -221,7 +221,7 @@ EXPORT_SYMBOL(iriap_open);
  */
 static void __iriap_close(struct iriap_cb *self)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	del_timer(&self->watchdog_timer);
@@ -243,7 +243,7 @@ void iriap_close(struct iriap_cb *self)
 {
 	struct iriap_cb *entry;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	if (self->lsap) {
@@ -274,7 +274,7 @@ static int iriap_register_lsap(struct iriap_cb *self, __u8 slsap_sel, int mode)
 		strcpy(notify.name, "IrIAS srv");
 
 	self->lsap = irlmp_open_lsap(slsap_sel, &notify, 0);
-	if (self->lsap == NULL) {
+	if (!self->lsap) {
 		net_err_ratelimited("%s: Unable to allocated LSAP!\n",
 				    __func__);
 		return -1;
@@ -301,10 +301,9 @@ static void iriap_disconnect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
-
-	IRDA_ASSERT(iriap != NULL, return;);
+	IRDA_ASSERT(iriap, return;);
 
 	del_timer(&self->watchdog_timer);
 
@@ -340,11 +339,11 @@ static void iriap_disconnect_request(struct iriap_cb *self)
 {
 	struct sk_buff *tx_skb;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
-	if (tx_skb == NULL) {
+	if (!tx_skb) {
 		pr_debug("%s(), Could not allocate an sk_buff of length %d\n",
 			 __func__, LMP_MAX_HEADER);
 		return;
@@ -372,7 +371,7 @@ int iriap_getvaluebyclass_request(struct iriap_cb *self,
 	int name_len, attr_len, skb_len;
 	__u8 *frame;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return -1;);
 
 	/* Client must supply the destination device address */
@@ -439,9 +438,9 @@ static void iriap_getvaluebyclass_confirm(struct iriap_cb *self,
 	__u8 *fp;
 	int n;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	/* Initialize variables */
 	fp = skb->data;
@@ -551,9 +550,9 @@ static void iriap_getvaluebyclass_response(struct iriap_cb *self,
 	__be16 tmp_be16;
 	__u8 *fp;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
-	IRDA_ASSERT(value != NULL, return;);
+	IRDA_ASSERT(value, return;);
 	IRDA_ASSERT(value->len <= 1024, return;);
 
 	/* Initialize variables */
@@ -643,9 +642,9 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
 	__u8 *fp;
 	int n;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	fp = skb->data;
 	n = 1;
@@ -666,8 +665,7 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
 
 	pr_debug("LM-IAS: Looking up %s: %s\n", name, attr);
 	obj = irias_find_object(name);
-
-	if (obj == NULL) {
+	if (!obj) {
 		pr_debug("LM-IAS: Object %s not found\n", name);
 		iriap_getvaluebyclass_response(self, 0x1235, IAS_CLASS_UNKNOWN,
 					       &irias_missing);
@@ -676,7 +674,7 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
 	pr_debug("LM-IAS: found %s, id=%d\n", obj->name, obj->id);
 
 	attrib = irias_find_attrib(obj, attr);
-	if (attrib == NULL) {
+	if (!attrib) {
 		pr_debug("LM-IAS: Attribute %s not found\n", attr);
 		iriap_getvaluebyclass_response(self, obj->id,
 					       IAS_ATTRIB_UNKNOWN,
@@ -700,7 +698,7 @@ void iriap_send_ack(struct iriap_cb *self)
 	struct sk_buff *tx_skb;
 	__u8 *frame;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	tx_skb = alloc_skb(LMP_MAX_HEADER + 1, GFP_ATOMIC);
@@ -722,7 +720,7 @@ void iriap_connect_request(struct iriap_cb *self)
 {
 	int ret;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	ret = irlmp_connect_request(self->lsap, LSAP_IAS,
@@ -749,9 +747,9 @@ static void iriap_connect_confirm(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	self->max_data_size = max_seg_size;
 	self->max_header_size = max_header_size;
@@ -779,8 +777,8 @@ static void iriap_connect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(skb != NULL, return;);
-	IRDA_ASSERT(self != NULL, goto out;);
+	IRDA_ASSERT(skb, return;);
+	IRDA_ASSERT(self, goto out;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, goto out;);
 
 	/* Start new server */
@@ -825,8 +823,8 @@ static int iriap_data_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(skb != NULL, return 0;);
-	IRDA_ASSERT(self != NULL, goto out;);
+	IRDA_ASSERT(skb, return 0;);
+	IRDA_ASSERT(self, goto out;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, goto out;);
 
 	frame = skb->data;
@@ -914,9 +912,9 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
 	__u8 *fp;
 	__u8 opcode;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	fp = skb->data;
 
@@ -950,7 +948,7 @@ static void iriap_watchdog_timer_expired(void *data)
 {
 	struct iriap_cb *self = (struct iriap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	/* iriap_close(self); */
@@ -1019,7 +1017,7 @@ static int irias_seq_show(struct seq_file *seq, void *v)
 
 		/* List all attributes for this object */
 		for (attrib = (struct ias_attrib *) hashbin_get_first(obj->attribs);
-		     attrib != NULL;
+		     attrib;
 		     attrib = (struct ias_attrib *) hashbin_get_next(obj->attribs)) {
 
 			IRDA_ASSERT(attrib->magic == IAS_ATTRIB_MAGIC,
@@ -1069,8 +1067,7 @@ static const struct seq_operations irias_seq_ops = {
 
 static int irias_seq_open(struct inode *inode, struct file *file)
 {
-	IRDA_ASSERT( irias_objects != NULL, return -EINVAL;);
-
+	IRDA_ASSERT(irias_objects, return -EINVAL;);
 	return seq_open(file, &irias_seq_ops);
 }
 
diff --git a/drivers/staging/irda/net/iriap_event.c b/drivers/staging/irda/net/iriap_event.c
index e6098b2e048a..468e30172702 100644
--- a/drivers/staging/irda/net/iriap_event.c
+++ b/drivers/staging/irda/net/iriap_event.c
@@ -95,7 +95,7 @@ static void (*iriap_state[])(struct iriap_cb *self, IRIAP_EVENT event,
 
 void iriap_next_client_state(struct iriap_cb *self, IRIAP_STATE state)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	self->client_state = state;
@@ -103,7 +103,7 @@ void iriap_next_client_state(struct iriap_cb *self, IRIAP_STATE state)
 
 void iriap_next_call_state(struct iriap_cb *self, IRIAP_STATE state)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	self->call_state = state;
@@ -111,7 +111,7 @@ void iriap_next_call_state(struct iriap_cb *self, IRIAP_STATE state)
 
 void iriap_next_server_state(struct iriap_cb *self, IRIAP_STATE state)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	self->server_state = state;
@@ -119,7 +119,7 @@ void iriap_next_server_state(struct iriap_cb *self, IRIAP_STATE state)
 
 void iriap_next_r_connect_state(struct iriap_cb *self, IRIAP_STATE state)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	self->r_connect_state = state;
@@ -128,7 +128,7 @@ void iriap_next_r_connect_state(struct iriap_cb *self, IRIAP_STATE state)
 void iriap_do_client_event(struct iriap_cb *self, IRIAP_EVENT event,
 			   struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	(*iriap_state[ self->client_state]) (self, event, skb);
@@ -137,7 +137,7 @@ void iriap_do_client_event(struct iriap_cb *self, IRIAP_EVENT event,
 void iriap_do_call_event(struct iriap_cb *self, IRIAP_EVENT event,
 			 struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	(*iriap_state[ self->call_state]) (self, event, skb);
@@ -146,7 +146,7 @@ void iriap_do_call_event(struct iriap_cb *self, IRIAP_EVENT event,
 void iriap_do_server_event(struct iriap_cb *self, IRIAP_EVENT event,
 			   struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	(*iriap_state[ self->server_state]) (self, event, skb);
@@ -155,7 +155,7 @@ void iriap_do_server_event(struct iriap_cb *self, IRIAP_EVENT event,
 void iriap_do_r_connect_event(struct iriap_cb *self, IRIAP_EVENT event,
 			      struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	(*iriap_state[ self->r_connect_state]) (self, event, skb);
@@ -171,13 +171,13 @@ void iriap_do_r_connect_event(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 			       struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	switch (event) {
 	case IAP_CALL_REQUEST_GVBC:
 		iriap_next_client_state(self, S_CONNECTING);
-		IRDA_ASSERT(self->request_skb == NULL, return;);
+		IRDA_ASSERT(!self->request_skb, return;);
 		/* Don't forget to refcount it -
 		 * see iriap_getvaluebyclass_request(). */
 		skb_get(skb);
@@ -201,7 +201,7 @@ static void state_s_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_connecting(struct iriap_cb *self, IRIAP_EVENT event,
 			       struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	switch (event) {
@@ -234,7 +234,7 @@ static void state_s_connecting(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_call(struct iriap_cb *self, IRIAP_EVENT event,
 			 struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 
 	switch (event) {
 	case IAP_LM_DISCONNECT_INDICATION:
@@ -259,7 +259,7 @@ static void state_s_make_call(struct iriap_cb *self, IRIAP_EVENT event,
 {
 	struct sk_buff *tx_skb;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 
 	switch (event) {
 	case IAP_CALL_REQUEST:
@@ -297,7 +297,7 @@ static void state_s_calling(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_s_outstanding(struct iriap_cb *self, IRIAP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 
 	switch (event) {
 	case IAP_RECV_F_LST:
@@ -368,7 +368,7 @@ static void state_r_disconnect(struct iriap_cb *self, IRIAP_EVENT event,
 	switch (event) {
 	case IAP_LM_CONNECT_INDICATION:
 		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
-		if (tx_skb == NULL)
+		if (!tx_skb)
 			return;
 
 		/* Reserve space for MUX_CONTROL and LAP header */
@@ -458,8 +458,8 @@ static void state_r_receiving(struct iriap_cb *self, IRIAP_EVENT event,
 static void state_r_execute(struct iriap_cb *self, IRIAP_EVENT event,
 			    struct sk_buff *skb)
 {
-	IRDA_ASSERT(skb != NULL, return;);
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(skb, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
 
 	switch (event) {
diff --git a/drivers/staging/irda/net/irias_object.c b/drivers/staging/irda/net/irias_object.c
index 4db986b9d756..4c2c65e28836 100644
--- a/drivers/staging/irda/net/irias_object.c
+++ b/drivers/staging/irda/net/irias_object.c
@@ -64,8 +64,7 @@ struct ias_object *irias_new_object( char *name, int id)
 	 * than the objects spinlock. Never grap the objects spinlock
 	 * while holding any attrib spinlock (risk of deadlock). Jean II */
 	obj->attribs = hashbin_new(HB_LOCK);
-
-	if (obj->attribs == NULL) {
+	if (!obj->attribs) {
 		net_warn_ratelimited("%s(), Unable to allocate attribs!\n",
 				     __func__);
 		kfree(obj->name);
@@ -85,7 +84,7 @@ EXPORT_SYMBOL(irias_new_object);
  */
 static void __irias_delete_attrib(struct ias_attrib *attrib)
 {
-	IRDA_ASSERT(attrib != NULL, return;);
+	IRDA_ASSERT(attrib, return;);
 	IRDA_ASSERT(attrib->magic == IAS_ATTRIB_MAGIC, return;);
 
 	kfree(attrib->name);
@@ -98,7 +97,7 @@ static void __irias_delete_attrib(struct ias_attrib *attrib)
 
 void __irias_delete_object(struct ias_object *obj)
 {
-	IRDA_ASSERT(obj != NULL, return;);
+	IRDA_ASSERT(obj, return;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return;);
 
 	kfree(obj->name);
@@ -121,7 +120,7 @@ int irias_delete_object(struct ias_object *obj)
 {
 	struct ias_object *node;
 
-	IRDA_ASSERT(obj != NULL, return -1;);
+	IRDA_ASSERT(obj, return -1;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return -1;);
 
 	/* Remove from list */
@@ -149,9 +148,9 @@ int irias_delete_attrib(struct ias_object *obj, struct ias_attrib *attrib,
 {
 	struct ias_attrib *node;
 
-	IRDA_ASSERT(obj != NULL, return -1;);
+	IRDA_ASSERT(obj, return -1;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return -1;);
-	IRDA_ASSERT(attrib != NULL, return -1;);
+	IRDA_ASSERT(attrib, return -1;);
 
 	/* Remove attribute from object */
 	node = hashbin_remove_this(obj->attribs, (irda_queue_t *) attrib);
@@ -181,7 +180,7 @@ int irias_delete_attrib(struct ias_object *obj, struct ias_attrib *attrib,
  */
 void irias_insert_object(struct ias_object *obj)
 {
-	IRDA_ASSERT(obj != NULL, return;);
+	IRDA_ASSERT(obj, return;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return;);
 
 	hashbin_insert(irias_objects, (irda_queue_t *) obj, 0, obj->name);
@@ -196,7 +195,7 @@ EXPORT_SYMBOL(irias_insert_object);
  */
 struct ias_object *irias_find_object(char *name)
 {
-	IRDA_ASSERT(name != NULL, return NULL;);
+	IRDA_ASSERT(name, return NULL;);
 
 	/* Unsafe (locking), object might change */
 	return hashbin_lock_find(irias_objects, 0, name);
@@ -213,12 +212,12 @@ struct ias_attrib *irias_find_attrib(struct ias_object *obj, char *name)
 {
 	struct ias_attrib *attrib;
 
-	IRDA_ASSERT(obj != NULL, return NULL;);
+	IRDA_ASSERT(obj, return NULL;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return NULL;);
-	IRDA_ASSERT(name != NULL, return NULL;);
+	IRDA_ASSERT(name, return NULL;);
 
 	attrib = hashbin_lock_find(obj->attribs, 0, name);
-	if (attrib == NULL)
+	if (!attrib)
 		return NULL;
 
 	/* Unsafe (locking), attrib might change */
@@ -234,10 +233,9 @@ struct ias_attrib *irias_find_attrib(struct ias_object *obj, char *name)
 static void irias_add_attrib(struct ias_object *obj, struct ias_attrib *attrib,
 			     int owner)
 {
-	IRDA_ASSERT(obj != NULL, return;);
+	IRDA_ASSERT(obj, return;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return;);
-
-	IRDA_ASSERT(attrib != NULL, return;);
+	IRDA_ASSERT(attrib, return;);
 	IRDA_ASSERT(attrib->magic == IAS_ATTRIB_MAGIC, return;);
 
 	/* Set if attrib is owned by kernel or user space */
@@ -261,7 +259,7 @@ int irias_object_change_attribute(char *obj_name, char *attrib_name,
 
 	/* Find object */
 	obj = hashbin_lock_find(irias_objects, 0, obj_name);
-	if (obj == NULL) {
+	if (!obj) {
 		net_warn_ratelimited("%s: Unable to find object: %s\n",
 				     __func__, obj_name);
 		return -1;
@@ -272,7 +270,7 @@ int irias_object_change_attribute(char *obj_name, char *attrib_name,
 
 	/* Find attribute */
 	attrib = hashbin_find(obj->attribs, 0, attrib_name);
-	if (attrib == NULL) {
+	if (!attrib) {
 		net_warn_ratelimited("%s: Unable to find attribute: %s\n",
 				     __func__, attrib_name);
 		spin_unlock_irqrestore(&obj->attribs->hb_spinlock, flags);
@@ -309,9 +307,9 @@ void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
 {
 	struct ias_attrib *attrib;
 
-	IRDA_ASSERT(obj != NULL, return;);
+	IRDA_ASSERT(obj, return;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return;);
-	IRDA_ASSERT(name != NULL, return;);
+	IRDA_ASSERT(name, return;);
 
 	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
 	if (!attrib)
@@ -348,11 +346,10 @@ void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
 {
 	struct ias_attrib *attrib;
 
-	IRDA_ASSERT(obj != NULL, return;);
+	IRDA_ASSERT(obj, return;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return;);
-
-	IRDA_ASSERT(name != NULL, return;);
-	IRDA_ASSERT(octets != NULL, return;);
+	IRDA_ASSERT(name, return;);
+	IRDA_ASSERT(octets, return;);
 
 	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
 	if (!attrib)
@@ -387,11 +384,10 @@ void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
 {
 	struct ias_attrib *attrib;
 
-	IRDA_ASSERT(obj != NULL, return;);
+	IRDA_ASSERT(obj, return;);
 	IRDA_ASSERT(obj->magic == IAS_OBJECT_MAGIC, return;);
-
-	IRDA_ASSERT(name != NULL, return;);
-	IRDA_ASSERT(value != NULL, return;);
+	IRDA_ASSERT(name, return;);
+	IRDA_ASSERT(value, return;);
 
 	attrib = kzalloc(sizeof(*attrib), GFP_ATOMIC);
 	if (!attrib)
@@ -426,7 +422,7 @@ struct ias_value *irias_new_integer_value(int integer)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(*value), GFP_ATOMIC);
-	if (value == NULL)
+	if (!value)
 		return NULL;
 
 	value->type = IAS_INTEGER;
@@ -449,7 +445,7 @@ struct ias_value *irias_new_string_value(char *string)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(*value), GFP_ATOMIC);
-	if (value == NULL)
+	if (!value)
 		return NULL;
 
 	value->type = IAS_STRING;
@@ -477,7 +473,7 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(*value), GFP_ATOMIC);
-	if (value == NULL)
+	if (!value)
 		return NULL;
 
 	value->type = IAS_OCT_SEQ;
@@ -487,7 +483,7 @@ struct ias_value *irias_new_octseq_value(__u8 *octseq , int len)
 	value->len = len;
 
 	value->t.oct_seq = kmemdup(octseq, len, GFP_ATOMIC);
-	if (value->t.oct_seq == NULL){
+	if (!value->t.oct_seq) {
 		kfree(value);
 		return NULL;
 	}
@@ -499,7 +495,7 @@ struct ias_value *irias_new_missing_value(void)
 	struct ias_value *value;
 
 	value = kzalloc(sizeof(*value), GFP_ATOMIC);
-	if (value == NULL)
+	if (!value)
 		return NULL;
 
 	value->type = IAS_MISSING;
@@ -515,7 +511,7 @@ struct ias_value *irias_new_missing_value(void)
  */
 void irias_delete_value(struct ias_value *value)
 {
-	IRDA_ASSERT(value != NULL, return;);
+	IRDA_ASSERT(value, return;);
 
 	switch (value->type) {
 	case IAS_INTEGER: /* Fallthrough */
diff --git a/drivers/staging/irda/net/irlap.c b/drivers/staging/irda/net/irlap.c
index 5dea721f44ac..715cedab2f41 100644
--- a/drivers/staging/irda/net/irlap.c
+++ b/drivers/staging/irda/net/irlap.c
@@ -82,7 +82,7 @@ int __init irlap_init(void)
 
 	/* Allocate master array */
 	irlap = hashbin_new(HB_LOCK);
-	if (irlap == NULL) {
+	if (!irlap) {
 		net_err_ratelimited("%s: can't allocate irlap hashbin!\n",
 				    __func__);
 		return -ENOMEM;
@@ -93,7 +93,7 @@ int __init irlap_init(void)
 
 void irlap_cleanup(void)
 {
-	IRDA_ASSERT(irlap != NULL, return;);
+	IRDA_ASSERT(irlap, return;);
 
 	hashbin_delete(irlap, (FREE_FUNC) __irlap_close);
 }
@@ -111,7 +111,7 @@ struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
 
 	/* Initialize the irlap structure. */
 	self = kzalloc(sizeof(*self), GFP_KERNEL);
-	if (self == NULL)
+	if (!self)
 		return NULL;
 
 	self->magic = LAP_MAGIC;
@@ -120,11 +120,10 @@ struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
 	self->netdev = dev;
 	self->qos_dev = qos;
 	/* Copy hardware name */
-	if(hw_name != NULL) {
+	if (hw_name)
 		strlcpy(self->hw_name, hw_name, sizeof(self->hw_name));
-	} else {
+	else
 		self->hw_name[0] = '\0';
-	}
 
 	/* FIXME: should we get our own field? */
 	dev->atalk_ptr = self;
@@ -179,7 +178,7 @@ EXPORT_SYMBOL(irlap_open);
  */
 static void __irlap_close(struct irlap_cb *self)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Stop timers */
@@ -209,7 +208,7 @@ void irlap_close(struct irlap_cb *self)
 {
 	struct irlap_cb *lap;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* We used to send a LAP_DISC_INDICATION here, but this was
@@ -238,7 +237,7 @@ EXPORT_SYMBOL(irlap_close);
  */
 void irlap_connect_indication(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlap_init_qos_capabilities(self, NULL); /* No user QoS! */
@@ -270,7 +269,7 @@ void irlap_connect_request(struct irlap_cb *self, __u32 daddr,
 {
 	pr_debug("%s(), daddr=0x%08x\n", __func__, daddr);
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	self->daddr = daddr;
@@ -295,7 +294,7 @@ void irlap_connect_request(struct irlap_cb *self, __u32 daddr,
  */
 void irlap_connect_confirm(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlmp_link_connect_confirm(self->notify.instance, &self->qos_tx, skb);
@@ -327,7 +326,7 @@ void irlap_data_indication(struct irlap_cb *self, struct sk_buff *skb,
 void irlap_data_request(struct irlap_cb *self, struct sk_buff *skb,
 			int unreliable)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	IRDA_ASSERT(skb_headroom(skb) >= (LAP_ADDR_HEADER+LAP_CTRL_HEADER),
@@ -372,7 +371,7 @@ void irlap_data_request(struct irlap_cb *self, struct sk_buff *skb,
 #ifdef CONFIG_IRDA_ULTRA
 void irlap_unitdata_request(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	IRDA_ASSERT(skb_headroom(skb) >= (LAP_ADDR_HEADER+LAP_CTRL_HEADER),
@@ -399,9 +398,9 @@ void irlap_unitdata_request(struct irlap_cb *self, struct sk_buff *skb)
 #ifdef CONFIG_IRDA_ULTRA
 void irlap_unitdata_indication(struct irlap_cb *self, struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	/* Hide LAP header from IrLMP layer */
 	skb_pull(skb, LAP_ADDR_HEADER+LAP_CTRL_HEADER);
@@ -417,7 +416,7 @@ void irlap_unitdata_indication(struct irlap_cb *self, struct sk_buff *skb)
  */
 void irlap_disconnect_request(struct irlap_cb *self)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Don't disconnect until all data frames are successfully sent */
@@ -452,7 +451,7 @@ void irlap_disconnect_indication(struct irlap_cb *self, LAP_REASON reason)
 {
 	pr_debug("%s(), reason=%s\n", __func__, lap_reasons[reason]);
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Flush queues */
@@ -486,9 +485,9 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 {
 	struct irlap_info info;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(discovery != NULL, return;);
+	IRDA_ASSERT(discovery, return;);
 
 	pr_debug("%s(), nslots = %d\n", __func__, discovery->nslots);
 
@@ -512,15 +511,14 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
 
 	/* Check if last discovery request finished in time, or if
 	 * it was aborted due to the media busy flag. */
-	if (self->discovery_log != NULL) {
+	if (self->discovery_log) {
 		hashbin_delete(self->discovery_log, (FREE_FUNC) kfree);
 		self->discovery_log = NULL;
 	}
 
 	/* All operations will occur at predictable time, no need to lock */
 	self->discovery_log = hashbin_new(HB_NOLOCK);
-
-	if (self->discovery_log == NULL) {
+	if (!self->discovery_log) {
 		net_warn_ratelimited("%s(), Unable to allocate discovery log!\n",
 				     __func__);
 		return;
@@ -546,10 +544,10 @@ void irlap_discovery_request(struct irlap_cb *self, discovery_t *discovery)
  */
 void irlap_discovery_confirm(struct irlap_cb *self, hashbin_t *discovery_log)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
-	IRDA_ASSERT(self->notify.instance != NULL, return;);
+	IRDA_ASSERT(self->notify.instance, return;);
 
 	/*
 	 * Check for successful discovery, since we are then allowed to clear
@@ -577,11 +575,11 @@ void irlap_discovery_confirm(struct irlap_cb *self, hashbin_t *discovery_log)
  */
 void irlap_discovery_indication(struct irlap_cb *self, discovery_t *discovery)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(discovery != NULL, return;);
+	IRDA_ASSERT(discovery, return;);
 
-	IRDA_ASSERT(self->notify.instance != NULL, return;);
+	IRDA_ASSERT(self->notify.instance, return;);
 
 	/* A device is very likely to connect immediately after it performs
 	 * a successful discovery. This means that in our case, we are much
@@ -621,7 +619,7 @@ void irlap_status_indication(struct irlap_cb *self, int quality_of_link)
  */
 void irlap_reset_indication(struct irlap_cb *self)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	if (self->state == LAP_RESET_WAIT)
@@ -691,8 +689,7 @@ void irlap_update_nr_received(struct irlap_cb *self, int nr)
 		self->va = nr - 1;
 	} else {
 		/* Remove all acknowledged frames in current window */
-		while ((skb_peek(&self->wx_list) != NULL) &&
-		       (((self->va+1) % 8) != nr))
+		while (skb_peek(&self->wx_list) && (((self->va + 1) % 8) != nr))
 		{
 			skb = skb_dequeue(&self->wx_list);
 			dev_kfree_skb(skb);
@@ -762,7 +759,7 @@ int irlap_validate_nr_received(struct irlap_cb *self, int nr)
  */
 void irlap_initiate_connection_state(struct irlap_cb *self)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Next to send and next to receive */
@@ -818,7 +815,7 @@ void irlap_flush_all_queues(struct irlap_cb *self)
 {
 	struct sk_buff* skb;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Free transmission queue */
@@ -845,7 +842,7 @@ static void irlap_change_speed(struct irlap_cb *self, __u32 speed, int now)
 
 	pr_debug("%s(), setting speed to %d\n", __func__, speed);
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	self->speed = speed;
@@ -870,9 +867,9 @@ static void irlap_change_speed(struct irlap_cb *self, __u32 speed, int now)
 static void irlap_init_qos_capabilities(struct irlap_cb *self,
 					struct qos_info *qos_user)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(self->netdev != NULL, return;);
+	IRDA_ASSERT(self->netdev, return;);
 
 	/* Start out with the maximum QoS support possible */
 	irda_init_max_qos_capabilies(&self->qos_rx);
@@ -916,7 +913,7 @@ static void irlap_init_qos_capabilities(struct irlap_cb *self,
  */
 void irlap_apply_default_connection_parameters(struct irlap_cb *self)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* xbofs : Default value in NDM */
@@ -977,7 +974,7 @@ void irlap_apply_default_connection_parameters(struct irlap_cb *self)
  */
 void irlap_apply_connection_parameters(struct irlap_cb *self, int now)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Set the negotiated xbofs value */
@@ -1189,7 +1186,7 @@ static const struct seq_operations irlap_seq_ops = {
 
 static int irlap_seq_open(struct inode *inode, struct file *file)
 {
-	if (irlap == NULL)
+	if (!irlap)
 		return -EINVAL;
 
 	return seq_open_private(file, &irlap_seq_ops,
diff --git a/drivers/staging/irda/net/irlap_event.c b/drivers/staging/irda/net/irlap_event.c
index 0e1b4d79f745..22c44b010976 100644
--- a/drivers/staging/irda/net/irlap_event.c
+++ b/drivers/staging/irda/net/irlap_event.c
@@ -167,7 +167,7 @@ static void irlap_poll_timer_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlap_do_event(self, POLL_TIMER_EXPIRED, NULL, NULL);
@@ -181,7 +181,7 @@ static void irlap_poll_timer_expired(void *data)
  */
 static void irlap_start_poll_timer(struct irlap_cb *self, int timeout)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 #ifdef CONFIG_IRDA_FAST_RR
@@ -327,12 +327,12 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 	discovery_t *discovery_rsp;
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
 	case CONNECT_REQUEST:
-		IRDA_ASSERT(self->netdev != NULL, return -1;);
+		IRDA_ASSERT(self->netdev, return -1;);
 
 		if (self->media_busy) {
 			/* Note : this will never happen, because we test
@@ -370,7 +370,7 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	case DISCOVERY_REQUEST:
-		IRDA_ASSERT(info != NULL, return -1;);
+		IRDA_ASSERT(info, return -1;);
 
 		if (self->media_busy) {
 			pr_debug("%s(), DISCOVERY_REQUEST: media busy!\n",
@@ -396,7 +396,7 @@ static int irlap_state_ndm(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_next_state(self, LAP_QUERY);
 		break;
 	case RECV_DISCOVERY_XID_CMD:
-		IRDA_ASSERT(info != NULL, return -1;);
+		IRDA_ASSERT(info, return -1;);
 
 		/* Assert that this is not the final slot */
 		if (info->s <= info->S) {
@@ -559,13 +559,13 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
 	case RECV_DISCOVERY_XID_RSP:
-		IRDA_ASSERT(info != NULL, return -1;);
-		IRDA_ASSERT(info->discovery != NULL, return -1;);
+		IRDA_ASSERT(info, return -1;);
+		IRDA_ASSERT(info->discovery, return -1;);
 
 		pr_debug("%s(), daddr=%08x\n", __func__,
 			 info->discovery->data.daddr);
@@ -595,7 +595,7 @@ static int irlap_state_query(struct irlap_cb *self, IRLAP_EVENT event,
 		 * Jean II
 		 */
 
-		IRDA_ASSERT(info != NULL, return -1;);
+		IRDA_ASSERT(info, return -1;);
 
 		pr_debug("%s(), Receiving discovery request (s = %d) while performing discovery :-(\n",
 			 __func__, info->s);
@@ -671,7 +671,7 @@ static int irlap_state_reply(struct irlap_cb *self, IRLAP_EVENT event,
 	discovery_t *discovery_rsp;
 	int ret=0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -681,7 +681,7 @@ static int irlap_state_reply(struct irlap_cb *self, IRLAP_EVENT event,
 		irlap_next_state(self, LAP_NDM);
 		break;
 	case RECV_DISCOVERY_XID_CMD:
-		IRDA_ASSERT(info != NULL, return -1;);
+		IRDA_ASSERT(info, return -1;);
 		/* Last frame? */
 		if (info->s == 0xff) {
 			del_timer(&self->query_timer);
@@ -738,14 +738,14 @@ static int irlap_state_conn(struct irlap_cb *self, IRLAP_EVENT event,
 
 	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
 	case CONNECT_RESPONSE:
 		skb_pull(skb, sizeof(struct snrm_frame));
 
-		IRDA_ASSERT(self->netdev != NULL, return -1;);
+		IRDA_ASSERT(self->netdev, return -1;);
 
 		irlap_qos_negotiate(self, skb);
 
@@ -830,7 +830,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -859,8 +859,8 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 	case RECV_SNRM_CMD:
 		pr_debug("%s(), SNRM battle!\n", __func__);
 
-		IRDA_ASSERT(skb != NULL, return 0;);
-		IRDA_ASSERT(info != NULL, return 0;);
+		IRDA_ASSERT(skb, return 0;);
+		IRDA_ASSERT(info, return 0;);
 
 		/*
 		 *  The device with the largest device address wins the battle
@@ -870,7 +870,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 			del_timer(&self->final_timer);
 			irlap_initiate_connection_state(self);
 
-			IRDA_ASSERT(self->netdev != NULL, return -1;);
+			IRDA_ASSERT(self->netdev, return -1;);
 
 			skb_pull(skb, sizeof(struct snrm_frame));
 
@@ -906,7 +906,7 @@ static int irlap_state_setup(struct irlap_cb *self, IRLAP_EVENT event,
 
 		skb_pull(skb, sizeof(struct ua_frame));
 
-		IRDA_ASSERT(self->netdev != NULL, return -1;);
+		IRDA_ASSERT(self->netdev, return -1;);
 
 		irlap_qos_negotiate(self, skb);
 
@@ -1013,9 +1013,9 @@ static int irlap_state_xmit_p(struct irlap_cb *self, IRLAP_EVENT event,
 			 * end of the window and sending a extra RR.
 			 * Note : (skb_next != NULL) <=> (skb_queue_len() > 0)
 			 * Jean II */
-			nextfit = ((skb_next != NULL) &&
-				   ((skb_next->len + skb->len) <=
-				    self->bytes_left));
+			nextfit = skb_next &&
+				  (skb_next->len + skb->len)
+				  <= self->bytes_left;
 
 			/*
 			 * The current packet may not fit ! Because of test
@@ -1134,7 +1134,7 @@ static int irlap_state_pclose(struct irlap_cb *self, IRLAP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -1215,8 +1215,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		 */
 		self->fast_RR = FALSE;
 #endif /* CONFIG_IRDA_FAST_RR */
-		IRDA_ASSERT( info != NULL, return -1;);
-
+		IRDA_ASSERT(info, return -1;);
 		ns_status = irlap_validate_ns_received(self, info->ns);
 		nr_status = irlap_validate_nr_received(self, info->nr);
 
@@ -1449,7 +1448,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 			/* Start poll timer */
 			irlap_start_poll_timer(self, self->poll_timeout);
 		} else if (ret == NR_UNEXPECTED) {
-			IRDA_ASSERT(info != NULL, return -1;);
+			IRDA_ASSERT(info, return -1;);
 			/*
 			 *  Unexpected nr!
 			 */
@@ -1477,7 +1476,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 		}
 		break;
 	case RECV_RNR_RSP:
-		IRDA_ASSERT(info != NULL, return -1;);
+		IRDA_ASSERT(info, return -1;);
 
 		/* Stop final timer */
 		del_timer(&self->final_timer);
@@ -1519,7 +1518,7 @@ static int irlap_state_nrm_p(struct irlap_cb *self, IRLAP_EVENT event,
 
 		/* N2 is the disconnect timer. Until we reach it, we retry */
 		if (self->retry_count < self->N2) {
-			if (skb_peek(&self->wx_list) == NULL) {
+			if (!skb_peek(&self->wx_list)) {
 				/* Retry sending the pf bit to the secondary */
 				pr_debug("nrm_p: resending rr");
 				irlap_wait_min_turn_around(self, &self->qos_tx);
@@ -1603,7 +1602,7 @@ static int irlap_state_reset_wait(struct irlap_cb *self, IRLAP_EVENT event,
 
 	pr_debug("%s(), event = %s\n", __func__, irlap_event[event]);
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -1650,7 +1649,7 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 
 	pr_debug("%s(), event = %s\n", __func__, irlap_event[event]);
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -1684,7 +1683,7 @@ static int irlap_state_reset(struct irlap_cb *self, IRLAP_EVENT event,
 		if (self->retry_count < 3) {
 			irlap_wait_min_turn_around(self, &self->qos_tx);
 
-			IRDA_ASSERT(self->netdev != NULL, return -1;);
+			IRDA_ASSERT(self->netdev, return -1;);
 			irlap_send_snrm_frame(self, self->qos_dev);
 
 			self->retry_count++; /* Experimental!! */
@@ -1742,7 +1741,7 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 
 	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
-	IRDA_ASSERT(self != NULL, return -ENODEV;);
+	IRDA_ASSERT(self, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
 
 	switch (event) {
@@ -1766,9 +1765,9 @@ static int irlap_state_xmit_s(struct irlap_cb *self, IRLAP_EVENT event,
 			 * the current window (with respect to turnaround
 			 * time). - Jean II */
 			skb_next = skb_peek(&self->txq);
-			nextfit = ((skb_next != NULL) &&
-				   ((skb_next->len + skb->len) <=
-				    self->bytes_left));
+			nextfit = skb_next &&
+				  (skb_next->len + skb->len)
+				  <= self->bytes_left;
 
 			/*
 			 *  Test if we have transmitted more bytes over the
@@ -1864,7 +1863,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 
 	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -2215,7 +2214,7 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 			      struct sk_buff *skb, struct irlap_info *info)
 {
-	IRDA_ASSERT(self != NULL, return -ENODEV;);
+	IRDA_ASSERT(self, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
 
 	switch (event) {
@@ -2262,7 +2261,7 @@ static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 		/* IrLAP-1.1 p.82: in SCLOSE, basically any received frame
 		 * with pf=1 shall restart the wd-timer and resend the rd:rsp
 		 */
-		if (info != NULL  &&  info->pf) {
+		if (info && info->pf) {
 			del_timer(&self->wd_timer);
 			irlap_wait_min_turn_around(self, &self->qos_tx);
 			irlap_send_rd_frame(self);
@@ -2287,7 +2286,7 @@ static int irlap_state_reset_check( struct irlap_cb *self, IRLAP_EVENT event,
 
 	pr_debug("%s(), event=%s\n", __func__, irlap_event[event]);
 
-	IRDA_ASSERT(self != NULL, return -ENODEV;);
+	IRDA_ASSERT(self, return -ENODEV;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -EBADR;);
 
 	switch (event) {
diff --git a/drivers/staging/irda/net/irlap_frame.c b/drivers/staging/irda/net/irlap_frame.c
index d4d88a5d2976..94972db87951 100644
--- a/drivers/staging/irda/net/irlap_frame.c
+++ b/drivers/staging/irda/net/irlap_frame.c
@@ -123,7 +123,7 @@ void irlap_send_snrm_frame(struct irlap_cb *self, struct qos_info *qos)
 	struct snrm_frame *frame;
 	int ret;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
@@ -218,7 +218,7 @@ void irlap_send_ua_response_frame(struct irlap_cb *self, struct qos_info *qos)
 
 	pr_debug("%s() <%ld>\n", __func__, jiffies);
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/* Allocate frame */
@@ -261,7 +261,7 @@ void irlap_send_dm_frame( struct irlap_cb *self)
 	struct sk_buff *tx_skb = NULL;
 	struct dm_frame *frame;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	tx_skb = alloc_skb(sizeof(struct dm_frame), GFP_ATOMIC);
@@ -291,7 +291,7 @@ void irlap_send_disc_frame(struct irlap_cb *self)
 	struct sk_buff *tx_skb = NULL;
 	struct disc_frame *frame;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	tx_skb = alloc_skb(sizeof(struct disc_frame), GFP_ATOMIC);
@@ -323,9 +323,9 @@ void irlap_send_discovery_xid_frame(struct irlap_cb *self, int S, __u8 s,
 	pr_debug("%s(), s=%d, S=%d, command=%d\n", __func__,
 		 s, S, command);
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(discovery != NULL, return;);
+	IRDA_ASSERT(discovery, return;);
 
 	tx_skb = alloc_skb(sizeof(struct xid_frame) + IRLAP_DISCOVERY_INFO_LEN,
 			   GFP_ATOMIC);
@@ -412,7 +412,7 @@ static void irlap_recv_discovery_xid_rsp(struct irlap_cb *self,
 	__u8 *discovery_info;
 	char *text;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	if (!pskb_may_pull(skb, sizeof(struct xid_frame))) {
@@ -528,8 +528,7 @@ static void irlap_recv_discovery_xid_cmd(struct irlap_cb *self,
 	 */
 	if (info->s == 0xff) {
 		/* Check if things are sane at this point... */
-		if((discovery_info == NULL) ||
-		   !pskb_may_pull(skb, 3)) {
+		if (!discovery_info || !pskb_may_pull(skb, 3)) {
 			net_err_ratelimited("%s: discovery frame too short!\n",
 					    __func__);
 			return;
@@ -732,9 +731,8 @@ void irlap_send_data_primary(struct irlap_cb *self, struct sk_buff *skb)
 
 		/* Copy buffer */
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
-		if (tx_skb == NULL) {
+		if (!tx_skb)
 			return;
-		}
 
 		self->vs = (self->vs + 1) % 8;
 		self->ack_required = FALSE;
@@ -778,9 +776,8 @@ void irlap_send_data_primary_poll(struct irlap_cb *self, struct sk_buff *skb)
 
 		/* Copy buffer */
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
-		if (tx_skb == NULL) {
+		if (!tx_skb)
 			return;
-		}
 
 		/*
 		 *  Set poll bit if necessary. We do this to the copied
@@ -867,9 +864,9 @@ void irlap_send_data_secondary_final(struct irlap_cb *self,
 {
 	struct sk_buff *tx_skb = NULL;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	/* Is this reliable or unreliable data? */
 	if (skb->data[1] == I_FRAME) {
@@ -888,9 +885,8 @@ void irlap_send_data_secondary_final(struct irlap_cb *self,
 		skb_queue_tail(&self->wx_list, skb);
 
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
-		if (tx_skb == NULL) {
+		if (!tx_skb)
 			return;
-		}
 
 		tx_skb->data[1] |= PF_BIT;
 
@@ -945,9 +941,8 @@ void irlap_send_data_secondary(struct irlap_cb *self, struct sk_buff *skb)
 		skb_queue_tail(&self->wx_list, skb);
 
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
-		if (tx_skb == NULL) {
+		if (!tx_skb)
 			return;
-		}
 
 		self->vs = (self->vs + 1) % 8;
 		self->ack_required = FALSE;
@@ -972,7 +967,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 	struct sk_buff *tx_skb;
 	struct sk_buff *skb;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/*  Resend unacknowledged frame(s) */
@@ -1011,7 +1006,7 @@ void irlap_resend_rejected_frames(struct irlap_cb *self, int command)
 		pr_debug("%s(), sending additional frames!\n", __func__);
 		if (self->window > 0) {
 			skb = skb_dequeue( &self->txq);
-			IRDA_ASSERT(skb != NULL, return;);
+			IRDA_ASSERT(skb, return;);
 
 			/*
 			 *  If send window > 1 then send frame with pf
@@ -1034,12 +1029,12 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 	struct sk_buff *tx_skb;
 	struct sk_buff *skb;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	/*  Resend unacknowledged frame(s) */
 	skb = skb_peek(&self->wx_list);
-	if (skb != NULL) {
+	if (skb) {
 		irlap_wait_min_turn_around(self, &self->qos_tx);
 
 		/* We copy the skb to be retransmitted since we will have to
@@ -1071,9 +1066,9 @@ void irlap_resend_rejected_frame(struct irlap_cb *self, int command)
 void irlap_send_ui_frame(struct irlap_cb *self, struct sk_buff *skb,
 			 __u8 caddr, int command)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	/* Insert connection address */
 	skb->data[0] = caddr | ((command) ? CMD_FRAME : 0);
@@ -1146,10 +1141,10 @@ static void irlap_recv_frmr_frame(struct irlap_cb *self, struct sk_buff *skb,
 	__u8 *frame;
 	int w, x, y, z;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
-	IRDA_ASSERT(info != NULL, return;);
+	IRDA_ASSERT(skb, return;);
+	IRDA_ASSERT(info, return;);
 
 	if (!pskb_may_pull(skb, 4)) {
 		net_err_ratelimited("%s: frame too short!\n", __func__);
diff --git a/drivers/staging/irda/net/irlmp.c b/drivers/staging/irda/net/irlmp.c
index f075735e4b9b..318660fbc094 100644
--- a/drivers/staging/irda/net/irlmp.c
+++ b/drivers/staging/irda/net/irlmp.c
@@ -85,7 +85,7 @@ int __init irlmp_init(void)
 {
 	/* Initialize the irlmp structure. */
 	irlmp = kzalloc( sizeof(struct irlmp_cb), GFP_KERNEL);
-	if (irlmp == NULL)
+	if (!irlmp)
 		return -ENOMEM;
 
 	irlmp->magic = LMP_MAGIC;
@@ -95,14 +95,12 @@ int __init irlmp_init(void)
 	irlmp->links = hashbin_new(HB_LOCK);
 	irlmp->unconnected_lsaps = hashbin_new(HB_LOCK);
 	irlmp->cachelog = hashbin_new(HB_NOLOCK);
-
-	if ((irlmp->clients == NULL) ||
-	    (irlmp->services == NULL) ||
-	    (irlmp->links == NULL) ||
-	    (irlmp->unconnected_lsaps == NULL) ||
-	    (irlmp->cachelog == NULL)) {
+	if (!irlmp->clients ||
+	    !irlmp->services ||
+	    !irlmp->links ||
+	    !irlmp->unconnected_lsaps ||
+	    !irlmp->cachelog)
 		return -ENOMEM;
-	}
 
 	spin_lock_init(&irlmp->cachelog->hb_spinlock);
 
@@ -128,7 +126,7 @@ int __init irlmp_init(void)
 void irlmp_cleanup(void)
 {
 	/* Check for main structure */
-	IRDA_ASSERT(irlmp != NULL, return;);
+	IRDA_ASSERT(irlmp, return;);
 	IRDA_ASSERT(irlmp->magic == LMP_MAGIC, return;);
 
 	del_timer(&irlmp->discovery_timer);
@@ -154,10 +152,10 @@ struct lsap_cb *irlmp_open_lsap(__u8 slsap_sel, notify_t *notify, __u8 pid)
 {
 	struct lsap_cb *self;
 
-	IRDA_ASSERT(notify != NULL, return NULL;);
-	IRDA_ASSERT(irlmp != NULL, return NULL;);
+	IRDA_ASSERT(notify, return NULL;);
+	IRDA_ASSERT(irlmp, return NULL;);
 	IRDA_ASSERT(irlmp->magic == LMP_MAGIC, return NULL;);
-	IRDA_ASSERT(notify->instance != NULL, return NULL;);
+	IRDA_ASSERT(notify->instance, return NULL;);
 
 	/*  Does the client care which Source LSAP selector it gets?  */
 	if (slsap_sel == LSAP_ANY) {
@@ -169,7 +167,7 @@ struct lsap_cb *irlmp_open_lsap(__u8 slsap_sel, notify_t *notify, __u8 pid)
 
 	/* Allocate new instance of a LSAP connection */
 	self = kzalloc(sizeof(*self), GFP_ATOMIC);
-	if (self == NULL)
+	if (!self)
 		return NULL;
 
 	self->magic = LMP_LSAP_MAGIC;
@@ -206,7 +204,7 @@ EXPORT_SYMBOL(irlmp_open_lsap);
  */
 static void __irlmp_close_lsap(struct lsap_cb *self)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
 	/*
@@ -232,7 +230,7 @@ void irlmp_close_lsap(struct lsap_cb *self)
 	struct lap_cb *lap;
 	struct lsap_cb *lsap = NULL;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
 	/*
@@ -283,15 +281,15 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 {
 	struct lap_cb *lap;
 
-	IRDA_ASSERT(irlmp != NULL, return;);
+	IRDA_ASSERT(irlmp, return;);
 	IRDA_ASSERT(irlmp->magic == LMP_MAGIC, return;);
-	IRDA_ASSERT(notify != NULL, return;);
+	IRDA_ASSERT(notify, return;);
 
 	/*
 	 *  Allocate new instance of a LSAP connection
 	 */
 	lap = kzalloc(sizeof(*lap), GFP_KERNEL);
-	if (lap == NULL)
+	if (!lap)
 		return;
 
 	lap->irlap = irlap;
@@ -302,7 +300,7 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 	lap->cache.valid = FALSE;
 #endif
 	lap->lsaps = hashbin_new(HB_LOCK);
-	if (lap->lsaps == NULL) {
+	if (!lap->lsaps) {
 		net_warn_ratelimited("%s(), unable to kmalloc lsaps\n",
 				     __func__);
 		kfree(lap);
@@ -374,7 +372,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 	struct lsap_cb *lsap;
 	int ret;
 
-	IRDA_ASSERT(self != NULL, return -EBADR;);
+	IRDA_ASSERT(self, return -EBADR;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -EBADR;);
 
 	pr_debug("%s(), slsap_sel=%02x, dlsap_sel=%02x, saddr=%08x, daddr=%08x\n",
@@ -392,7 +390,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 	}
 
 	/* Any userdata? */
-	if (tx_skb == NULL) {
+	if (!tx_skb) {
 		tx_skb = alloc_skb(LMP_MAX_HEADER, GFP_ATOMIC);
 		if (!tx_skb)
 			return -ENOMEM;
@@ -434,7 +432,7 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 		spin_unlock_irqrestore(&irlmp->cachelog->hb_spinlock, flags);
 	}
 	lap = hashbin_lock_find(irlmp->links, saddr, NULL);
-	if (lap == NULL) {
+	if (!lap) {
 		pr_debug("%s(), Unable to find a usable link!\n", __func__);
 		ret = -EHOSTUNREACH;
 		goto err;
@@ -471,9 +469,9 @@ int irlmp_connect_request(struct lsap_cb *self, __u8 dlsap_sel,
 	 */
 	lsap = hashbin_remove(irlmp->unconnected_lsaps, (long) self, NULL);
 
-	IRDA_ASSERT(lsap != NULL, return -1;);
+	IRDA_ASSERT(lsap, return -1;);
 	IRDA_ASSERT(lsap->magic == LMP_LSAP_MAGIC, return -1;);
-	IRDA_ASSERT(lsap->lap != NULL, return -1;);
+	IRDA_ASSERT(lsap->lap, return -1;);
 	IRDA_ASSERT(lsap->lap->magic == LMP_LAP_MAGIC, return -1;);
 
 	hashbin_insert(self->lap->lsaps, (irda_queue_t *) self, (long) self,
@@ -514,10 +512,10 @@ void irlmp_connect_indication(struct lsap_cb *self, struct sk_buff *skb)
 	int lap_header_size;
 	int max_header_size;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
-	IRDA_ASSERT(self->lap != NULL, return;);
+	IRDA_ASSERT(skb, return;);
+	IRDA_ASSERT(self->lap, return;);
 
 	pr_debug("%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
 		 __func__, self->slsap_sel, self->dlsap_sel);
@@ -553,9 +551,9 @@ void irlmp_connect_indication(struct lsap_cb *self, struct sk_buff *skb)
  */
 int irlmp_connect_response(struct lsap_cb *self, struct sk_buff *userdata)
 {
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
-	IRDA_ASSERT(userdata != NULL, return -1;);
+	IRDA_ASSERT(userdata, return -1;);
 
 	/* We set the connected bit and move the lsap to the connected list
 	 * in the state machine itself. Jean II */
@@ -587,10 +585,10 @@ void irlmp_connect_confirm(struct lsap_cb *self, struct sk_buff *skb)
 	int lap_header_size;
 	int max_seg_size;
 
-	IRDA_ASSERT(skb != NULL, return;);
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(skb, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
-	IRDA_ASSERT(self->lap != NULL, return;);
+	IRDA_ASSERT(self->lap, return;);
 
 	self->qos = *self->lap->qos;
 
@@ -630,7 +628,7 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	/* Only allowed to duplicate unconnected LSAP's, and only LSAPs
 	 * that have received a connect indication. Jean II */
 	if ((!hashbin_find(irlmp->unconnected_lsaps, (long) orig, NULL)) ||
-	    (orig->lap == NULL)) {
+	    (!orig->lap)) {
 		pr_debug("%s(), invalid LSAP (wrong state)\n",
 			 __func__);
 		spin_unlock_irqrestore(&irlmp->unconnected_lsaps->hb_spinlock,
@@ -677,9 +675,9 @@ int irlmp_disconnect_request(struct lsap_cb *self, struct sk_buff *userdata)
 {
 	struct lsap_cb *lsap;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
-	IRDA_ASSERT(userdata != NULL, return -1;);
+	IRDA_ASSERT(userdata, return -1;);
 
 	/* Already disconnected ?
 	 * There is a race condition between irlmp_disconnect_indication()
@@ -706,16 +704,16 @@ int irlmp_disconnect_request(struct lsap_cb *self, struct sk_buff *userdata)
 	 *  Remove LSAP from list of connected LSAPs for the particular link
 	 *  and insert it into the list of unconnected LSAPs
 	 */
-	IRDA_ASSERT(self->lap != NULL, return -1;);
+	IRDA_ASSERT(self->lap, return -1;);
 	IRDA_ASSERT(self->lap->magic == LMP_LAP_MAGIC, return -1;);
-	IRDA_ASSERT(self->lap->lsaps != NULL, return -1;);
+	IRDA_ASSERT(self->lap->lsaps, return -1;);
 
 	lsap = hashbin_remove(self->lap->lsaps, (long) self, NULL);
 #ifdef CONFIG_IRDA_CACHE_LAST_LSAP
 	self->lap->cache.valid = FALSE;
 #endif
 
-	IRDA_ASSERT(lsap != NULL, return -1;);
+	IRDA_ASSERT(lsap, return -1;);
 	IRDA_ASSERT(lsap->magic == LMP_LSAP_MAGIC, return -1;);
 	IRDA_ASSERT(lsap == self, return -1;);
 
@@ -742,7 +740,7 @@ void irlmp_disconnect_indication(struct lsap_cb *self, LM_REASON reason,
 
 	pr_debug("%s(), reason=%s [%d]\n", __func__,
 		 irlmp_reason_str(reason), reason);
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
 	pr_debug("%s(), slsap_sel=%02x, dlsap_sel=%02x\n",
@@ -760,15 +758,15 @@ void irlmp_disconnect_indication(struct lsap_cb *self, LM_REASON reason,
 	/*
 	 *  Remove association between this LSAP and the link it used
 	 */
-	IRDA_ASSERT(self->lap != NULL, return;);
-	IRDA_ASSERT(self->lap->lsaps != NULL, return;);
+	IRDA_ASSERT(self->lap, return;);
+	IRDA_ASSERT(self->lap->lsaps, return;);
 
 	lsap = hashbin_remove(self->lap->lsaps, (long) self, NULL);
 #ifdef CONFIG_IRDA_CACHE_LAST_LSAP
 	self->lap->cache.valid = FALSE;
 #endif
 
-	IRDA_ASSERT(lsap != NULL, return;);
+	IRDA_ASSERT(lsap, return;);
 	IRDA_ASSERT(lsap == self, return;);
 	hashbin_insert(irlmp->unconnected_lsaps, (irda_queue_t *) lsap,
 		       (long) lsap, NULL);
@@ -812,7 +810,7 @@ void irlmp_do_expiry(void)
 	 * to work properly. - Jean II
 	 */
 	lap = (struct lap_cb *) hashbin_get_first(irlmp->links);
-	while (lap != NULL) {
+	while (lap) {
 		IRDA_ASSERT(lap->magic == LMP_LAP_MAGIC, return;);
 
 		if (lap->lap_state == LAP_STANDBY) {
@@ -862,7 +860,7 @@ void irlmp_do_discovery(int nslots)
 	 * Try to send discovery packets on all links
 	 */
 	lap = (struct lap_cb *) hashbin_get_first(irlmp->links);
-	while (lap != NULL) {
+	while (lap) {
 		IRDA_ASSERT(lap->magic == LMP_LAP_MAGIC, return;);
 
 		if (lap->lap_state == LAP_STANDBY) {
@@ -983,7 +981,7 @@ irlmp_notify_client(irlmp_client_t *client,
 					     client->hint_mask.word,
 					     (mode == DISCOVERY_LOG));
 	/* Check if the we got some results */
-	if (discoveries == NULL)
+	if (!discoveries)
 		return;	/* No nodes discovered */
 
 	/* Pass all entries to the listener */
@@ -1006,7 +1004,7 @@ void irlmp_discovery_confirm(hashbin_t *log, DISCOVERY_MODE mode)
 	irlmp_client_t *client;
 	irlmp_client_t *client_next;
 
-	IRDA_ASSERT(log != NULL, return;);
+	IRDA_ASSERT(log, return;);
 
 	if (!(HASHBIN_GET_SIZE(log)))
 		return;
@@ -1039,7 +1037,7 @@ void irlmp_discovery_expiry(discinfo_t *expiries, int number)
 	irlmp_client_t *client_next;
 	int		i;
 
-	IRDA_ASSERT(expiries != NULL, return;);
+	IRDA_ASSERT(expiries, return;);
 
 	/* For each client - notify callback may touch client list */
 	client = (irlmp_client_t *) hashbin_get_first(irlmp->clients);
@@ -1071,7 +1069,7 @@ void irlmp_discovery_expiry(discinfo_t *expiries, int number)
  */
 discovery_t *irlmp_get_discovery_response(void)
 {
-	IRDA_ASSERT(irlmp != NULL, return NULL;);
+	IRDA_ASSERT(irlmp, return NULL;);
 
 	put_unaligned(irlmp->hints.word, (__u16 *)irlmp->discovery_rsp.data.hints);
 
@@ -1106,7 +1104,7 @@ int irlmp_data_request(struct lsap_cb *self, struct sk_buff *userdata)
 {
 	int	ret;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
 	/* Make room for MUX header */
@@ -1147,7 +1145,7 @@ int irlmp_udata_request(struct lsap_cb *self, struct sk_buff *userdata)
 {
 	int	ret;
 
-	IRDA_ASSERT(userdata != NULL, return -1;);
+	IRDA_ASSERT(userdata, return -1;);
 
 	/* Make room for MUX header */
 	IRDA_ASSERT(skb_headroom(userdata) >= LMP_HEADER, return -1;);
@@ -1169,9 +1167,9 @@ int irlmp_udata_request(struct lsap_cb *self, struct sk_buff *userdata)
  */
 void irlmp_udata_indication(struct lsap_cb *self, struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	/* Hide LMP header from layer above */
 	skb_pull(skb, LMP_HEADER);
@@ -1194,7 +1192,7 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 	struct sk_buff *clone_skb;
 	struct lap_cb *lap;
 
-	IRDA_ASSERT(userdata != NULL, return -1;);
+	IRDA_ASSERT(userdata, return -1;);
 
 	/* Make room for MUX and PID header */
 	IRDA_ASSERT(skb_headroom(userdata) >= LMP_HEADER+LMP_PID_HEADER,
@@ -1202,10 +1200,7 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 
 	/* Insert protocol identifier */
 	skb_push(userdata, LMP_PID_HEADER);
-	if(self != NULL)
-	  userdata->data[0] = self->pid;
-	else
-	  userdata->data[0] = pid;
+	userdata->data[0] = self ? self->pid : pid;
 
 	/* Connectionless sockets must use 0x70 */
 	skb_push(userdata, LMP_HEADER);
@@ -1213,7 +1208,7 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 
 	/* Try to send Connectionless  packets out on all links */
 	lap = (struct lap_cb *) hashbin_get_first(irlmp->links);
-	while (lap != NULL) {
+	while (lap) {
 		IRDA_ASSERT(lap->magic == LMP_LAP_MAGIC, return -1;);
 
 		clone_skb = skb_clone(userdata, GFP_ATOMIC);
@@ -1243,9 +1238,9 @@ int irlmp_connless_data_request(struct lsap_cb *self, struct sk_buff *userdata,
 #ifdef CONFIG_IRDA_ULTRA
 void irlmp_connless_data_indication(struct lsap_cb *self, struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	/* Hide LMP and PID header from layer above */
 	skb_pull(skb, LMP_HEADER+LMP_PID_HEADER);
@@ -1280,7 +1275,7 @@ void irlmp_status_indication(struct lap_cb *self,
 		/*
 		 *  Inform service user if he has requested it
 		 */
-		if (curr->notify.status_indication != NULL)
+		if (curr->notify.status_indication)
 			curr->notify.status_indication(curr->notify.instance,
 						       link, lock);
 		else
@@ -1323,20 +1318,20 @@ void irlmp_flow_indication(struct lap_cb *self, LOCAL_FLOW flow)
 		/* Try to find the next lsap we should poll. */
 		next = self->flow_next;
 		/* If we have no lsap, restart from first one */
-		if(next == NULL)
+		if (!next)
 			next = (struct lsap_cb *) hashbin_get_first(self->lsaps);
 		/* Verify current one and find the next one */
 		curr = hashbin_find_next(self->lsaps, (long) next, NULL,
 					 (void *) &self->flow_next);
 		/* Uh-oh... Paranoia */
-		if(curr == NULL)
+		if (!curr)
 			break;
 		pr_debug("%s() : curr is %p, next was %p and is now %p, still %d to go - queue len = %d\n",
 			 __func__, curr, next, self->flow_next, lsap_todo,
 			 IRLAP_GET_TX_QUEUE_LEN(self->irlap));
 
 		/* Inform lsap user that it can send one more packet. */
-		if (curr->notify.flow_indication != NULL)
+		if (curr->notify.flow_indication)
 			curr->notify.flow_indication(curr->notify.instance,
 						     curr, flow);
 		else
@@ -1534,7 +1529,7 @@ void *irlmp_register_client(__u16 hint_mask, DISCOVERY_CALLBACK1 disco_clb,
 {
 	irlmp_client_t *client;
 
-	IRDA_ASSERT(irlmp != NULL, return NULL;);
+	IRDA_ASSERT(irlmp, return NULL;);
 
 	/* Make a new registration */
 	client = kmalloc(sizeof(*client), GFP_ATOMIC);
@@ -1631,7 +1626,7 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 	struct lap_cb *lap;
 	unsigned long flags;
 
-	IRDA_ASSERT(irlmp != NULL, return TRUE;);
+	IRDA_ASSERT(irlmp, return TRUE;);
 	IRDA_ASSERT(irlmp->magic == LMP_MAGIC, return TRUE;);
 	IRDA_ASSERT(slsap_sel != LSAP_ANY, return TRUE;);
 
@@ -1653,7 +1648,7 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 	spin_lock_irqsave_nested(&irlmp->links->hb_spinlock, flags,
 			SINGLE_DEPTH_NESTING);
 	lap = (struct lap_cb *) hashbin_get_first(irlmp->links);
-	while (lap != NULL) {
+	while (lap) {
 		IRDA_ASSERT(lap->magic == LMP_LAP_MAGIC, goto errlap;);
 
 		/* Careful for priority inversions here !
@@ -1663,7 +1658,7 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 
 		/* For this IrLAP, check all the LSAPs */
 		self = (struct lsap_cb *) hashbin_get_first(lap->lsaps);
-		while (self != NULL) {
+		while (self) {
 			IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC,
 				    goto errlsap;);
 
@@ -1690,7 +1685,7 @@ static int irlmp_slsap_inuse(__u8 slsap_sel)
 	spin_lock_irqsave(&irlmp->unconnected_lsaps->hb_spinlock, flags);
 
 	self = (struct lsap_cb *) hashbin_get_first(irlmp->unconnected_lsaps);
-	while (self != NULL) {
+	while (self) {
 		IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, goto erruncon;);
 		if ((self->slsap_sel == slsap_sel)) {
 			pr_debug("Source LSAP selector=%02x in use (unconnected)\n",
@@ -1730,7 +1725,7 @@ static __u8 irlmp_find_free_slsap(void)
 	__u8 lsap_sel;
 	int wrapped = 0;
 
-	IRDA_ASSERT(irlmp != NULL, return -1;);
+	IRDA_ASSERT(irlmp, return -1;);
 	IRDA_ASSERT(irlmp->magic == LMP_MAGIC, return -1;);
 
 	/* Most users don't really care which LSAPs they are given,
@@ -1836,7 +1831,7 @@ static void *irlmp_seq_hb_idx(struct irlmp_iter_state *iter, loff_t *off)
 
 	spin_lock_irq(&iter->hashbin->hb_spinlock);
 	for (element = hashbin_get_first(iter->hashbin);
-	     element != NULL;
+	     element;
 	     element = hashbin_get_next(iter->hashbin)) {
 		if (!off || (*off)-- == 0) {
 			/* NB: hashbin left locked */
@@ -1889,8 +1884,7 @@ static void *irlmp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	}
 
 	v = hashbin_get_next(iter->hashbin);
-
-	if (v == NULL) {			/* no more in this hash bin */
+	if (!v) {			/* no more in this hash bin */
 		spin_unlock_irq(&iter->hashbin->hb_spinlock);
 
 		if (iter->hashbin == irlmp->unconnected_lsaps)
@@ -1947,7 +1941,7 @@ static int irlmp_seq_show(struct seq_file *seq, void *v)
 
 		seq_printf(seq, "\n  Connected LSAPs:\n");
 		for (self = (struct lsap_cb *) hashbin_get_first(lap->lsaps);
-		     self != NULL;
+		     self;
 		     self = (struct lsap_cb *)hashbin_get_next(lap->lsaps)) {
 			IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC,
 				    goto outloop;);
@@ -1978,7 +1972,7 @@ static const struct seq_operations irlmp_seq_ops = {
 
 static int irlmp_seq_open(struct inode *inode, struct file *file)
 {
-	IRDA_ASSERT(irlmp != NULL, return -EINVAL;);
+	IRDA_ASSERT(irlmp, return -EINVAL;);
 
 	return seq_open_private(file, &irlmp_seq_ops,
 			sizeof(struct irlmp_iter_state));
diff --git a/drivers/staging/irda/net/irlmp_event.c b/drivers/staging/irda/net/irlmp_event.c
index e306cf2c1e04..5856c8ed7dea 100644
--- a/drivers/staging/irda/net/irlmp_event.c
+++ b/drivers/staging/irda/net/irlmp_event.c
@@ -137,7 +137,7 @@ static inline void irlmp_next_lsap_state(struct lsap_cb *self,
 int irlmp_do_lsap_event(struct lsap_cb *self, IRLMP_EVENT event,
 			struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
 	pr_debug("%s(), EVENT = %s, STATE = %s\n",
@@ -155,7 +155,7 @@ int irlmp_do_lsap_event(struct lsap_cb *self, IRLMP_EVENT event,
 void irlmp_do_lap_event(struct lap_cb *self, IRLMP_EVENT event,
 			struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
 	pr_debug("%s(), EVENT = %s, STATE = %s\n", __func__,
@@ -180,7 +180,7 @@ void irlmp_watchdog_timer_expired(void *data)
 {
 	struct lsap_cb *self = (struct lsap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
 
 	irlmp_do_lsap_event(self, LM_WATCHDOG_TIMEOUT, NULL);
@@ -190,7 +190,7 @@ void irlmp_idle_timer_expired(void *data)
 {
 	struct lap_cb *self = (struct lap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
 	irlmp_do_lap_event(self, LM_LAP_IDLE_TIMEOUT, NULL);
@@ -248,7 +248,7 @@ irlmp_do_all_lsap_event(hashbin_t *	lsap_hashbin,
 static void irlmp_state_standby(struct lap_cb *self, IRLMP_EVENT event,
 				struct sk_buff *skb)
 {
-	IRDA_ASSERT(self->irlap != NULL, return;);
+	IRDA_ASSERT(self->irlap, return;);
 
 	switch (event) {
 	case LM_LAP_DISCOVERY_REQUEST:
@@ -479,7 +479,7 @@ static int irlmp_state_disconnected(struct lsap_cb *self, IRLMP_EVENT event,
 {
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -557,7 +557,7 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 	struct lsap_cb *lsap;
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -570,8 +570,8 @@ static int irlmp_state_connect(struct lsap_cb *self, IRLMP_EVENT event,
 				      NULL);
 
 		IRDA_ASSERT(lsap == self, return -1;);
-		IRDA_ASSERT(self->lap != NULL, return -1;);
-		IRDA_ASSERT(self->lap->lsaps != NULL, return -1;);
+		IRDA_ASSERT(self->lap, return -1;);
+		IRDA_ASSERT(self->lap->lsaps, return -1;);
 
 		hashbin_insert(self->lap->lsaps, (irda_queue_t *) self,
 			       (long) self, NULL);
@@ -617,7 +617,7 @@ static int irlmp_state_connect_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	struct sk_buff *tx_skb;
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -681,9 +681,9 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 	LM_REASON reason;
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
-	IRDA_ASSERT(self->lap != NULL, return -1;);
+	IRDA_ASSERT(self->lap, return -1;);
 
 	switch (event) {
 	case LM_DATA_REQUEST: /* Optimize for the common case */
@@ -694,7 +694,7 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 		irlmp_data_indication(self, skb);
 		break;
 	case LM_UDATA_REQUEST:
-		IRDA_ASSERT(skb != NULL, return -1;);
+		IRDA_ASSERT(skb, return -1;);
 		irlmp_send_data_pdu(self->lap, self->dlsap_sel,
 				    self->slsap_sel, TRUE, skb);
 		break;
@@ -737,10 +737,9 @@ static int irlmp_state_dtr(struct lsap_cb *self, IRLMP_EVENT event,
 	case LM_DISCONNECT_INDICATION:
 		irlmp_next_lsap_state(self, LSAP_DISCONNECTED);
 
-		IRDA_ASSERT(self->lap != NULL, return -1;);
+		IRDA_ASSERT(self->lap, return -1;);
 		IRDA_ASSERT(self->lap->magic == LMP_LAP_MAGIC, return -1;);
-
-		IRDA_ASSERT(skb != NULL, return -1;);
+		IRDA_ASSERT(skb, return -1;);
 		IRDA_ASSERT(skb->len > 3, return -1;);
 		reason = skb->data[3];
 
@@ -771,7 +770,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 	LM_REASON reason;
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return -1;);
 
 	switch (event) {
@@ -785,10 +784,9 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 	case LM_DISCONNECT_INDICATION:
 		irlmp_next_lsap_state(self, LSAP_DISCONNECTED);
 
-		IRDA_ASSERT(self->lap != NULL, return -1;);
+		IRDA_ASSERT(self->lap, return -1;);
 		IRDA_ASSERT(self->lap->magic == LMP_LAP_MAGIC, return -1;);
-
-		IRDA_ASSERT(skb != NULL, return -1;);
+		IRDA_ASSERT(skb, return -1;);
 		IRDA_ASSERT(skb->len > 3, return -1;);
 		reason = skb->data[3];
 
@@ -803,7 +801,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 
 		del_timer(&self->watchdog_timer);
 
-		IRDA_ASSERT(self->lap != NULL, return -1;);
+		IRDA_ASSERT(self->lap, return -1;);
 		IRDA_ASSERT(self->lap->magic == LMP_LAP_MAGIC, return -1;);
 
 		reason = irlmp_convert_lap_reason(self->lap->reason);
@@ -813,7 +811,7 @@ static int irlmp_state_setup(struct lsap_cb *self, IRLMP_EVENT event,
 	case LM_WATCHDOG_TIMEOUT:
 		pr_debug("%s() WATCHDOG_TIMEOUT!\n", __func__);
 
-		IRDA_ASSERT(self->lap != NULL, return -1;);
+		IRDA_ASSERT(self->lap, return -1;);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
 		irlmp_next_lsap_state(self, LSAP_DISCONNECTED);
 
@@ -842,12 +840,12 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	LM_REASON reason;
 	int ret = 0;
 
-	IRDA_ASSERT(self != NULL, return -1;);
-	IRDA_ASSERT(irlmp != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
+	IRDA_ASSERT(irlmp, return -1;);
 
 	switch (event) {
 	case LM_LAP_CONNECT_CONFIRM:
-		IRDA_ASSERT(self->conn_skb != NULL, return -1;);
+		IRDA_ASSERT(self->conn_skb, return -1;);
 
 		tx_skb = self->conn_skb;
 		self->conn_skb = NULL;
@@ -862,7 +860,7 @@ static int irlmp_state_setup_pend(struct lsap_cb *self, IRLMP_EVENT event,
 	case LM_WATCHDOG_TIMEOUT:
 		pr_debug("%s() : WATCHDOG_TIMEOUT !\n",  __func__);
 
-		IRDA_ASSERT(self->lap != NULL, return -1;);
+		IRDA_ASSERT(self->lap, return -1;);
 		irlmp_do_lap_event(self->lap, LM_LAP_DISCONNECT_REQUEST, NULL);
 		irlmp_next_lsap_state(self, LSAP_DISCONNECTED);
 
diff --git a/drivers/staging/irda/net/irlmp_frame.c b/drivers/staging/irda/net/irlmp_frame.c
index 38b0f994bc7b..abcbcc8c7a4c 100644
--- a/drivers/staging/irda/net/irlmp_frame.c
+++ b/drivers/staging/irda/net/irlmp_frame.c
@@ -60,9 +60,9 @@ void irlmp_send_lcf_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap,
 {
 	__u8 *frame;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	frame = skb->data;
 
@@ -93,7 +93,7 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 	__u8   dlsap_sel;   /* Destination LSAP address */
 	__u8   *fp;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 	IRDA_ASSERT(skb->len > 2, return;);
 
@@ -129,7 +129,7 @@ void irlmp_link_data_indication(struct lap_cb *self, struct sk_buff *skb,
 		lsap = irlmp_find_lsap(self, dlsap_sel, slsap_sel, 0,
 				       self->lsaps);
 
-	if (lsap == NULL) {
+	if (!lsap) {
 		pr_debug("IrLMP, Sorry, no LSAP for received frame!\n");
 		pr_debug("%s(), slsap_sel = %02x, dlsap_sel = %02x\n",
 			 __func__, slsap_sel, dlsap_sel);
@@ -202,7 +202,7 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 	__u8   *fp;
 	unsigned long flags;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 	IRDA_ASSERT(skb->len > 2, return;);
 
@@ -231,7 +231,7 @@ void irlmp_link_unitdata_indication(struct lap_cb *self, struct sk_buff *skb)
 	/* Search the connectionless LSAP */
 	spin_lock_irqsave(&irlmp->unconnected_lsaps->hb_spinlock, flags);
 	lsap = (struct lsap_cb *) hashbin_get_first(irlmp->unconnected_lsaps);
-	while (lsap != NULL) {
+	while (lsap) {
 		/*
 		 *  Check if source LSAP and dest LSAP selectors and PID match.
 		 */
@@ -264,7 +264,7 @@ void irlmp_link_disconnect_indication(struct lap_cb *lap,
 				      LAP_REASON reason,
 				      struct sk_buff *skb)
 {
-	IRDA_ASSERT(lap != NULL, return;);
+	IRDA_ASSERT(lap, return;);
 	IRDA_ASSERT(lap->magic == LMP_LAP_MAGIC, return;);
 
 	lap->reason = reason;
@@ -307,9 +307,9 @@ void irlmp_link_connect_indication(struct lap_cb *self, __u32 saddr,
 void irlmp_link_connect_confirm(struct lap_cb *self, struct qos_info *qos,
 				struct sk_buff *skb)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
-	IRDA_ASSERT(qos != NULL, return;);
+	IRDA_ASSERT(qos, return;);
 
 	/* Don't need use the skb for now */
 
@@ -350,7 +350,7 @@ void irlmp_link_connect_confirm(struct lap_cb *self, struct qos_info *qos,
 void irlmp_link_discovery_indication(struct lap_cb *self,
 				     discovery_t *discovery)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
 	/* Add to main log, cleanup */
@@ -371,7 +371,7 @@ void irlmp_link_discovery_indication(struct lap_cb *self,
  */
 void irlmp_link_discovery_confirm(struct lap_cb *self, hashbin_t *log)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
 
 	/* Add to main log, cleanup */
@@ -441,7 +441,7 @@ static struct lsap_cb *irlmp_find_lsap(struct lap_cb *self, __u8 dlsap_sel,
 	spin_lock_irqsave(&queue->hb_spinlock, flags);
 
 	lsap = (struct lsap_cb *) hashbin_get_first(queue);
-	while (lsap != NULL) {
+	while (lsap) {
 		/*
 		 *  If this is an incoming connection, then the destination
 		 *  LSAP selector may have been specified as LM_ANY so that
diff --git a/drivers/staging/irda/net/irnetlink.c b/drivers/staging/irda/net/irnetlink.c
index 7fc340e574cf..300cf57317d9 100644
--- a/drivers/staging/irda/net/irnetlink.c
+++ b/drivers/staging/irda/net/irnetlink.c
@@ -96,7 +96,7 @@ static int irda_nl_get_mode(struct sk_buff *skb, struct genl_info *info)
 
 	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
 			  &irda_nl_family, 0,  IRDA_NL_CMD_GET_MODE);
-	if (hdr == NULL) {
+	if (!hdr) {
 		ret = -EMSGSIZE;
 		goto err_out;
 	}
diff --git a/drivers/staging/irda/net/irproc.c b/drivers/staging/irda/net/irproc.c
index 77cfdde9d82f..2ddac9f15e6c 100644
--- a/drivers/staging/irda/net/irproc.c
+++ b/drivers/staging/irda/net/irproc.c
@@ -66,7 +66,7 @@ void __init irda_proc_register(void)
 	int i;
 
 	proc_irda = proc_mkdir("irda", init_net.proc_net);
-	if (proc_irda == NULL)
+	if (!proc_irda)
 		return;
 
 	for (i = 0; i < ARRAY_SIZE(irda_dirs); i++)
diff --git a/drivers/staging/irda/net/irqueue.c b/drivers/staging/irda/net/irqueue.c
index 14291cbc4097..ee9d30536a9a 100644
--- a/drivers/staging/irda/net/irqueue.c
+++ b/drivers/staging/irda/net/irqueue.c
@@ -237,7 +237,7 @@ static void enqueue_first(irda_queue_t **queue, irda_queue_t* element)
 	/*
 	 * Check if queue is empty.
 	 */
-	if ( *queue == NULL ) {
+	if (!*queue) {
 		/*
 		 * Queue is empty.  Insert one element into the queue.
 		 */
@@ -273,7 +273,7 @@ static irda_queue_t *dequeue_first(irda_queue_t **queue)
 	 */
 	ret =  *queue;
 
-	if ( *queue == NULL ) {
+	if (!*queue) {
 		/*
 		 * Queue was empty.
 		 */
@@ -314,7 +314,7 @@ static irda_queue_t *dequeue_general(irda_queue_t **queue, irda_queue_t* element
 	 */
 	ret =  *queue;
 
-	if ( *queue == NULL ) {
+	if (!*queue) {
 		/*
 		 * Queue was empty.
 		 */
@@ -390,7 +390,7 @@ int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
 	unsigned long flags = 0;
 	int i;
 
-	IRDA_ASSERT(hashbin != NULL, return -1;);
+	IRDA_ASSERT(hashbin, return -1;);
 	IRDA_ASSERT(hashbin->magic == HB_MAGIC, return -1;);
 
 	/* Synchronize */
@@ -449,7 +449,7 @@ void hashbin_insert(hashbin_t* hashbin, irda_queue_t* entry, long hashv,
 	unsigned long flags = 0;
 	int bin;
 
-	IRDA_ASSERT( hashbin != NULL, return;);
+	IRDA_ASSERT(hashbin, return;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return;);
 
 	/*
@@ -505,7 +505,7 @@ void *hashbin_remove_first( hashbin_t *hashbin)
 	} /* Default is no-lock  */
 
 	entry = hashbin_get_first( hashbin);
-	if ( entry != NULL) {
+	if (entry) {
 		int	bin;
 		long	hashv;
 		/*
@@ -560,7 +560,7 @@ void* hashbin_remove( hashbin_t* hashbin, long hashv, const char* name)
 	unsigned long flags = 0;
 	irda_queue_t* entry;
 
-	IRDA_ASSERT( hashbin != NULL, return NULL;);
+	IRDA_ASSERT(hashbin, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
 
 	/*
@@ -651,9 +651,9 @@ void* hashbin_remove_this( hashbin_t* hashbin, irda_queue_t* entry)
 	int	bin;
 	long	hashv;
 
-	IRDA_ASSERT( hashbin != NULL, return NULL;);
+	IRDA_ASSERT(hashbin, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
-	IRDA_ASSERT( entry != NULL, return NULL;);
+	IRDA_ASSERT(entry, return NULL;);
 
 	/* Synchronize */
 	if ( hashbin->hb_type & HB_LOCK ) {
@@ -661,7 +661,7 @@ void* hashbin_remove_this( hashbin_t* hashbin, irda_queue_t* entry)
 	} /* Default is no-lock  */
 
 	/* Check if valid and not already removed... */
-	if((entry->q_next == NULL) || (entry->q_prev == NULL)) {
+	if (!entry->q_next || !entry->q_prev) {
 		entry = NULL;
 		goto out;
 	}
@@ -712,7 +712,7 @@ void* hashbin_find( hashbin_t* hashbin, long hashv, const char* name )
 
 	pr_debug("hashbin_find()\n");
 
-	IRDA_ASSERT( hashbin != NULL, return NULL;);
+	IRDA_ASSERT(hashbin, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
 
 	/*
@@ -833,10 +833,10 @@ irda_queue_t *hashbin_get_first( hashbin_t* hashbin)
 	irda_queue_t *entry;
 	int i;
 
-	IRDA_ASSERT( hashbin != NULL, return NULL;);
+	IRDA_ASSERT(hashbin, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
 
-	if ( hashbin == NULL)
+	if (!hashbin)
 		return NULL;
 
 	for ( i = 0; i < HASHBIN_SIZE; i ++ ) {
@@ -869,11 +869,11 @@ irda_queue_t *hashbin_get_next( hashbin_t *hashbin)
 	int bin;
 	int i;
 
-	IRDA_ASSERT( hashbin != NULL, return NULL;);
+	IRDA_ASSERT(hashbin, return NULL;);
 	IRDA_ASSERT( hashbin->magic == HB_MAGIC, return NULL;);
 
-	if ( hashbin->hb_current == NULL) {
-		IRDA_ASSERT( hashbin->hb_current != NULL, return NULL;);
+	if (!hashbin->hb_current) {
+		IRDA_ASSERT(hashbin->hb_current, return NULL;);
 		return NULL;
 	}
 	entry = hashbin->hb_current->q_next;
diff --git a/drivers/staging/irda/net/irsysctl.c b/drivers/staging/irda/net/irsysctl.c
index 873da5e7d428..70b8d39b5c1c 100644
--- a/drivers/staging/irda/net/irsysctl.c
+++ b/drivers/staging/irda/net/irsysctl.c
@@ -99,8 +99,8 @@ static int do_discovery(struct ctl_table *table, int write,
        if (ret)
 	       return ret;
 
-       if (irlmp == NULL)
-	       return -ENODEV;
+	if (!irlmp)
+		return -ENODEV;
 
        if (sysctl_discovery)
 	       irlmp_start_discovery_timer(irlmp, sysctl_discovery_timeout*HZ);
diff --git a/drivers/staging/irda/net/irttp.c b/drivers/staging/irda/net/irttp.c
index bcab5a60cd47..2adba87aeb68 100644
--- a/drivers/staging/irda/net/irttp.c
+++ b/drivers/staging/irda/net/irttp.c
@@ -91,7 +91,7 @@ static pi_param_info_t param_info = { pi_major_call_table, 1, 0x0f, 4 };
 int __init irttp_init(void)
 {
 	irttp = kzalloc(sizeof(struct irttp_cb), GFP_KERNEL);
-	if (irttp == NULL)
+	if (!irttp)
 		return -ENOMEM;
 
 	irttp->magic = TTP_MAGIC;
@@ -209,7 +209,7 @@ static void irttp_flush_queues(struct tsap_cb *self)
 {
 	struct sk_buff *skb;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	/* Deallocate frames waiting to be sent */
@@ -237,7 +237,7 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 	struct sk_buff *skb, *frag;
 	int n = 0;  /* Fragment index */
 
-	IRDA_ASSERT(self != NULL, return NULL;);
+	IRDA_ASSERT(self, return NULL;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return NULL;);
 
 	pr_debug("%s(), self->rx_sdu_size=%d\n", __func__,
@@ -294,9 +294,9 @@ static inline void irttp_fragment_skb(struct tsap_cb *self,
 	struct sk_buff *frag;
 	__u8 *frame;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	/*
 	 *  Split frame into a number of segments
@@ -350,7 +350,7 @@ static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 
 	if (get)
@@ -404,7 +404,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	}
 
 	self = kzalloc(sizeof(*self), GFP_ATOMIC);
-	if (self == NULL)
+	if (!self)
 		return NULL;
 
 	/* Initialize internal objects */
@@ -422,7 +422,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	ttp_notify.data_indication = irttp_data_indication;
 	ttp_notify.udata_indication = irttp_udata_indication;
 	ttp_notify.flow_indication = irttp_flow_indication;
-	if (notify->status_indication != NULL)
+	if (notify->status_indication)
 		ttp_notify.status_indication = irttp_status_indication;
 	ttp_notify.instance = self;
 	strncpy(ttp_notify.name, notify->name, NOTIFY_MAX_NAME);
@@ -434,7 +434,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	 *  Create LSAP at IrLMP layer
 	 */
 	lsap = irlmp_open_lsap(stsap_sel, &ttp_notify, 0);
-	if (lsap == NULL) {
+	if (!lsap) {
 		pr_debug("%s: unable to allocate LSAP!!\n", __func__);
 		__irttp_close_tsap(self);
 		return NULL;
@@ -472,7 +472,7 @@ EXPORT_SYMBOL(irttp_open_tsap);
 static void __irttp_close_tsap(struct tsap_cb *self)
 {
 	/* First make sure we're connected. */
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	irttp_flush_queues(self);
@@ -504,7 +504,7 @@ int irttp_close_tsap(struct tsap_cb *self)
 {
 	struct tsap_cb *tsap;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 
 	/* Make sure tsap has been disconnected */
@@ -547,9 +547,9 @@ int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 {
 	int ret;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
-	IRDA_ASSERT(skb != NULL, return -1;);
+	IRDA_ASSERT(skb, return -1;);
 
 	/* Take shortcut on zero byte packets */
 	if (skb->len == 0) {
@@ -594,9 +594,9 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	__u8 *frame;
 	int ret;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
-	IRDA_ASSERT(skb != NULL, return -1;);
+	IRDA_ASSERT(skb, return -1;);
 
 	pr_debug("%s() : queue len = %d\n", __func__,
 		 skb_queue_len(&self->tx_queue));
@@ -769,7 +769,7 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
 		 * remains in IrLAP (retry on the link or else) after we
 		 * close the socket, we are dead !
 		 * Jean II */
-		if (skb->sk != NULL) {
+		if (skb->sk) {
 			/* IrSOCK application, IrOBEX, ... */
 			skb_orphan(skb);
 		}
@@ -815,7 +815,7 @@ static inline void irttp_give_credit(struct tsap_cb *self)
 	unsigned long flags;
 	int n;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	pr_debug("%s() send=%d,avail=%d,remote=%d\n",
@@ -870,9 +870,9 @@ static int irttp_udata_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
-	IRDA_ASSERT(skb != NULL, return -1;);
+	IRDA_ASSERT(skb, return -1;);
 
 	self->stats.rx_packets++;
 
@@ -985,7 +985,7 @@ static void irttp_status_indication(void *instance,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	/* Check if client has already closed the TSAP and gone away */
@@ -995,7 +995,7 @@ static void irttp_status_indication(void *instance,
 	/*
 	 *  Inform service user if he has requested it
 	 */
-	if (self->notify.status_indication != NULL)
+	if (self->notify.status_indication)
 		self->notify.status_indication(self->notify.instance,
 					       link, lock);
 	else
@@ -1014,7 +1014,7 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	pr_debug("%s(instance=%p)\n", __func__, self);
@@ -1055,7 +1055,7 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
  */
 void irttp_flow_request(struct tsap_cb *self, LOCAL_FLOW flow)
 {
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	switch (flow) {
@@ -1095,7 +1095,7 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 
 	pr_debug("%s(), max_sdu_size=%d\n", __func__, max_sdu_size);
 
-	IRDA_ASSERT(self != NULL, return -EBADR;);
+	IRDA_ASSERT(self, return -EBADR;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -EBADR;);
 
 	if (self->connected) {
@@ -1105,7 +1105,7 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 	}
 
 	/* Any userdata supplied? */
-	if (userdata == NULL) {
+	if (!userdata) {
 		tx_skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
 				   GFP_ATOMIC);
 		if (!tx_skb)
@@ -1193,9 +1193,9 @@ static void irttp_connect_confirm(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	self->max_seg_size = max_seg_size - TTP_HEADER;
 	self->max_header_size = max_header_size + TTP_HEADER;
@@ -1277,9 +1277,9 @@ static void irttp_connect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
-	IRDA_ASSERT(skb != NULL, return;);
+	IRDA_ASSERT(skb, return;);
 
 	lsap = sap;
 
@@ -1345,14 +1345,14 @@ int irttp_connect_response(struct tsap_cb *self, __u32 max_sdu_size,
 	int ret;
 	__u8 n;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 
 	pr_debug("%s(), Source TSAP selector=%02x\n", __func__,
 		 self->stsap_sel);
 
 	/* Any userdata supplied? */
-	if (userdata == NULL) {
+	if (!userdata) {
 		tx_skb = alloc_skb(TTP_MAX_HEADER + TTP_SAR_HEADER,
 				   GFP_ATOMIC);
 		if (!tx_skb)
@@ -1484,7 +1484,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 {
 	int ret;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 
 	/* Already disconnected? */
@@ -1580,7 +1580,7 @@ static void irttp_disconnect_indication(void *instance, void *sap,
 
 	self = instance;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return;);
 
 	/* Prevent higher layer to send more data */
@@ -1800,7 +1800,7 @@ static void *irttp_seq_start(struct seq_file *seq, loff_t *pos)
 	iter->id = 0;
 
 	for (self = (struct tsap_cb *) hashbin_get_first(irttp->tsaps);
-	     self != NULL;
+	     self;
 	     self = (struct tsap_cb *) hashbin_get_next(irttp->tsaps)) {
 		if (iter->id == *pos)
 			break;
diff --git a/drivers/staging/irda/net/parameters.c b/drivers/staging/irda/net/parameters.c
index 16ce32ffe004..2d891729815d 100644
--- a/drivers/staging/irda/net/parameters.c
+++ b/drivers/staging/irda/net/parameters.c
@@ -456,8 +456,8 @@ int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len,
 	int ret = -1;
 	int n = 0;
 
-	IRDA_ASSERT(buf != NULL, return ret;);
-	IRDA_ASSERT(info != NULL, return ret;);
+	IRDA_ASSERT(buf, return ret;);
+	IRDA_ASSERT(info, return ret;);
 
 	pi_minor = pi & info->pi_mask;
 	pi_major = pi >> info->pi_major_offset;
@@ -511,8 +511,8 @@ static int irda_param_extract(void *self, __u8 *buf, int len,
 	int ret = -1;
 	int n = 0;
 
-	IRDA_ASSERT(buf != NULL, return ret;);
-	IRDA_ASSERT(info != NULL, return ret;);
+	IRDA_ASSERT(buf, return ret;);
+	IRDA_ASSERT(info, return ret;);
 
 	pi_minor = buf[n] & info->pi_mask;
 	pi_major = buf[n] >> info->pi_major_offset;
@@ -564,8 +564,8 @@ int irda_param_extract_all(void *self, __u8 *buf, int len,
 	int ret = -1;
 	int n = 0;
 
-	IRDA_ASSERT(buf != NULL, return ret;);
-	IRDA_ASSERT(info != NULL, return ret;);
+	IRDA_ASSERT(buf, return ret;);
+	IRDA_ASSERT(info, return ret;);
 
 	/*
 	 * Parse all parameters. Each parameter must be at least two bytes
diff --git a/drivers/staging/irda/net/qos.c b/drivers/staging/irda/net/qos.c
index 25ba8509ad3e..b3816b90ff2c 100644
--- a/drivers/staging/irda/net/qos.c
+++ b/drivers/staging/irda/net/qos.c
@@ -278,8 +278,8 @@ static inline int value_highest_bit(__u32 value, __u32 *array, int size, __u16 *
  */
 void irda_qos_compute_intersection(struct qos_info *qos, struct qos_info *new)
 {
-	IRDA_ASSERT(qos != NULL, return;);
-	IRDA_ASSERT(new != NULL, return;);
+	IRDA_ASSERT(qos, return;);
+	IRDA_ASSERT(new, return;);
 
 	/* Apply */
 	qos->baud_rate.bits       &= new->baud_rate.bits;
@@ -529,7 +529,7 @@ static int irlap_param_baud_rate(void *instance, irda_param_t *param, int get)
 
 	struct irlap_cb *self = (struct irlap_cb *) instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	if (get) {
@@ -565,7 +565,7 @@ static int irlap_param_link_disconnect(void *instance, irda_param_t *param,
 
 	struct irlap_cb *self = (struct irlap_cb *) instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	if (get)
@@ -597,7 +597,7 @@ static int irlap_param_max_turn_time(void *instance, irda_param_t *param,
 {
 	struct irlap_cb *self = (struct irlap_cb *) instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	if (get)
@@ -619,7 +619,7 @@ static int irlap_param_data_size(void *instance, irda_param_t *param, int get)
 {
 	struct irlap_cb *self = (struct irlap_cb *) instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	if (get)
@@ -642,7 +642,7 @@ static int irlap_param_window_size(void *instance, irda_param_t *param,
 {
 	struct irlap_cb *self = (struct irlap_cb *) instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	if (get)
@@ -663,7 +663,7 @@ static int irlap_param_additional_bofs(void *instance, irda_param_t *param, int
 {
 	struct irlap_cb *self = (struct irlap_cb *) instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	if (get)
@@ -685,7 +685,7 @@ static int irlap_param_min_turn_time(void *instance, irda_param_t *param,
 {
 	struct irlap_cb *self = (struct irlap_cb *) instance;
 
-	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(self, return -1;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return -1;);
 
 	if (get)
@@ -745,7 +745,7 @@ void irda_qos_bits_to_value(struct qos_info *qos)
 {
 	int index;
 
-	IRDA_ASSERT(qos != NULL, return;);
+	IRDA_ASSERT(qos, return;);
 
 	index = msb_index(qos->baud_rate.bits);
 	qos->baud_rate.value = baud_rates[index];
diff --git a/drivers/staging/irda/net/timer.c b/drivers/staging/irda/net/timer.c
index f2280f73b057..3d47ac9df2fe 100644
--- a/drivers/staging/irda/net/timer.c
+++ b/drivers/staging/irda/net/timer.c
@@ -142,7 +142,7 @@ static void irlap_slot_timer_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlap_do_event(self, SLOT_TIMER_EXPIRED, NULL, NULL);
@@ -158,7 +158,7 @@ static void irlap_query_timer_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlap_do_event(self, QUERY_TIMER_EXPIRED, NULL, NULL);
@@ -174,7 +174,7 @@ static void irlap_final_timer_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlap_do_event(self, FINAL_TIMER_EXPIRED, NULL, NULL);
@@ -190,7 +190,7 @@ static void irlap_wd_timer_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlap_do_event(self, WD_TIMER_EXPIRED, NULL, NULL);
@@ -206,7 +206,7 @@ static void irlap_backoff_timer_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	irlap_do_event(self, BACKOFF_TIMER_EXPIRED, NULL, NULL);
@@ -222,7 +222,7 @@ static void irlap_media_busy_expired(void *data)
 {
 	struct irlap_cb *self = (struct irlap_cb *) data;
 
-	IRDA_ASSERT(self != NULL, return;);
+	IRDA_ASSERT(self, return;);
 
 	irda_device_set_media_busy(self->netdev, FALSE);
 	/* Note : the LAP event will be send in irlap_stop_mbusy_timer(),
diff --git a/drivers/staging/irda/net/wrapper.c b/drivers/staging/irda/net/wrapper.c
index 40a0f993bf13..526f86d27268 100644
--- a/drivers/staging/irda/net/wrapper.c
+++ b/drivers/staging/irda/net/wrapper.c
@@ -219,8 +219,7 @@ async_bump(struct net_device *dev,
 	 * skb. But, if the frame is small, it is more efficient to
 	 * copy it to save memory (copy will be fast anyway - that's
 	 * called Rx-copy-break). Jean II */
-	docopy = ((rx_buff->skb == NULL) ||
-		  (rx_buff->len < IRDA_RX_COPY_THRESHOLD));
+	docopy = !rx_buff->skb || rx_buff->len < IRDA_RX_COPY_THRESHOLD;
 
 	/* Allocate a new skb */
 	newskb = dev_alloc_skb(docopy ? rx_buff->len + 1 : rx_buff->truesize);
-- 
2.14.2
