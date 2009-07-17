From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] udp: cleanups
Date: Fri, 17 Jul 2009 12:26:32 +0200
Message-ID: <4A6051D8.3080804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47870 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934323AbZGQK0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 06:26:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pure style cleanups.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/udp.c |   87 +++++++++++++++++++++++------------------------
 1 files changed, 43 insertions(+), 44 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7bc2d08..8640d72 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -110,11 +110,12 @@ struct udp_table udp_table;
 EXPORT_SYMBOL(udp_table);
 
 int sysctl_udp_mem[3] __read_mostly;
-int sysctl_udp_rmem_min __read_mostly;
-int sysctl_udp_wmem_min __read_mostly;
-
 EXPORT_SYMBOL(sysctl_udp_mem);
+
+int sysctl_udp_rmem_min __read_mostly;
 EXPORT_SYMBOL(sysctl_udp_rmem_min);
+
+int sysctl_udp_wmem_min __read_mostly;
 EXPORT_SYMBOL(sysctl_udp_wmem_min);
 
 atomic_t udp_memory_allocated;
@@ -158,7 +159,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
  */
 int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       int (*saddr_comp)(const struct sock *sk1,
-					 const struct sock *sk2 )    )
+					 const struct sock *sk2))
 {
 	struct udp_hslot *hslot;
 	struct udp_table *udptable = sk->sk_prot->h.udp_table;
@@ -221,14 +222,15 @@ fail_unlock:
 fail:
 	return error;
 }
+EXPORT_SYMBOL(udp_lib_get_port);
 
 static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
-	return 	( !ipv6_only_sock(sk2)  &&
-		  (!inet1->rcv_saddr || !inet2->rcv_saddr ||
-		   inet1->rcv_saddr == inet2->rcv_saddr      ));
+	return 	(!ipv6_only_sock(sk2)  &&
+		 (!inet1->rcv_saddr || !inet2->rcv_saddr ||
+		   inet1->rcv_saddr == inet2->rcv_saddr));
 }
 
 int udp_v4_get_port(struct sock *sk, unsigned short snum)
@@ -383,8 +385,8 @@ found:
 void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 {
 	struct inet_sock *inet;
-	struct iphdr *iph = (struct iphdr*)skb->data;
-	struct udphdr *uh = (struct udphdr*)(skb->data+(iph->ihl<<2));
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct udphdr *uh = (struct udphdr *)(skb->data+(iph->ihl<<2));
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct sock *sk;
@@ -439,7 +441,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 		if (!harderr || sk->sk_state != TCP_ESTABLISHED)
 			goto out;
 	} else {
-		ip_icmp_error(sk, skb, err, uh->dest, info, (u8*)(uh+1));
+		ip_icmp_error(sk, skb, err, uh->dest, info, (u8 *)(uh+1));
 	}
 	sk->sk_err = err;
 	sk->sk_error_report(sk);
@@ -474,7 +476,7 @@ EXPORT_SYMBOL(udp_flush_pending_frames);
  * 	        (checksum field must be zeroed out)
  */
 static void udp4_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
-				 __be32 src, __be32 dst, int len      )
+				 __be32 src, __be32 dst, int len)
 {
 	unsigned int offset;
 	struct udphdr *uh = udp_hdr(skb);
@@ -545,7 +547,7 @@ static int udp_push_pending_frames(struct sock *sk)
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
 
-		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src,fl->fl4_dst, up->len);
+		udp4_hwcsum_outgoing(sk, skb, fl->fl4_src, fl->fl4_dst, up->len);
 		goto send;
 
 	} else						 /*   `normal' UDP    */
@@ -553,7 +555,7 @@ static int udp_push_pending_frames(struct sock *sk)
 
 	/* add protocol-dependent pseudo-header */
 	uh->check = csum_tcpudp_magic(fl->fl4_src, fl->fl4_dst, up->len,
-				      sk->sk_protocol, csum             );
+				      sk->sk_protocol, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
@@ -592,7 +594,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 *	Check the flags.
 	 */
 
-	if (msg->msg_flags&MSG_OOB)	/* Mirror BSD error message compatibility */
+	if (msg->msg_flags & MSG_OOB) /* Mirror BSD error message compatibility */
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
@@ -619,7 +621,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 *	Get and verify the address.
 	 */
 	if (msg->msg_name) {
-		struct sockaddr_in * usin = (struct sockaddr_in*)msg->msg_name;
+		struct sockaddr_in * usin = (struct sockaddr_in *)msg->msg_name;
 		if (msg->msg_namelen < sizeof(*usin))
 			return -EINVAL;
 		if (usin->sin_family != AF_INET) {
@@ -684,7 +686,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	if (connected)
-		rt = (struct rtable*)sk_dst_check(sk, 0);
+		rt = (struct rtable *)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
 		struct flowi fl = { .oif = ipc.oif,
@@ -782,6 +784,7 @@ do_confirm:
 	err = 0;
 	goto out;
 }
+EXPORT_SYMBOL(udp_sendmsg);
 
 int udp_sendpage(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags)
@@ -871,6 +874,7 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 
 	return 0;
 }
+EXPORT_SYMBOL(udp_ioctl);
 
 /*
  * 	This should be easy, if there is something there we
@@ -892,7 +896,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 *	Check any passed addresses
 	 */
 	if (addr_len)
-		*addr_len=sizeof(*sin);
+		*addr_len = sizeof(*sin);
 
 	if (flags & MSG_ERRQUEUE)
 		return ip_recv_error(sk, msg, len);
@@ -923,9 +927,11 @@ try_again:
 
 	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
-					      msg->msg_iov, copied       );
+					      msg->msg_iov, copied);
 	else {
-		err = skb_copy_and_csum_datagram_iovec(skb, sizeof(struct udphdr), msg->msg_iov);
+		err = skb_copy_and_csum_datagram_iovec(skb,
+						       sizeof(struct udphdr),
+						       msg->msg_iov);
 
 		if (err == -EINVAL)
 			goto csum_copy_err;
@@ -941,8 +947,7 @@ try_again:
 	sock_recv_timestamp(msg, sk, skb);
 
 	/* Copy the address. */
-	if (sin)
-	{
+	if (sin) {
 		sin->sin_family = AF_INET;
 		sin->sin_port = udp_hdr(skb)->source;
 		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
@@ -995,6 +1000,7 @@ int udp_disconnect(struct sock *sk, int flags)
 	sk_dst_reset(sk);
 	return 0;
 }
+EXPORT_SYMBOL(udp_disconnect);
 
 void udp_lib_unhash(struct sock *sk)
 {
@@ -1044,7 +1050,7 @@ drop:
  * Note that in the success and error cases, the skb is assumed to
  * have either been requeued or freed.
  */
-int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
+int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
@@ -1214,7 +1220,7 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 	if (uh->check == 0) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
-	       if (!csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
+		if (!csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
 				      proto, skb->csum))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
@@ -1355,7 +1361,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
 
-	if (optlen<sizeof(int))
+	if (optlen < sizeof(int))
 		return -EINVAL;
 
 	if (get_user(val, (int __user *)optval))
@@ -1426,6 +1432,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 
 	return err;
 }
+EXPORT_SYMBOL(udp_lib_setsockopt);
 
 int udp_setsockopt(struct sock *sk, int level, int optname,
 		   char __user *optval, int optlen)
@@ -1453,7 +1460,7 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 	struct udp_sock *up = udp_sk(sk);
 	int val, len;
 
-	if (get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 
 	len = min_t(unsigned int, len, sizeof(int));
@@ -1486,10 +1493,11 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 
 	if (put_user(len, optlen))
 		return -EFAULT;
-	if (copy_to_user(optval, &val,len))
+	if (copy_to_user(optval, &val, len))
 		return -EFAULT;
 	return 0;
 }
+EXPORT_SYMBOL(udp_lib_getsockopt);
 
 int udp_getsockopt(struct sock *sk, int level, int optname,
 		   char __user *optval, int __user *optlen)
@@ -1528,9 +1536,9 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	int 	is_lite = IS_UDPLITE(sk);
 
 	/* Check for false positives due to checksum errors */
-	if ( (mask & POLLRDNORM) &&
-	     !(file->f_flags & O_NONBLOCK) &&
-	     !(sk->sk_shutdown & RCV_SHUTDOWN)){
+	if ((mask & POLLRDNORM) &&
+	    !(file->f_flags & O_NONBLOCK) &&
+	    !(sk->sk_shutdown & RCV_SHUTDOWN)) {
 		struct sk_buff_head *rcvq = &sk->sk_receive_queue;
 		struct sk_buff *skb;
 
@@ -1552,6 +1560,7 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	return mask;
 
 }
+EXPORT_SYMBOL(udp_poll);
 
 struct proto udp_prot = {
 	.name		   = "UDP",
@@ -1582,6 +1591,7 @@ struct proto udp_prot = {
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
 };
+EXPORT_SYMBOL(udp_prot);
 
 /* ------------------------------------------------------------------------ */
 #ifdef CONFIG_PROC_FS
@@ -1703,11 +1713,13 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 		rc = -ENOMEM;
 	return rc;
 }
+EXPORT_SYMBOL(udp_proc_register);
 
 void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo)
 {
 	proc_net_remove(net, afinfo->name);
 }
+EXPORT_SYMBOL(udp_proc_unregister);
 
 /* ------------------------------------------------------------------------ */
 static void udp4_format_sock(struct sock *sp, struct seq_file *f,
@@ -1741,7 +1753,7 @@ int udp4_seq_show(struct seq_file *seq, void *v)
 		int len;
 
 		udp4_format_sock(v, seq, state->bucket, &len);
-		seq_printf(seq, "%*s\n", 127 - len ,"");
+		seq_printf(seq, "%*s\n", 127 - len, "");
 	}
 	return 0;
 }
@@ -1864,7 +1876,7 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, int features)
 	 * do checksum of UDP packets sent as multiple IP fragments.
 	 */
 	offset = skb->csum_start - skb_headroom(skb);
-	csum = skb_checksum(skb, offset, skb->len- offset, 0);
+	csum = skb_checksum(skb, offset, skb->len - offset, 0);
 	offset += skb->csum_offset;
 	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
 	skb->ip_summed = CHECKSUM_NONE;
@@ -1877,16 +1889,3 @@ out:
 	return segs;
 }
 
-EXPORT_SYMBOL(udp_disconnect);
-EXPORT_SYMBOL(udp_ioctl);
-EXPORT_SYMBOL(udp_prot);
-EXPORT_SYMBOL(udp_sendmsg);
-EXPORT_SYMBOL(udp_lib_getsockopt);
-EXPORT_SYMBOL(udp_lib_setsockopt);
-EXPORT_SYMBOL(udp_poll);
-EXPORT_SYMBOL(udp_lib_get_port);
-
-#ifdef CONFIG_PROC_FS
-EXPORT_SYMBOL(udp_proc_register);
-EXPORT_SYMBOL(udp_proc_unregister);
-#endif
