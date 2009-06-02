From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: ipv4/ip_sockglue.c cleanups
Date: Tue, 02 Jun 2009 09:41:01 +0200
Message-ID: <4A24D78D.3020909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35576 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600AbZFBHlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:41:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pure cleanups

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e2d1f87..5f1a038 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -157,38 +157,39 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 	/* Ordered by supposed usage frequency */
 	if (flags & 1)
 		ip_cmsg_recv_pktinfo(msg, skb);
-	if ((flags>>=1) == 0)
+	if ((flags >>= 1) == 0)
 		return;
 
 	if (flags & 1)
 		ip_cmsg_recv_ttl(msg, skb);
-	if ((flags>>=1) == 0)
+	if ((flags >>= 1) == 0)
 		return;
 
 	if (flags & 1)
 		ip_cmsg_recv_tos(msg, skb);
-	if ((flags>>=1) == 0)
+	if ((flags >>= 1) == 0)
 		return;
 
 	if (flags & 1)
 		ip_cmsg_recv_opts(msg, skb);
-	if ((flags>>=1) == 0)
+	if ((flags >>= 1) == 0)
 		return;
 
 	if (flags & 1)
 		ip_cmsg_recv_retopts(msg, skb);
-	if ((flags>>=1) == 0)
+	if ((flags >>= 1) == 0)
 		return;
 
 	if (flags & 1)
 		ip_cmsg_recv_security(msg, skb);
 
-	if ((flags>>=1) == 0)
+	if ((flags >>= 1) == 0)
 		return;
 	if (flags & 1)
 		ip_cmsg_recv_dstaddr(msg, skb);
 
 }
+EXPORT_SYMBOL(ip_cmsg_recv);
 
 int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 {
@@ -203,7 +204,8 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 		switch (cmsg->cmsg_type) {
 		case IP_RETOPTS:
 			err = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
-			err = ip_options_get(net, &ipc->opt, CMSG_DATA(cmsg), err < 40 ? err : 40);
+			err = ip_options_get(net, &ipc->opt, CMSG_DATA(cmsg),
+					     err < 40 ? err : 40);
 			if (err)
 				return err;
 			break;
@@ -238,7 +240,8 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 struct ip_ra_chain *ip_ra_chain;
 DEFINE_RWLOCK(ip_ra_lock);
 
-int ip_ra_control(struct sock *sk, unsigned char on, void (*destructor)(struct sock *))
+int ip_ra_control(struct sock *sk, unsigned char on,
+		  void (*destructor)(struct sock *))
 {
 	struct ip_ra_chain *ra, *new_ra, **rap;
 
@@ -248,7 +251,7 @@ int ip_ra_control(struct sock *sk, unsigned char on, void (*destructor)(struct s
 	new_ra = on ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
 
 	write_lock_bh(&ip_ra_lock);
-	for (rap = &ip_ra_chain; (ra=*rap) != NULL; rap = &ra->next) {
+	for (rap = &ip_ra_chain; (ra = *rap) != NULL; rap = &ra->next) {
 		if (ra->sk == sk) {
 			if (on) {
 				write_unlock_bh(&ip_ra_lock);
@@ -416,7 +419,8 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len)
 	/* Reset and regenerate socket error */
 	spin_lock_bh(&sk->sk_error_queue.lock);
 	sk->sk_err = 0;
-	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
+	skb2 = skb_peek(&sk->sk_error_queue);
+	if (skb2 != NULL) {
 		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
 		spin_unlock_bh(&sk->sk_error_queue.lock);
 		sk->sk_error_report(sk);
@@ -431,8 +435,8 @@ out:
 
 
 /*
- *	Socket option code for IP. This is the end of the line after any TCP,UDP etc options on
- *	an IP socket.
+ *	Socket option code for IP. This is the end of the line after any
+ *	TCP,UDP etc options on an IP socket.
  */
 
 static int do_ip_setsockopt(struct sock *sk, int level,
@@ -474,7 +478,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	switch (optname) {
 	case IP_OPTIONS:
 	{
-		struct ip_options * opt = NULL;
+		struct ip_options *opt = NULL;
 		if (optlen > 40 || optlen < 0)
 			goto e_inval;
 		err = ip_options_get_from_user(sock_net(sk), &opt,
@@ -556,9 +560,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 		break;
 	case IP_TTL:
-		if (optlen<1)
+		if (optlen < 1)
 			goto e_inval;
-		if (val != -1 && (val < 1 || val>255))
+		if (val != -1 && (val < 0 || val > 255))
 			goto e_inval;
 		inet->uc_ttl = val;
 		break;
@@ -570,7 +574,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->hdrincl = val ? 1 : 0;
 		break;
 	case IP_MTU_DISCOVER:
-		if (val<0 || val>3)
+		if (val < 0 || val > 3)
 			goto e_inval;
 		inet->pmtudisc = val;
 		break;
@@ -582,7 +586,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_MULTICAST_TTL:
 		if (sk->sk_type == SOCK_STREAM)
 			goto e_inval;
-		if (optlen<1)
+		if (optlen < 1)
 			goto e_inval;
 		if (val == -1)
 			val = 1;
@@ -591,7 +595,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->mc_ttl = val;
 		break;
 	case IP_MULTICAST_LOOP:
-		if (optlen<1)
+		if (optlen < 1)
 			goto e_inval;
 		inet->mc_loop = !!val;
 		break;
@@ -613,7 +617,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
 			if (optlen >= sizeof(struct in_addr) &&
-			    copy_from_user(&mreq.imr_address, optval, sizeof(struct in_addr)))
+			    copy_from_user(&mreq.imr_address, optval,
+					   sizeof(struct in_addr)))
 				break;
 		}
 
@@ -677,7 +682,6 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	}
 	case IP_MSFILTER:
 	{
-		extern int sysctl_igmp_max_msf;
 		struct ip_msfilter *msf;
 
 		if (optlen < IP_MSFILTER_SIZE(0))
@@ -831,7 +835,6 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	}
 	case MCAST_MSFILTER:
 	{
-		extern int sysctl_igmp_max_msf;
 		struct sockaddr_in *psin;
 		struct ip_msfilter *msf = NULL;
 		struct group_filter *gsf = NULL;
@@ -849,9 +852,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			break;
 		}
 		err = -EFAULT;
-		if (copy_from_user(gsf, optval, optlen)) {
+		if (copy_from_user(gsf, optval, optlen))
 			goto mc_msf_out;
-		}
+
 		/* numsrc >= (4G-140)/128 overflow in 32 bits */
 		if (gsf->gf_numsrc >= 0x1ffffff ||
 		    gsf->gf_numsrc > sysctl_igmp_max_msf) {
@@ -879,7 +882,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		msf->imsf_fmode = gsf->gf_fmode;
 		msf->imsf_numsrc = gsf->gf_numsrc;
 		err = -EADDRNOTAVAIL;
-		for (i=0; i<gsf->gf_numsrc; ++i) {
+		for (i = 0; i < gsf->gf_numsrc; ++i) {
 			psin = (struct sockaddr_in *)&gsf->gf_slist[i];
 
 			if (psin->sin_family != AF_INET)
@@ -890,7 +893,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		gsf = NULL;
 
 		err = ip_mc_msfilter(sk, msf, ifindex);
-	mc_msf_out:
+mc_msf_out:
 		kfree(msf);
 		kfree(gsf);
 		break;
@@ -900,7 +903,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		break;
 
 	case IP_FREEBIND:
-		if (optlen<1)
+		if (optlen < 1)
 			goto e_inval;
 		inet->freebind = !!val;
 		break;
@@ -957,6 +960,7 @@ int ip_setsockopt(struct sock *sk, int level,
 #endif
 	return err;
 }
+EXPORT_SYMBOL(ip_setsockopt);
 
 #ifdef CONFIG_COMPAT
 int compat_ip_setsockopt(struct sock *sk, int level, int optname,
@@ -986,13 +990,12 @@ int compat_ip_setsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(compat_ip_setsockopt);
 #endif
 
 /*
- *	Get the options. Note for future reference. The GET of IP options gets the
- *	_received_ ones. The set sets the _sent_ ones.
+ *	Get the options. Note for future reference. The GET of IP options gets
+ *	the _received_ ones. The set sets the _sent_ ones.
  */
 
 static int do_ip_getsockopt(struct sock *sk, int level, int optname,
@@ -1143,7 +1146,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 			return -EFAULT;
 		}
 		err = ip_mc_gsfget(sk, &gsf,
-				   (struct group_filter __user *)optval, optlen);
+				   (struct group_filter __user *)optval,
+				   optlen);
 		release_sock(sk);
 		return err;
 	}
@@ -1187,7 +1191,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	}
 	release_sock(sk);
 
-	if (len < sizeof(int) && len > 0 && val>=0 && val<=255) {
+	if (len < sizeof(int) && len > 0 && val >= 0 && val <= 255) {
 		unsigned char ucval = (unsigned char)val;
 		len = 1;
 		if (put_user(len, optlen))
@@ -1230,6 +1234,7 @@ int ip_getsockopt(struct sock *sk, int level,
 #endif
 	return err;
 }
+EXPORT_SYMBOL(ip_getsockopt);
 
 #ifdef CONFIG_COMPAT
 int compat_ip_getsockopt(struct sock *sk, int level, int optname,
@@ -1262,11 +1267,5 @@ int compat_ip_getsockopt(struct sock *sk, int level, int optname,
 #endif
 	return err;
 }
-
 EXPORT_SYMBOL(compat_ip_getsockopt);
 #endif
-
-EXPORT_SYMBOL(ip_cmsg_recv);
-
-EXPORT_SYMBOL(ip_getsockopt);
-EXPORT_SYMBOL(ip_setsockopt);
