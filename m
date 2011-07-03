From: Joe Perches <joe@perches.com>
Subject: [PATCH] af_econet: Use current logging styles and neatening
Date: Sun,  3 Jul 2011 11:28:33 -0700
Message-ID: <8e47a6e010a39bd35d3544311dd451abda8b7fb3.1309717580.git.joe@perches.com>
Cc: Phil Blundell <philb@gnu.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt() without KBUILD_MODNAME to allow AUN and econet prefixes.
Convert printks with KERN_DEBUG to pr_debug.
Hoist assigns from if.
80 column wrapping.
Move open braces to end of line.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/econet/af_econet.c |  149 ++++++++++++++++++++++++------------------------
 1 files changed, 74 insertions(+), 75 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 5afdc8f..1c1f26c 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -9,6 +9,8 @@
  *
  */
 
+#define pr_fmt(fmt) fmt
+
 #include <linux/module.h>
 
 #include <linux/types.h>
@@ -44,7 +46,7 @@
 #include <linux/bitops.h>
 #include <linux/mutex.h>
 
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <asm/system.h>
 
 static const struct proto_ops econet_ops;
@@ -63,9 +65,7 @@ static DEFINE_SPINLOCK(aun_queue_lock);
 static struct socket *udpsock;
 #define AUN_PORT	0x8000
 
-
-struct aunhdr
-{
+struct aunhdr {
 	unsigned char code;		/* AUN magic protocol byte */
 	unsigned char port;
 	unsigned char cb;
@@ -82,8 +82,7 @@ static struct timer_list ab_cleanup_timer;
 #endif		/* CONFIG_ECONET_AUNUDP */
 
 /* Per-packet information */
-struct ec_cb
-{
+struct ec_cb {
 	struct sockaddr_ec sec;
 	unsigned long cookie;		/* Supplied by user. */
 #ifdef CONFIG_ECONET_AUNUDP
@@ -137,7 +136,7 @@ static int econet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 *	but then it will block.
 	 */
 
-	skb=skb_recv_datagram(sk,flags,flags&MSG_DONTWAIT,&err);
+	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
 
 	/*
 	 *	An error occurred so return it. Because skb_recv_datagram()
@@ -145,7 +144,7 @@ static int econet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 *	retries.
 	 */
 
-	if(skb==NULL)
+	if (skb == NULL)
 		goto out;
 
 	/*
@@ -154,10 +153,9 @@ static int econet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 */
 
 	copied = skb->len;
-	if (copied > len)
-	{
-		copied=len;
-		msg->msg_flags|=MSG_TRUNC;
+	if (copied > len) {
+		copied = len;
+		msg->msg_flags |= MSG_TRUNC;
 	}
 
 	/* We can't use skb_copy_datagram here */
@@ -186,7 +184,8 @@ out:
  *	Bind an Econet socket.
  */
 
-static int econet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
+static int econet_bind(struct socket *sock, struct sockaddr *uaddr,
+		       int addr_len)
 {
 	struct sockaddr_ec *sec = (struct sockaddr_ec *)uaddr;
 	struct sock *sk;
@@ -226,9 +225,8 @@ static void tx_result(struct sock *sk, unsigned long cookie, int result)
 	struct ec_cb *eb;
 	struct sockaddr_ec *sec;
 
-	if (skb == NULL)
-	{
-		printk(KERN_DEBUG "ec: memory squeeze, transmit result dropped.\n");
+	if (skb == NULL) {
+		pr_debug("econet: memory squeeze, transmit result dropped\n");
 		return;
 	}
 
@@ -265,7 +263,7 @@ static void ec_tx_done(struct sk_buff *skb, int result)
 static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 			  struct msghdr *msg, size_t len)
 {
-	struct sockaddr_ec *saddr=(struct sockaddr_ec *)msg->msg_name;
+	struct sockaddr_ec *saddr = (struct sockaddr_ec *)msg->msg_name;
 	struct net_device *dev;
 	struct ec_addr addr;
 	int err;
@@ -298,14 +296,14 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	mutex_lock(&econet_mutex);
 
-        if (saddr == NULL || msg->msg_namelen < sizeof(struct sockaddr_ec)) {
-                mutex_unlock(&econet_mutex);
-                return -EINVAL;
-        }
-        addr.station = saddr->addr.station;
-        addr.net = saddr->addr.net;
-        port = saddr->port;
-        cb = saddr->cb;
+	if (saddr == NULL || msg->msg_namelen < sizeof(struct sockaddr_ec)) {
+		mutex_unlock(&econet_mutex);
+		return -EINVAL;
+	}
+	addr.station = saddr->addr.station;
+	addr.net = saddr->addr.net;
+	port = saddr->port;
+	cb = saddr->cb;
 
 	/* Look for a device with the right network number. */
 	dev = net2dev_map[addr.net];
@@ -333,9 +331,9 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 		dev_hold(dev);
 
-		skb = sock_alloc_send_skb(sk, len+LL_ALLOCATED_SPACE(dev),
+		skb = sock_alloc_send_skb(sk, len + LL_ALLOCATED_SPACE(dev),
 					  msg->msg_flags & MSG_DONTWAIT, &err);
-		if (skb==NULL)
+		if (skb == NULL)
 			goto out_unlock;
 
 		skb_reserve(skb, LL_RESERVED_SPACE(dev));
@@ -355,7 +353,7 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 			struct ec_framehdr *fh;
 			/* Poke in our control byte and
 			   port number.  Hack, hack.  */
-			fh = (struct ec_framehdr *)(skb->data);
+			fh = (struct ec_framehdr *)skb->data;
 			fh->cb = cb;
 			fh->port = port;
 			if (sock->type != SOCK_DGRAM) {
@@ -365,7 +363,7 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 		}
 
 		/* Copy the data. Returns -EFAULT on error */
-		err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
+		err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 		skb->protocol = proto;
 		skb->dev = dev;
 		skb->priority = sk->sk_priority;
@@ -385,9 +383,9 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 		mutex_unlock(&econet_mutex);
 		return len;
 
-	out_free:
+out_free:
 		kfree_skb(skb);
-	out_unlock:
+out_unlock:
 		if (dev)
 			dev_put(dev);
 #else
@@ -458,15 +456,14 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 		goto error_free_buf;
 
 	/* Get a skbuff (no data, just holds our cb information) */
-	if ((skb = sock_alloc_send_skb(sk, 0,
-				       msg->msg_flags & MSG_DONTWAIT,
-				       &err)) == NULL)
+	skb = sock_alloc_send_skb(sk, 0, msg->msg_flags & MSG_DONTWAIT, &err);
+	if (skb == NULL)
 		goto error_free_buf;
 
 	eb = (struct ec_cb *)&skb->cb;
 
 	eb->cookie = saddr->cookie;
-	eb->timeout = (5*HZ);
+	eb->timeout = 5 * HZ;
 	eb->start = jiffies;
 	ah.handle = aun_seq;
 	eb->seq = (aun_seq++);
@@ -480,9 +477,10 @@ static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	udpmsg.msg_iovlen = 2;
 	udpmsg.msg_control = NULL;
 	udpmsg.msg_controllen = 0;
-	udpmsg.msg_flags=0;
+	udpmsg.msg_flags = 0;
 
-	oldfs = get_fs(); set_fs(KERNEL_DS);	/* More privs :-) */
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);		/* More privs :-) */
 	err = sock_sendmsg(udpsock, &udpmsg, size);
 	set_fs(oldfs);
 
@@ -530,7 +528,7 @@ static int econet_getname(struct socket *sock, struct sockaddr *uaddr,
 
 static void econet_destroy_timer(unsigned long data)
 {
-	struct sock *sk=(struct sock *)data;
+	struct sock *sk = (struct sock *)data;
 
 	if (!sk_has_allocations(sk)) {
 		sk_free(sk);
@@ -539,7 +537,7 @@ static void econet_destroy_timer(unsigned long data)
 
 	sk->sk_timer.expires = jiffies + 10 * HZ;
 	add_timer(&sk->sk_timer);
-	printk(KERN_DEBUG "econet socket destroy delayed\n");
+	pr_debug("econet: socket destroy delayed\n");
 }
 
 /*
@@ -651,7 +649,8 @@ static int ec_dev_ioctl(struct socket *sock, unsigned int cmd, void __user *arg)
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;
 
-	if ((dev = dev_get_by_name(&init_net, ifr.ifr_name)) == NULL)
+	dev = dev_get_by_name(&init_net, ifr.ifr_name);
+	if (dev == NULL)
 		return -ENODEV;
 
 	sec = (struct sockaddr_ec *)&ifr.ifr_addr;
@@ -715,7 +714,8 @@ static int ec_dev_ioctl(struct socket *sock, unsigned int cmd, void __user *arg)
  *	Handle generic ioctls
  */
 
-static int econet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+static int econet_ioctl(struct socket *sock, unsigned int cmd,
+			unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 	void __user *argp = (void __user *)arg;
@@ -833,7 +833,7 @@ static void aun_send_response(__u32 addr, unsigned long seq, int code, int cb)
 	udpmsg.msg_namelen = sizeof(sin);
 	udpmsg.msg_control = NULL;
 	udpmsg.msg_controllen = 0;
-	udpmsg.msg_flags=0;
+	udpmsg.msg_flags = 0;
 
 	kernel_sendmsg(udpsock, &udpmsg, &iov, 1, sizeof(ah));
 }
@@ -856,26 +856,25 @@ static void aun_incoming(struct sk_buff *skb, struct aunhdr *ah, size_t len)
 	if (dst)
 		edev = dst->dev->ec_ptr;
 
-	if (! edev)
+	if (!edev)
 		goto bad;
 
-	if ((sk = ec_listening_socket(ah->port, stn, edev->net)) == NULL)
+	sk = ec_listening_socket(ah->port, stn, edev->net);
+	if (sk == NULL)
 		goto bad;		/* Nobody wants it */
 
 	newskb = alloc_skb((len - sizeof(struct aunhdr) + 15) & ~15,
 			   GFP_ATOMIC);
-	if (newskb == NULL)
-	{
-		printk(KERN_DEBUG "AUN: memory squeeze, dropping packet.\n");
+	if (newskb == NULL) {
+		pr_debug("AUN: memory squeeze, dropping packet\n");
 		/* Send nack and hope sender tries again */
 		goto bad;
 	}
 
-	memcpy(skb_put(newskb, len - sizeof(struct aunhdr)), (void *)(ah+1),
+	memcpy(skb_put(newskb, len - sizeof(struct aunhdr)), (void *)(ah + 1),
 	       len - sizeof(struct aunhdr));
 
-	if (ec_queue_packet(sk, newskb, stn, edev->net, ah->cb, ah->port))
-	{
+	if (ec_queue_packet(sk, newskb, stn, edev->net, ah->cb, ah->port)) {
 		/* Socket is bankrupt. */
 		kfree_skb(newskb);
 		goto bad;
@@ -911,7 +910,7 @@ static void aun_tx_ack(unsigned long seq, int result)
 			goto foundit;
 	}
 	spin_unlock_irqrestore(&aun_queue_lock, flags);
-	printk(KERN_DEBUG "AUN: unknown sequence %ld\n", seq);
+	pr_debug("AUN: unknown sequence %ld\n", seq);
 	return;
 
 foundit:
@@ -936,18 +935,17 @@ static void aun_data_available(struct sock *sk, int slen)
 
 	while ((skb = skb_recv_datagram(sk, 0, 1, &err)) == NULL) {
 		if (err == -EAGAIN) {
-			printk(KERN_ERR "AUN: no data available?!");
+			pr_err("AUN: no data available?!\n");
 			return;
 		}
-		printk(KERN_DEBUG "AUN: recvfrom() error %d\n", -err);
+		pr_debug("AUN: recvfrom() error %d\n", -err);
 	}
 
 	data = skb_transport_header(skb) + sizeof(struct udphdr);
 	ah = (struct aunhdr *)data;
 	len = skb->len - sizeof(struct udphdr);
 
-	switch (ah->code)
-	{
+	switch (ah->code) {
 	case 2:
 		aun_incoming(skb, ah, len);
 		break;
@@ -958,7 +956,7 @@ static void aun_data_available(struct sock *sk, int slen)
 		aun_tx_ack(ah->handle, ECTYPE_TRANSMIT_NOT_LISTENING);
 		break;
 	default:
-		printk(KERN_DEBUG "unknown AUN packet (type %d)\n", data[0]);
+		pr_debug("AUN: unknown packet type: %d\n", data[0]);
 	}
 
 	skb_free_datagram(sk, skb);
@@ -988,7 +986,7 @@ static void ab_cleanup(unsigned long h)
 	}
 	spin_unlock_irqrestore(&aun_queue_lock, flags);
 
-	mod_timer(&ab_cleanup_timer, jiffies + (HZ*2));
+	mod_timer(&ab_cleanup_timer, jiffies + (HZ * 2));
 }
 
 static int __init aun_udp_initialise(void)
@@ -998,7 +996,7 @@ static int __init aun_udp_initialise(void)
 
 	skb_queue_head_init(&aun_queue);
 	setup_timer(&ab_cleanup_timer, ab_cleanup, 0);
-	ab_cleanup_timer.expires = jiffies + (HZ*2);
+	ab_cleanup_timer.expires = jiffies + (HZ * 2);
 	add_timer(&ab_cleanup_timer);
 
 	memset(&sin, 0, sizeof(sin));
@@ -1006,9 +1004,9 @@ static int __init aun_udp_initialise(void)
 
 	/* We can count ourselves lucky Acorn machines are too dim to
 	   speak IPv6. :-) */
-	if ((error = sock_create_kern(PF_INET, SOCK_DGRAM, 0, &udpsock)) < 0)
-	{
-		printk("AUN: socket error %d\n", -error);
+	error = sock_create_kern(PF_INET, SOCK_DGRAM, 0, &udpsock);
+	if (error < 0) {
+		pr_err("AUN: socket error %d\n", -error);
 		return error;
 	}
 
@@ -1017,10 +1015,9 @@ static int __init aun_udp_initialise(void)
 						    from interrupts */
 
 	error = udpsock->ops->bind(udpsock, (struct sockaddr *)&sin,
-				sizeof(sin));
-	if (error < 0)
-	{
-		printk("AUN: bind error %d\n", -error);
+				   sizeof(sin));
+	if (error < 0) {
+		pr_err("AUN: bind error %d\n", -error);
 		goto release;
 	}
 
@@ -1041,7 +1038,8 @@ release:
  *	Receive an Econet frame from a device.
  */
 
-static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int econet_rcv(struct sk_buff *skb, struct net_device *dev,
+		      struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct ec_framehdr *hdr;
 	struct sock *sk = NULL;
@@ -1056,13 +1054,14 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	if (!edev)
 		goto drop;
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (skb == NULL)
 		return NET_RX_DROP;
 
 	if (!pskb_may_pull(skb, sizeof(struct ec_framehdr)))
 		goto drop;
 
-	hdr = (struct ec_framehdr *) skb->data;
+	hdr = (struct ec_framehdr *)skb->data;
 
 	/* First check for encapsulated IP */
 	if (hdr->port == EC_PORT_IP) {
@@ -1090,8 +1089,8 @@ drop:
 }
 
 static struct packet_type econet_packet_type __read_mostly = {
-	.type =		cpu_to_be16(ETH_P_ECONET),
-	.func =		econet_rcv,
+	.type =	cpu_to_be16(ETH_P_ECONET),
+	.func =	econet_rcv,
 };
 
 static void econet_hw_initialise(void)
@@ -1101,9 +1100,10 @@ static void econet_hw_initialise(void)
 
 #endif
 
-static int econet_notifier(struct notifier_block *this, unsigned long msg, void *data)
+static int econet_notifier(struct notifier_block *this, unsigned long msg,
+			   void *data)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct net_device *dev = data;
 	struct ec_device *edev;
 
 	if (!net_eq(dev_net(dev), &init_net))
@@ -1113,8 +1113,7 @@ static int econet_notifier(struct notifier_block *this, unsigned long msg, void
 	case NETDEV_UNREGISTER:
 		/* A device has gone down - kill any data we hold for it. */
 		edev = dev->ec_ptr;
-		if (edev)
-		{
+		if (edev) {
 			if (net2dev_map[0] == dev)
 				net2dev_map[0] = NULL;
 			net2dev_map[edev->net] = NULL;
@@ -1128,7 +1127,7 @@ static int econet_notifier(struct notifier_block *this, unsigned long msg, void
 }
 
 static struct notifier_block econet_netdev_notifier = {
-	.notifier_call =econet_notifier,
+	.notifier_call = econet_notifier,
 };
 
 static void __exit econet_proto_exit(void)
-- 
1.7.6.rc1
