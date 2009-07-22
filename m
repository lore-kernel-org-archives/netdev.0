From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] af_packet: style cleanups
Date: Wed, 22 Jul 2009 09:57:59 +0200
Message-ID: <4A66C687.3050109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59572 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbZGVH6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 03:58:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some style cleanups to match current code practices.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/packet/af_packet.c |  246 +++++++++++++++++++--------------------
 1 files changed, 122 insertions(+), 124 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ebe5718..d3d52c6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -137,8 +137,7 @@ dev->hard_header == NULL (ll header is added by device, we cannot control it)
 
 /* Private packet socket structures. */
 
-struct packet_mclist
-{
+struct packet_mclist {
 	struct packet_mclist	*next;
 	int			ifindex;
 	int			count;
@@ -149,8 +148,7 @@ struct packet_mclist
 /* identical to struct packet_mreq except it has
  * a longer address field.
  */
-struct packet_mreq_max
-{
+struct packet_mreq_max {
 	int		mr_ifindex;
 	unsigned short	mr_type;
 	unsigned short	mr_alen;
@@ -162,7 +160,7 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		int closing, int tx_ring);
 
 struct packet_ring_buffer {
-	char *			*pg_vec;
+	char			**pg_vec;
 	unsigned int		head;
 	unsigned int		frames_per_block;
 	unsigned int		frame_size;
@@ -239,7 +237,7 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
 		flush_dcache_page(virt_to_page(&h.h2->tp_status));
 		break;
 	default:
-		printk(KERN_ERR "TPACKET version not supported\n");
+		pr_err("TPACKET version not supported\n");
 		BUG();
 	}
 
@@ -265,7 +263,7 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
 		flush_dcache_page(virt_to_page(&h.h2->tp_status));
 		return h.h2->tp_status;
 	default:
-		printk(KERN_ERR "TPACKET version not supported\n");
+		pr_err("TPACKET version not supported\n");
 		BUG();
 		return 0;
 	}
@@ -327,7 +325,7 @@ static void packet_sock_destruct(struct sock *sk)
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk("Attempt to release alive packet socket: %p\n", sk);
+		pr_err("Attempt to release alive packet socket: %p\n", sk);
 		return;
 	}
 
@@ -339,7 +337,8 @@ static const struct proto_ops packet_ops;
 
 static const struct proto_ops packet_ops_spkt;
 
-static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct packet_type *pt, struct net_device *orig_dev)
+static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,
+			   struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct sock *sk;
 	struct sockaddr_pkt *spkt;
@@ -368,7 +367,8 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	if (dev_net(dev) != sock_net(sk))
 		goto out;
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (skb == NULL)
 		goto oom;
 
 	/* drop any routing info */
@@ -394,7 +394,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	 *	to prevent sockets using all the memory up.
 	 */
 
-	if (sock_queue_rcv_skb(sk,skb) == 0)
+	if (sock_queue_rcv_skb(sk, skb) == 0)
 		return 0;
 
 out:
@@ -413,25 +413,23 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct sockaddr_pkt *saddr=(struct sockaddr_pkt *)msg->msg_name;
+	struct sockaddr_pkt *saddr = (struct sockaddr_pkt *)msg->msg_name;
 	struct sk_buff *skb;
 	struct net_device *dev;
-	__be16 proto=0;
+	__be16 proto = 0;
 	int err;
 
 	/*
 	 *	Get and verify the address.
 	 */
 
-	if (saddr)
-	{
+	if (saddr) {
 		if (msg->msg_namelen < sizeof(struct sockaddr))
-			return(-EINVAL);
-		if (msg->msg_namelen==sizeof(struct sockaddr_pkt))
-			proto=saddr->spkt_protocol;
-	}
-	else
-		return(-ENOTCONN);	/* SOCK_PACKET must be sent giving an address */
+			return -EINVAL;
+		if (msg->msg_namelen == sizeof(struct sockaddr_pkt))
+			proto = saddr->spkt_protocol;
+	} else
+		return -ENOTCONN;	/* SOCK_PACKET must be sent giving an address */
 
 	/*
 	 *	Find the device first to size check it
@@ -448,8 +446,8 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 		goto out_unlock;
 
 	/*
-	 *	You may not queue a frame bigger than the mtu. This is the lowest level
-	 *	raw protocol and you must do your own fragmentation at this level.
+	 * You may not queue a frame bigger than the mtu. This is the lowest level
+	 * raw protocol and you must do your own fragmentation at this level.
 	 */
 
 	err = -EMSGSIZE;
@@ -460,9 +458,9 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	skb = sock_wmalloc(sk, len + LL_RESERVED_SPACE(dev), 0, GFP_KERNEL);
 
 	/*
-	 *	If the write buffer is full, then tough. At this level the user gets to
-	 *	deal with the problem - do your own algorithmic backoffs. That's far
-	 *	more flexible.
+	 * If the write buffer is full, then tough. At this level the user
+	 * gets to deal with the problem - do your own algorithmic backoffs.
+	 * That's far more flexible.
 	 */
 
 	if (skb == NULL)
@@ -488,7 +486,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	}
 
 	/* Returns -EFAULT on error */
-	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
+	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
@@ -501,7 +499,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 
 	dev_queue_xmit(skb);
 	dev_put(dev);
-	return(len);
+	return len;
 
 out_free:
 	kfree_skb(skb);
@@ -537,12 +535,13 @@ static inline unsigned int run_filter(struct sk_buff *skb, struct sock *sk,
    we will not harm anyone.
  */
 
-static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
+		      struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct sock *sk;
 	struct sockaddr_ll *sll;
 	struct packet_sock *po;
-	u8 * skb_head = skb->data;
+	u8 *skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
 
@@ -648,7 +647,8 @@ drop:
 }
 
 #ifdef CONFIG_PACKET_MMAP
-static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
+		       struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct sock *sk;
 	struct packet_sock *po;
@@ -658,7 +658,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 		struct tpacket2_hdr *h2;
 		void *raw;
 	} h;
-	u8 * skb_head = skb->data;
+	u8 *skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
 	unsigned long status = TP_STATUS_LOSING|TP_STATUS_USER;
@@ -821,7 +821,7 @@ ring_is_full:
 static void tpacket_destruct_skb(struct sk_buff *skb)
 {
 	struct packet_sock *po = pkt_sk(skb->sk);
-	void * ph;
+	void *ph;
 
 	BUG_ON(skb == NULL);
 
@@ -836,9 +836,9 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 	sock_wfree(skb);
 }
 
-static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff * skb,
-		void * frame, struct net_device *dev, int size_max,
-		__be16 proto, unsigned char * addr)
+static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
+		void *frame, struct net_device *dev, int size_max,
+		__be16 proto, unsigned char *addr)
 {
 	union {
 		struct tpacket_hdr *h1;
@@ -867,8 +867,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff * skb,
 		break;
 	}
 	if (unlikely(tp_len > size_max)) {
-		printk(KERN_ERR "packet size is too long (%d > %d)\n",
-				tp_len, size_max);
+		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
 		return -EMSGSIZE;
 	}
 
@@ -883,12 +882,11 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff * skb,
 				NULL, tp_len);
 		if (unlikely(err < 0))
 			return -EINVAL;
-	} else if (dev->hard_header_len ) {
+	} else if (dev->hard_header_len) {
 		/* net device doesn't like empty head */
 		if (unlikely(tp_len <= dev->hard_header_len)) {
-			printk(KERN_ERR "packet size is too short "
-					"(%d < %d)\n", tp_len,
-					dev->hard_header_len);
+			pr_err("packet size is too short (%d < %d)\n",
+			       tp_len, dev->hard_header_len);
 			return -EINVAL;
 		}
 
@@ -917,9 +915,8 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff * skb,
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
 		if (unlikely(nr_frags >= MAX_SKB_FRAGS)) {
-			printk(KERN_ERR "Packet exceed the number "
-					"of skb frags(%lu)\n",
-					MAX_SKB_FRAGS);
+			pr_err("Packet exceed the number of skb frags(%lu)\n",
+			       MAX_SKB_FRAGS);
 			return -EFAULT;
 		}
 
@@ -944,8 +941,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct net_device *dev;
 	__be16 proto;
 	int ifindex, err, reserve = 0;
-	void * ph;
-	struct sockaddr_ll *saddr=(struct sockaddr_ll *)msg->msg_name;
+	void *ph;
+	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	int tp_len, size_max;
 	unsigned char *addr;
 	int len_sum = 0;
@@ -1038,8 +1035,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			goto out_xmit;
 		packet_increment_head(&po->tx_ring);
 		len_sum += tp_len;
-	}
-	while (likely((ph != NULL) || ((!(msg->msg_flags & MSG_DONTWAIT))
+	} while (likely((ph != NULL) || ((!(msg->msg_flags & MSG_DONTWAIT))
 					&& (atomic_read(&po->tx_ring.pending))))
 	      );
 
@@ -1064,7 +1060,7 @@ static int packet_snd(struct socket *sock,
 			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct sockaddr_ll *saddr=(struct sockaddr_ll *)msg->msg_name;
+	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
@@ -1110,7 +1106,7 @@ static int packet_snd(struct socket *sock,
 
 	skb = sock_alloc_send_skb(sk, len + LL_ALLOCATED_SPACE(dev),
 				msg->msg_flags & MSG_DONTWAIT, &err);
-	if (skb==NULL)
+	if (skb == NULL)
 		goto out_unlock;
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
@@ -1122,7 +1118,7 @@ static int packet_snd(struct socket *sock,
 		goto out_free;
 
 	/* Returns -EFAULT on error */
-	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
+	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 	if (err)
 		goto out_free;
 
@@ -1140,7 +1136,7 @@ static int packet_snd(struct socket *sock,
 
 	dev_put(dev);
 
-	return(len);
+	return len;
 
 out_free:
 	kfree_skb(skb);
@@ -1283,9 +1279,10 @@ out_unlock:
  *	Bind a packet socket to a device
  */
 
-static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr, int addr_len)
+static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
+			    int addr_len)
 {
-	struct sock *sk=sock->sk;
+	struct sock *sk = sock->sk;
 	char name[15];
 	struct net_device *dev;
 	int err = -ENODEV;
@@ -1296,7 +1293,7 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr, int add
 
 	if (addr_len != sizeof(struct sockaddr))
 		return -EINVAL;
-	strlcpy(name,uaddr->sa_data,sizeof(name));
+	strlcpy(name, uaddr->sa_data, sizeof(name));
 
 	dev = dev_get_by_name(sock_net(sk), name);
 	if (dev) {
@@ -1308,8 +1305,8 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr, int add
 
 static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
-	struct sockaddr_ll *sll = (struct sockaddr_ll*)uaddr;
-	struct sock *sk=sock->sk;
+	struct sockaddr_ll *sll = (struct sockaddr_ll *)uaddr;
+	struct sock *sk = sock->sk;
 	struct net_device *dev = NULL;
 	int err;
 
@@ -1404,7 +1401,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
 	sk_add_node(sk, &net->packet.sklist);
 	sock_prot_inuse_add(net, &packet_proto, 1);
 	write_unlock_bh(&net->packet.sklist_lock);
-	return(0);
+	return 0;
 out:
 	return err;
 }
@@ -1441,7 +1438,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 *	but then it will block.
 	 */
 
-	skb=skb_recv_datagram(sk,flags,flags&MSG_DONTWAIT,&err);
+	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
 
 	/*
 	 *	An error occurred so return it. Because skb_recv_datagram()
@@ -1469,10 +1466,9 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
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
 
 	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
@@ -1539,7 +1535,7 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct net_device *dev;
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
-	struct sockaddr_ll *sll = (struct sockaddr_ll*)uaddr;
+	struct sockaddr_ll *sll = (struct sockaddr_ll *)uaddr;
 
 	if (peer)
 		return -EOPNOTSUPP;
@@ -1584,14 +1580,15 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 		else
 			return dev_unicast_delete(dev, i->addr);
 		break;
-	default:;
+	default:
+		break;
 	}
 	return 0;
 }
 
 static void packet_dev_mclist(struct net_device *dev, struct packet_mclist *i, int what)
 {
-	for ( ; i; i=i->next) {
+	for ( ; i; i = i->next) {
 		if (i->ifindex == dev->ifindex)
 			packet_dev_mc(dev, i, what);
 	}
@@ -1693,7 +1690,8 @@ static void packet_flush_mclist(struct sock *sk)
 		struct net_device *dev;
 
 		po->mclist = ml->next;
-		if ((dev = dev_get_by_index(sock_net(sk), ml->ifindex)) != NULL) {
+		dev = dev_get_by_index(sock_net(sk), ml->ifindex);
+		if (dev != NULL) {
 			packet_dev_mc(dev, ml, -1);
 			dev_put(dev);
 		}
@@ -1723,7 +1721,7 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 			return -EINVAL;
 		if (len > sizeof(mreq))
 			len = sizeof(mreq);
-		if (copy_from_user(&mreq,optval,len))
+		if (copy_from_user(&mreq, optval, len))
 			return -EFAULT;
 		if (len < (mreq.mr_alen + offsetof(struct packet_mreq, mr_address)))
 			return -EINVAL;
@@ -1740,9 +1738,9 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 	{
 		struct tpacket_req req;
 
-		if (optlen<sizeof(req))
+		if (optlen < sizeof(req))
 			return -EINVAL;
-		if (copy_from_user(&req,optval,sizeof(req)))
+		if (copy_from_user(&req, optval, sizeof(req)))
 			return -EFAULT;
 		return packet_set_ring(sk, &req, 0, optname == PACKET_TX_RING);
 	}
@@ -1750,9 +1748,9 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 	{
 		int val;
 
-		if (optlen!=sizeof(val))
+		if (optlen != sizeof(val))
 			return -EINVAL;
-		if (copy_from_user(&val,optval,sizeof(val)))
+		if (copy_from_user(&val, optval, sizeof(val)))
 			return -EFAULT;
 
 		pkt_sk(sk)->copy_thresh = val;
@@ -1985,51 +1983,51 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
 	struct sock *sk = sock->sk;
 
 	switch (cmd) {
-		case SIOCOUTQ:
-		{
-			int amount = sk_wmem_alloc_get(sk);
+	case SIOCOUTQ:
+	{
+		int amount = sk_wmem_alloc_get(sk);
 
-			return put_user(amount, (int __user *)arg);
-		}
-		case SIOCINQ:
-		{
-			struct sk_buff *skb;
-			int amount = 0;
-
-			spin_lock_bh(&sk->sk_receive_queue.lock);
-			skb = skb_peek(&sk->sk_receive_queue);
-			if (skb)
-				amount = skb->len;
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
-			return put_user(amount, (int __user *)arg);
-		}
-		case SIOCGSTAMP:
-			return sock_get_timestamp(sk, (struct timeval __user *)arg);
-		case SIOCGSTAMPNS:
-			return sock_get_timestampns(sk, (struct timespec __user *)arg);
+		return put_user(amount, (int __user *)arg);
+	}
+	case SIOCINQ:
+	{
+		struct sk_buff *skb;
+		int amount = 0;
+
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb)
+			amount = skb->len;
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		return put_user(amount, (int __user *)arg);
+	}
+	case SIOCGSTAMP:
+		return sock_get_timestamp(sk, (struct timeval __user *)arg);
+	case SIOCGSTAMPNS:
+		return sock_get_timestampns(sk, (struct timespec __user *)arg);
 
 #ifdef CONFIG_INET
-		case SIOCADDRT:
-		case SIOCDELRT:
-		case SIOCDARP:
-		case SIOCGARP:
-		case SIOCSARP:
-		case SIOCGIFADDR:
-		case SIOCSIFADDR:
-		case SIOCGIFBRDADDR:
-		case SIOCSIFBRDADDR:
-		case SIOCGIFNETMASK:
-		case SIOCSIFNETMASK:
-		case SIOCGIFDSTADDR:
-		case SIOCSIFDSTADDR:
-		case SIOCSIFFLAGS:
-			if (!net_eq(sock_net(sk), &init_net))
-				return -ENOIOCTLCMD;
-			return inet_dgram_ops.ioctl(sock, cmd, arg);
+	case SIOCADDRT:
+	case SIOCDELRT:
+	case SIOCDARP:
+	case SIOCGARP:
+	case SIOCSARP:
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+	case SIOCGIFBRDADDR:
+	case SIOCSIFBRDADDR:
+	case SIOCGIFNETMASK:
+	case SIOCSIFNETMASK:
+	case SIOCGIFDSTADDR:
+	case SIOCSIFDSTADDR:
+	case SIOCSIFFLAGS:
+		if (!net_eq(sock_net(sk), &init_net))
+			return -ENOIOCTLCMD;
+		return inet_dgram_ops.ioctl(sock, cmd, arg);
 #endif
 
-		default:
-			return -ENOIOCTLCMD;
+	default:
+		return -ENOIOCTLCMD;
 	}
 	return 0;
 }
@@ -2039,7 +2037,7 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
 #define packet_poll datagram_poll
 #else
 
-static unsigned int packet_poll(struct file * file, struct socket *sock,
+static unsigned int packet_poll(struct file *file, struct socket *sock,
 				poll_table *wait)
 {
 	struct sock *sk = sock->sk;
@@ -2069,7 +2067,7 @@ static unsigned int packet_poll(struct file * file, struct socket *sock,
 static void packet_mm_open(struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
-	struct socket * sock = file->private_data;
+	struct socket *sock = file->private_data;
 	struct sock *sk = sock->sk;
 
 	if (sk)
@@ -2079,7 +2077,7 @@ static void packet_mm_open(struct vm_area_struct *vma)
 static void packet_mm_close(struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
-	struct socket * sock = file->private_data;
+	struct socket *sock = file->private_data;
 	struct sock *sk = sock->sk;
 
 	if (sk)
@@ -2087,8 +2085,8 @@ static void packet_mm_close(struct vm_area_struct *vma)
 }
 
 static struct vm_operations_struct packet_mmap_ops = {
-	.open =	packet_mm_open,
-	.close =packet_mm_close,
+	.open	=	packet_mm_open,
+	.close	=	packet_mm_close,
 };
 
 static void free_pg_vec(char **pg_vec, unsigned int order, unsigned int len)
@@ -2239,8 +2237,8 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 		skb_queue_purge(rb_queue);
 #undef XC
 		if (atomic_read(&po->mapped))
-			printk(KERN_DEBUG "packet_mmap: vma is busy: %d\n",
-						atomic_read(&po->mapped));
+			pr_err("packet_mmap: vma is busy: %d\n",
+			       atomic_read(&po->mapped));
 	}
 	mutex_unlock(&po->pg_vec_lock);
 
@@ -2303,7 +2301,7 @@ static int packet_mmap(struct file *file, struct socket *sock,
 			int pg_num;
 
 			for (pg_num = 0; pg_num < rb->pg_vec_pages;
-					pg_num++,page++) {
+					pg_num++, page++) {
 				err = vm_insert_page(vma, start, page);
 				if (unlikely(err))
 					goto out;
@@ -2372,7 +2370,7 @@ static struct net_proto_family packet_family_ops = {
 };
 
 static struct notifier_block packet_netdev_notifier = {
-	.notifier_call =packet_notifier,
+	.notifier_call =	packet_notifier,
 };
 
 #ifdef CONFIG_PROC_FS
@@ -2402,7 +2400,7 @@ static void *packet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	++*pos;
 	return  (v == SEQ_START_TOKEN)
 		? sk_head(&net->packet.sklist)
-		: sk_next((struct sock*)v) ;
+		: sk_next((struct sock *)v) ;
 }
 
 static void packet_seq_stop(struct seq_file *seq, void *v)
@@ -2430,7 +2428,7 @@ static int packet_seq_show(struct seq_file *seq, void *v)
 			   po->running,
 			   atomic_read(&s->sk_rmem_alloc),
 			   sock_i_uid(s),
-			   sock_i_ino(s) );
+			   sock_i_ino(s));
 	}
 
 	return 0;
