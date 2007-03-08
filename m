From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/8] network core: whitespace cleanup
Date: Thu, 08 Mar 2007 12:52:17 -0800
Message-ID: <20070308205305.774302695@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35778 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933322AbXCHUyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:40 -0500
Content-Disposition: inline; filename=core-cleanup
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix whitespace around keywords. Fix indentation especially of switch
statements.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/compat.c         |   30 +-
 net/core/ethtool.c   |    4 
 net/core/net-sysfs.c |    4 
 net/core/pktgen.c    |   16 -
 net/core/sock.c      |  710 +++++++++++++++++++++++++--------------------------
 net/core/wireless.c  |  297 ++++++++++-----------
 net/socket.c         |    2 
 7 files changed, 529 insertions(+), 534 deletions(-)

--- net-2.6.22.orig/net/core/sock.c	2007-03-08 12:48:49.000000000 -0800
+++ net-2.6.22/net/core/sock.c	2007-03-08 12:51:38.000000000 -0800
@@ -361,8 +361,8 @@
 	}
 #endif
 
-	if(optlen<sizeof(int))
-		return(-EINVAL);
+	if (optlen < sizeof(int))
+		return -EINVAL;
 
 	if (get_user(val, (int __user *)optval))
 		return -EFAULT;
@@ -371,265 +371,263 @@
 
 	lock_sock(sk);
 
-	switch(optname)
-	{
-		case SO_DEBUG:
-			if(val && !capable(CAP_NET_ADMIN))
-			{
-				ret = -EACCES;
-			}
-			else if (valbool)
-				sock_set_flag(sk, SOCK_DBG);
-			else
-				sock_reset_flag(sk, SOCK_DBG);
-			break;
-		case SO_REUSEADDR:
-			sk->sk_reuse = valbool;
-			break;
-		case SO_TYPE:
-		case SO_ERROR:
-			ret = -ENOPROTOOPT;
-			break;
-		case SO_DONTROUTE:
-			if (valbool)
-				sock_set_flag(sk, SOCK_LOCALROUTE);
-			else
-				sock_reset_flag(sk, SOCK_LOCALROUTE);
-			break;
-		case SO_BROADCAST:
-			sock_valbool_flag(sk, SOCK_BROADCAST, valbool);
-			break;
-		case SO_SNDBUF:
-			/* Don't error on this BSD doesn't and if you think
-			   about it this is right. Otherwise apps have to
-			   play 'guess the biggest size' games. RCVBUF/SNDBUF
-			   are treated in BSD as hints */
+	switch(optname) {
+	case SO_DEBUG:
+		if (val && !capable(CAP_NET_ADMIN)) {
+			ret = -EACCES;
+		}
+		else if (valbool)
+			sock_set_flag(sk, SOCK_DBG);
+		else
+			sock_reset_flag(sk, SOCK_DBG);
+		break;
+	case SO_REUSEADDR:
+		sk->sk_reuse = valbool;
+		break;
+	case SO_TYPE:
+	case SO_ERROR:
+		ret = -ENOPROTOOPT;
+		break;
+	case SO_DONTROUTE:
+		if (valbool)
+			sock_set_flag(sk, SOCK_LOCALROUTE);
+		else
+			sock_reset_flag(sk, SOCK_LOCALROUTE);
+		break;
+	case SO_BROADCAST:
+		sock_valbool_flag(sk, SOCK_BROADCAST, valbool);
+		break;
+	case SO_SNDBUF:
+		/* Don't error on this BSD doesn't and if you think
+		   about it this is right. Otherwise apps have to
+		   play 'guess the biggest size' games. RCVBUF/SNDBUF
+		   are treated in BSD as hints */
 
-			if (val > sysctl_wmem_max)
-				val = sysctl_wmem_max;
+		if (val > sysctl_wmem_max)
+			val = sysctl_wmem_max;
 set_sndbuf:
-			sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
-			if ((val * 2) < SOCK_MIN_SNDBUF)
-				sk->sk_sndbuf = SOCK_MIN_SNDBUF;
-			else
-				sk->sk_sndbuf = val * 2;
+		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
+		if ((val * 2) < SOCK_MIN_SNDBUF)
+			sk->sk_sndbuf = SOCK_MIN_SNDBUF;
+		else
+			sk->sk_sndbuf = val * 2;
 
-			/*
-			 *	Wake up sending tasks if we
-			 *	upped the value.
-			 */
-			sk->sk_write_space(sk);
-			break;
+		/*
+		 *	Wake up sending tasks if we
+		 *	upped the value.
+		 */
+		sk->sk_write_space(sk);
+		break;
 
-		case SO_SNDBUFFORCE:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret = -EPERM;
-				break;
-			}
-			goto set_sndbuf;
+	case SO_SNDBUFFORCE:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret = -EPERM;
+			break;
+		}
+		goto set_sndbuf;
 
-		case SO_RCVBUF:
-			/* Don't error on this BSD doesn't and if you think
-			   about it this is right. Otherwise apps have to
-			   play 'guess the biggest size' games. RCVBUF/SNDBUF
-			   are treated in BSD as hints */
+	case SO_RCVBUF:
+		/* Don't error on this BSD doesn't and if you think
+		   about it this is right. Otherwise apps have to
+		   play 'guess the biggest size' games. RCVBUF/SNDBUF
+		   are treated in BSD as hints */
 
-			if (val > sysctl_rmem_max)
-				val = sysctl_rmem_max;
+		if (val > sysctl_rmem_max)
+			val = sysctl_rmem_max;
 set_rcvbuf:
-			sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
-			/*
-			 * We double it on the way in to account for
-			 * "struct sk_buff" etc. overhead.   Applications
-			 * assume that the SO_RCVBUF setting they make will
-			 * allow that much actual data to be received on that
-			 * socket.
-			 *
-			 * Applications are unaware that "struct sk_buff" and
-			 * other overheads allocate from the receive buffer
-			 * during socket buffer allocation.
-			 *
-			 * And after considering the possible alternatives,
-			 * returning the value we actually used in getsockopt
-			 * is the most desirable behavior.
-			 */
-			if ((val * 2) < SOCK_MIN_RCVBUF)
-				sk->sk_rcvbuf = SOCK_MIN_RCVBUF;
-			else
-				sk->sk_rcvbuf = val * 2;
+		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
+		/*
+		 * We double it on the way in to account for
+		 * "struct sk_buff" etc. overhead.   Applications
+		 * assume that the SO_RCVBUF setting they make will
+		 * allow that much actual data to be received on that
+		 * socket.
+		 *
+		 * Applications are unaware that "struct sk_buff" and
+		 * other overheads allocate from the receive buffer
+		 * during socket buffer allocation.
+		 *
+		 * And after considering the possible alternatives,
+		 * returning the value we actually used in getsockopt
+		 * is the most desirable behavior.
+		 */
+		if ((val * 2) < SOCK_MIN_RCVBUF)
+			sk->sk_rcvbuf = SOCK_MIN_RCVBUF;
+		else
+			sk->sk_rcvbuf = val * 2;
+		break;
+
+	case SO_RCVBUFFORCE:
+		if (!capable(CAP_NET_ADMIN)) {
+			ret = -EPERM;
 			break;
+		}
+		goto set_rcvbuf;
 
-		case SO_RCVBUFFORCE:
-			if (!capable(CAP_NET_ADMIN)) {
-				ret = -EPERM;
-				break;
-			}
-			goto set_rcvbuf;
-
-		case SO_KEEPALIVE:
+	case SO_KEEPALIVE:
 #ifdef CONFIG_INET
-			if (sk->sk_protocol == IPPROTO_TCP)
-				tcp_set_keepalive(sk, valbool);
+		if (sk->sk_protocol == IPPROTO_TCP)
+			tcp_set_keepalive(sk, valbool);
 #endif
-			sock_valbool_flag(sk, SOCK_KEEPOPEN, valbool);
-			break;
-
-		case SO_OOBINLINE:
-			sock_valbool_flag(sk, SOCK_URGINLINE, valbool);
-			break;
+		sock_valbool_flag(sk, SOCK_KEEPOPEN, valbool);
+		break;
 
-		case SO_NO_CHECK:
-			sk->sk_no_check = valbool;
+	case SO_OOBINLINE:
+		sock_valbool_flag(sk, SOCK_URGINLINE, valbool);
+		break;
+
+	case SO_NO_CHECK:
+		sk->sk_no_check = valbool;
+		break;
+
+	case SO_PRIORITY:
+		if ((val >= 0 && val <= 6) || capable(CAP_NET_ADMIN))
+			sk->sk_priority = val;
+		else
+			ret = -EPERM;
+		break;
+
+	case SO_LINGER:
+		if (optlen < sizeof(ling)) {
+			ret = -EINVAL;	/* 1003.1g */
 			break;
-
-		case SO_PRIORITY:
-			if ((val >= 0 && val <= 6) || capable(CAP_NET_ADMIN))
-				sk->sk_priority = val;
-			else
-				ret = -EPERM;
+		}
+		if (copy_from_user(&ling,optval,sizeof(ling))) {
+			ret = -EFAULT;
 			break;
-
-		case SO_LINGER:
-			if(optlen<sizeof(ling)) {
-				ret = -EINVAL;	/* 1003.1g */
-				break;
-			}
-			if (copy_from_user(&ling,optval,sizeof(ling))) {
-				ret = -EFAULT;
-				break;
-			}
-			if (!ling.l_onoff)
-				sock_reset_flag(sk, SOCK_LINGER);
-			else {
+		}
+		if (!ling.l_onoff)
+			sock_reset_flag(sk, SOCK_LINGER);
+		else {
 #if (BITS_PER_LONG == 32)
-				if ((unsigned int)ling.l_linger >= MAX_SCHEDULE_TIMEOUT/HZ)
-					sk->sk_lingertime = MAX_SCHEDULE_TIMEOUT;
-				else
-#endif
-					sk->sk_lingertime = (unsigned int)ling.l_linger * HZ;
-				sock_set_flag(sk, SOCK_LINGER);
-			}
-			break;
-
-		case SO_BSDCOMPAT:
-			sock_warn_obsolete_bsdism("setsockopt");
-			break;
-
-		case SO_PASSCRED:
-			if (valbool)
-				set_bit(SOCK_PASSCRED, &sock->flags);
+			if ((unsigned int)ling.l_linger >= MAX_SCHEDULE_TIMEOUT/HZ)
+				sk->sk_lingertime = MAX_SCHEDULE_TIMEOUT;
 			else
-				clear_bit(SOCK_PASSCRED, &sock->flags);
-			break;
+#endif
+				sk->sk_lingertime = (unsigned int)ling.l_linger * HZ;
+			sock_set_flag(sk, SOCK_LINGER);
+		}
+		break;
 
-		case SO_TIMESTAMP:
-			if (valbool)  {
-				sock_set_flag(sk, SOCK_RCVTSTAMP);
-				sock_enable_timestamp(sk);
-			} else
-				sock_reset_flag(sk, SOCK_RCVTSTAMP);
-			break;
+	case SO_BSDCOMPAT:
+		sock_warn_obsolete_bsdism("setsockopt");
+		break;
+
+	case SO_PASSCRED:
+		if (valbool)
+			set_bit(SOCK_PASSCRED, &sock->flags);
+		else
+			clear_bit(SOCK_PASSCRED, &sock->flags);
+		break;
+
+	case SO_TIMESTAMP:
+		if (valbool)  {
+			sock_set_flag(sk, SOCK_RCVTSTAMP);
+			sock_enable_timestamp(sk);
+		} else
+			sock_reset_flag(sk, SOCK_RCVTSTAMP);
+		break;
+
+	case SO_RCVLOWAT:
+		if (val < 0)
+			val = INT_MAX;
+		sk->sk_rcvlowat = val ? : 1;
+		break;
+
+	case SO_RCVTIMEO:
+		ret = sock_set_timeout(&sk->sk_rcvtimeo, optval, optlen);
+		break;
+
+	case SO_SNDTIMEO:
+		ret = sock_set_timeout(&sk->sk_sndtimeo, optval, optlen);
+		break;
 
-		case SO_RCVLOWAT:
-			if (val < 0)
-				val = INT_MAX;
-			sk->sk_rcvlowat = val ? : 1;
-			break;
+#ifdef CONFIG_NETDEVICES
+	case SO_BINDTODEVICE:
+	{
+		char devname[IFNAMSIZ];
 
-		case SO_RCVTIMEO:
-			ret = sock_set_timeout(&sk->sk_rcvtimeo, optval, optlen);
+		/* Sorry... */
+		if (!capable(CAP_NET_RAW)) {
+			ret = -EPERM;
 			break;
+		}
 
-		case SO_SNDTIMEO:
-			ret = sock_set_timeout(&sk->sk_sndtimeo, optval, optlen);
-			break;
+		/* Bind this socket to a particular device like "eth0",
+		 * as specified in the passed interface name. If the
+		 * name is "" or the option length is zero the socket
+		 * is not bound.
+		 */
 
-#ifdef CONFIG_NETDEVICES
-		case SO_BINDTODEVICE:
-		{
-			char devname[IFNAMSIZ];
-
-			/* Sorry... */
-			if (!capable(CAP_NET_RAW)) {
-				ret = -EPERM;
+		if (!valbool) {
+			sk->sk_bound_dev_if = 0;
+		} else {
+			if (optlen > IFNAMSIZ - 1)
+				optlen = IFNAMSIZ - 1;
+			memset(devname, 0, sizeof(devname));
+			if (copy_from_user(devname, optval, optlen)) {
+				ret = -EFAULT;
 				break;
 			}
 
-			/* Bind this socket to a particular device like "eth0",
-			 * as specified in the passed interface name. If the
-			 * name is "" or the option length is zero the socket
-			 * is not bound.
-			 */
+			/* Remove any cached route for this socket. */
+			sk_dst_reset(sk);
 
-			if (!valbool) {
+			if (devname[0] == '\0') {
 				sk->sk_bound_dev_if = 0;
 			} else {
-				if (optlen > IFNAMSIZ - 1)
-					optlen = IFNAMSIZ - 1;
-				memset(devname, 0, sizeof(devname));
-				if (copy_from_user(devname, optval, optlen)) {
-					ret = -EFAULT;
+				struct net_device *dev = dev_get_by_name(devname);
+				if (!dev) {
+					ret = -ENODEV;
 					break;
 				}
-
-				/* Remove any cached route for this socket. */
-				sk_dst_reset(sk);
-
-				if (devname[0] == '\0') {
-					sk->sk_bound_dev_if = 0;
-				} else {
-					struct net_device *dev = dev_get_by_name(devname);
-					if (!dev) {
-						ret = -ENODEV;
-						break;
-					}
-					sk->sk_bound_dev_if = dev->ifindex;
-					dev_put(dev);
-				}
+				sk->sk_bound_dev_if = dev->ifindex;
+				dev_put(dev);
 			}
-			break;
 		}
+		break;
+	}
 #endif
 
 
-		case SO_ATTACH_FILTER:
-			ret = -EINVAL;
-			if (optlen == sizeof(struct sock_fprog)) {
-				struct sock_fprog fprog;
+	case SO_ATTACH_FILTER:
+		ret = -EINVAL;
+		if (optlen == sizeof(struct sock_fprog)) {
+			struct sock_fprog fprog;
 
-				ret = -EFAULT;
-				if (copy_from_user(&fprog, optval, sizeof(fprog)))
-					break;
+			ret = -EFAULT;
+			if (copy_from_user(&fprog, optval, sizeof(fprog)))
+				break;
 
-				ret = sk_attach_filter(&fprog, sk);
-			}
-			break;
+			ret = sk_attach_filter(&fprog, sk);
+		}
+		break;
 
-		case SO_DETACH_FILTER:
-			rcu_read_lock_bh();
-			filter = rcu_dereference(sk->sk_filter);
-			if (filter) {
-				rcu_assign_pointer(sk->sk_filter, NULL);
-				sk_filter_release(sk, filter);
-				rcu_read_unlock_bh();
-				break;
-			}
+	case SO_DETACH_FILTER:
+		rcu_read_lock_bh();
+		filter = rcu_dereference(sk->sk_filter);
+		if (filter) {
+			rcu_assign_pointer(sk->sk_filter, NULL);
+			sk_filter_release(sk, filter);
 			rcu_read_unlock_bh();
-			ret = -ENONET;
-			break;
-
-		case SO_PASSSEC:
-			if (valbool)
-				set_bit(SOCK_PASSSEC, &sock->flags);
-			else
-				clear_bit(SOCK_PASSSEC, &sock->flags);
 			break;
+		}
+		rcu_read_unlock_bh();
+		ret = -ENONET;
+		break;
+
+	case SO_PASSSEC:
+		if (valbool)
+			set_bit(SOCK_PASSSEC, &sock->flags);
+		else
+			clear_bit(SOCK_PASSSEC, &sock->flags);
+		break;
 
 		/* We implement the SO_SNDLOWAT etc to
 		   not be settable (1003.1g 5.3) */
-		default:
-			ret = -ENOPROTOOPT;
-			break;
+	default:
+		ret = -ENOPROTOOPT;
+		break;
 	}
 	release_sock(sk);
 	return ret;
@@ -641,8 +639,7 @@
 {
 	struct sock *sk = sock->sk;
 
-	union
-	{
+	union {
 		int val;
 		struct linger ling;
 		struct timeval tm;
@@ -651,148 +648,148 @@
 	unsigned int lv = sizeof(int);
 	int len;
 
-	if(get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
-	if(len < 0)
+	if (len < 0)
 		return -EINVAL;
 
-	switch(optname)
-	{
-		case SO_DEBUG:
-			v.val = sock_flag(sk, SOCK_DBG);
-			break;
-
-		case SO_DONTROUTE:
-			v.val = sock_flag(sk, SOCK_LOCALROUTE);
-			break;
-
-		case SO_BROADCAST:
-			v.val = !!sock_flag(sk, SOCK_BROADCAST);
-			break;
-
-		case SO_SNDBUF:
-			v.val = sk->sk_sndbuf;
-			break;
-
-		case SO_RCVBUF:
-			v.val = sk->sk_rcvbuf;
-			break;
-
-		case SO_REUSEADDR:
-			v.val = sk->sk_reuse;
-			break;
-
-		case SO_KEEPALIVE:
-			v.val = !!sock_flag(sk, SOCK_KEEPOPEN);
-			break;
-
-		case SO_TYPE:
-			v.val = sk->sk_type;
-			break;
-
-		case SO_ERROR:
-			v.val = -sock_error(sk);
-			if(v.val==0)
-				v.val = xchg(&sk->sk_err_soft, 0);
-			break;
-
-		case SO_OOBINLINE:
-			v.val = !!sock_flag(sk, SOCK_URGINLINE);
-			break;
-
-		case SO_NO_CHECK:
-			v.val = sk->sk_no_check;
-			break;
-
-		case SO_PRIORITY:
-			v.val = sk->sk_priority;
-			break;
-
-		case SO_LINGER:
-			lv		= sizeof(v.ling);
-			v.ling.l_onoff	= !!sock_flag(sk, SOCK_LINGER);
-			v.ling.l_linger	= sk->sk_lingertime / HZ;
-			break;
-
-		case SO_BSDCOMPAT:
-			sock_warn_obsolete_bsdism("getsockopt");
-			break;
-
-		case SO_TIMESTAMP:
-			v.val = sock_flag(sk, SOCK_RCVTSTAMP);
-			break;
-
-		case SO_RCVTIMEO:
-			lv=sizeof(struct timeval);
-			if (sk->sk_rcvtimeo == MAX_SCHEDULE_TIMEOUT) {
-				v.tm.tv_sec = 0;
-				v.tm.tv_usec = 0;
-			} else {
-				v.tm.tv_sec = sk->sk_rcvtimeo / HZ;
-				v.tm.tv_usec = ((sk->sk_rcvtimeo % HZ) * 1000000) / HZ;
-			}
-			break;
-
-		case SO_SNDTIMEO:
-			lv=sizeof(struct timeval);
-			if (sk->sk_sndtimeo == MAX_SCHEDULE_TIMEOUT) {
-				v.tm.tv_sec = 0;
-				v.tm.tv_usec = 0;
-			} else {
-				v.tm.tv_sec = sk->sk_sndtimeo / HZ;
-				v.tm.tv_usec = ((sk->sk_sndtimeo % HZ) * 1000000) / HZ;
-			}
-			break;
-
-		case SO_RCVLOWAT:
-			v.val = sk->sk_rcvlowat;
-			break;
+	switch(optname) {
+	case SO_DEBUG:
+		v.val = sock_flag(sk, SOCK_DBG);
+		break;
+
+	case SO_DONTROUTE:
+		v.val = sock_flag(sk, SOCK_LOCALROUTE);
+		break;
+
+	case SO_BROADCAST:
+		v.val = !!sock_flag(sk, SOCK_BROADCAST);
+		break;
+
+	case SO_SNDBUF:
+		v.val = sk->sk_sndbuf;
+		break;
+
+	case SO_RCVBUF:
+		v.val = sk->sk_rcvbuf;
+		break;
+
+	case SO_REUSEADDR:
+		v.val = sk->sk_reuse;
+		break;
+
+	case SO_KEEPALIVE:
+		v.val = !!sock_flag(sk, SOCK_KEEPOPEN);
+		break;
+
+	case SO_TYPE:
+		v.val = sk->sk_type;
+		break;
+
+	case SO_ERROR:
+		v.val = -sock_error(sk);
+		if (v.val==0)
+			v.val = xchg(&sk->sk_err_soft, 0);
+		break;
+
+	case SO_OOBINLINE:
+		v.val = !!sock_flag(sk, SOCK_URGINLINE);
+		break;
+
+	case SO_NO_CHECK:
+		v.val = sk->sk_no_check;
+		break;
+
+	case SO_PRIORITY:
+		v.val = sk->sk_priority;
+		break;
+
+	case SO_LINGER:
+		lv		= sizeof(v.ling);
+		v.ling.l_onoff	= !!sock_flag(sk, SOCK_LINGER);
+		v.ling.l_linger	= sk->sk_lingertime / HZ;
+		break;
+
+	case SO_BSDCOMPAT:
+		sock_warn_obsolete_bsdism("getsockopt");
+		break;
+
+	case SO_TIMESTAMP:
+		v.val = sock_flag(sk, SOCK_RCVTSTAMP);
+		break;
+
+	case SO_RCVTIMEO:
+		lv=sizeof(struct timeval);
+		if (sk->sk_rcvtimeo == MAX_SCHEDULE_TIMEOUT) {
+			v.tm.tv_sec = 0;
+			v.tm.tv_usec = 0;
+		} else {
+			v.tm.tv_sec = sk->sk_rcvtimeo / HZ;
+			v.tm.tv_usec = ((sk->sk_rcvtimeo % HZ) * 1000000) / HZ;
+		}
+		break;
 
-		case SO_SNDLOWAT:
-			v.val=1;
-			break;
+	case SO_SNDTIMEO:
+		lv=sizeof(struct timeval);
+		if (sk->sk_sndtimeo == MAX_SCHEDULE_TIMEOUT) {
+			v.tm.tv_sec = 0;
+			v.tm.tv_usec = 0;
+		} else {
+			v.tm.tv_sec = sk->sk_sndtimeo / HZ;
+			v.tm.tv_usec = ((sk->sk_sndtimeo % HZ) * 1000000) / HZ;
+		}
+		break;
 
-		case SO_PASSCRED:
-			v.val = test_bit(SOCK_PASSCRED, &sock->flags) ? 1 : 0;
-			break;
+	case SO_RCVLOWAT:
+		v.val = sk->sk_rcvlowat;
+		break;
+
+	case SO_SNDLOWAT:
+		v.val=1;
+		break;
+
+	case SO_PASSCRED:
+		v.val = test_bit(SOCK_PASSCRED, &sock->flags) ? 1 : 0;
+		break;
+
+	case SO_PEERCRED:
+		if (len > sizeof(sk->sk_peercred))
+			len = sizeof(sk->sk_peercred);
+		if (copy_to_user(optval, &sk->sk_peercred, len))
+			return -EFAULT;
+		goto lenout;
 
-		case SO_PEERCRED:
-			if (len > sizeof(sk->sk_peercred))
-				len = sizeof(sk->sk_peercred);
-			if (copy_to_user(optval, &sk->sk_peercred, len))
-				return -EFAULT;
-			goto lenout;
-
-		case SO_PEERNAME:
-		{
-			char address[128];
-
-			if (sock->ops->getname(sock, (struct sockaddr *)address, &lv, 2))
-				return -ENOTCONN;
-			if (lv < len)
-				return -EINVAL;
-			if (copy_to_user(optval, address, len))
-				return -EFAULT;
-			goto lenout;
-		}
+	case SO_PEERNAME:
+	{
+		char address[128];
 
-		/* Dubious BSD thing... Probably nobody even uses it, but
-		 * the UNIX standard wants it for whatever reason... -DaveM
-		 */
-		case SO_ACCEPTCONN:
-			v.val = sk->sk_state == TCP_LISTEN;
-			break;
+		if (sock->ops->getname(sock, (struct sockaddr *)address, &lv, 2))
+			return -ENOTCONN;
+		if (lv < len)
+			return -EINVAL;
+		if (copy_to_user(optval, address, len))
+			return -EFAULT;
+		goto lenout;
+	}
 
-		case SO_PASSSEC:
-			v.val = test_bit(SOCK_PASSSEC, &sock->flags) ? 1 : 0;
-			break;
+	/* Dubious BSD thing... Probably nobody even uses it, but
+	 * the UNIX standard wants it for whatever reason... -DaveM
+	 */
+	case SO_ACCEPTCONN:
+		v.val = sk->sk_state == TCP_LISTEN;
+		break;
+
+	case SO_PASSSEC:
+		v.val = test_bit(SOCK_PASSSEC, &sock->flags) ? 1 : 0;
+		break;
 
-		case SO_PEERSEC:
-			return security_socket_getpeersec_stream(sock, optval, optlen, len);
+	case SO_PEERSEC:
+		return security_socket_getpeersec_stream(sock, optval, optlen, len);
 
-		default:
-			return(-ENOPROTOOPT);
+	default:
+		return -ENOPROTOOPT;
 	}
+
 	if (len > lv)
 		len = lv;
 	if (copy_to_user(optval, &v, len))
@@ -1220,13 +1217,13 @@
 {
 	DEFINE_WAIT(wait);
 
-	for(;;) {
+	for (;;) {
 		prepare_to_wait_exclusive(&sk->sk_lock.wq, &wait,
 					TASK_UNINTERRUPTIBLE);
 		spin_unlock_bh(&sk->sk_lock.slock);
 		schedule();
 		spin_lock_bh(&sk->sk_lock.slock);
-		if(!sock_owned_by_user(sk))
+		if (!sock_owned_by_user(sk))
 			break;
 	}
 	finish_wait(&sk->sk_lock.wq, &wait);
@@ -1258,7 +1255,7 @@
 		} while (skb != NULL);
 
 		bh_lock_sock(sk);
-	} while((skb = sk->sk_backlog.head) != NULL);
+	} while ((skb = sk->sk_backlog.head) != NULL);
 }
 
 /**
@@ -1420,7 +1417,7 @@
 	/* Do not wake up a writer until he can make "significant"
 	 * progress.  --DaveM
 	 */
-	if((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
+	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
 		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
 			wake_up_interruptible(sk->sk_sleep);
 
@@ -1482,8 +1479,7 @@
 
 	sock_set_flag(sk, SOCK_ZAPPED);
 
-	if(sock)
-	{
+	if (sock) {
 		sk->sk_type	=	sock->type;
 		sk->sk_sleep	=	&sock->wait;
 		sock->sk	=	sk;
--- net-2.6.22.orig/net/socket.c	2007-03-08 12:48:49.000000000 -0800
+++ net-2.6.22/net/socket.c	2007-03-08 12:48:52.000000000 -0800
@@ -1292,7 +1292,7 @@
 	int err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if(sock) {
+	if (sock) {
 		err = move_addr_to_kernel(umyaddr, addrlen, address);
 		if (err >= 0) {
 			err = security_socket_bind(sock,
--- net-2.6.22.orig/net/core/ethtool.c	2007-03-08 12:48:49.000000000 -0800
+++ net-2.6.22/net/core/ethtool.c	2007-03-08 12:48:52.000000000 -0800
@@ -836,7 +836,7 @@
 			return -EPERM;
 	}
 
-	if(dev->ethtool_ops->begin)
+	if (dev->ethtool_ops->begin)
 		if ((rc = dev->ethtool_ops->begin(dev)) < 0)
 			return rc;
 
@@ -952,7 +952,7 @@
 		rc =  -EOPNOTSUPP;
 	}
 
-	if(dev->ethtool_ops->complete)
+	if (dev->ethtool_ops->complete)
 		dev->ethtool_ops->complete(dev);
 
 	if (old_features != dev->features)
--- net-2.6.22.orig/net/core/net-sysfs.c	2007-03-08 12:48:49.000000000 -0800
+++ net-2.6.22/net/core/net-sysfs.c	2007-03-08 12:48:52.000000000 -0800
@@ -352,8 +352,8 @@
 
 	read_lock(&dev_base_lock);
 	if (dev_isalive(dev)) {
-		if(dev->wireless_handlers &&
-		   dev->wireless_handlers->get_wireless_stats)
+		if (dev->wireless_handlers &&
+		    dev->wireless_handlers->get_wireless_stats)
 			iw = dev->wireless_handlers->get_wireless_stats(dev);
 		if (iw != NULL)
 			ret = (*format)(iw, buf);
--- net-2.6.22.orig/net/core/wireless.c	2007-03-08 12:48:49.000000000 -0800
+++ net-2.6.22/net/core/wireless.c	2007-03-08 12:49:54.000000000 -0800
@@ -445,17 +445,17 @@
 	unsigned int	index;		/* *MUST* be unsigned */
 
 	/* Check if we have some wireless handlers defined */
-	if(dev->wireless_handlers == NULL)
+	if (dev->wireless_handlers == NULL)
 		return NULL;
 
 	/* Try as a standard command */
 	index = cmd - SIOCIWFIRST;
-	if(index < dev->wireless_handlers->num_standard)
+	if (index < dev->wireless_handlers->num_standard)
 		return dev->wireless_handlers->standard[index];
 
 	/* Try as a private command */
 	index = cmd - SIOCIWFIRSTPRIV;
-	if(index < dev->wireless_handlers->num_private)
+	if (index < dev->wireless_handlers->num_private)
 		return dev->wireless_handlers->private[index];
 
 	/* Not found */
@@ -469,7 +469,7 @@
 static inline struct iw_statistics *get_wireless_stats(struct net_device *dev)
 {
 	/* New location */
-	if((dev->wireless_handlers != NULL) &&
+	if ((dev->wireless_handlers != NULL) &&
 	   (dev->wireless_handlers->get_wireless_stats != NULL))
 		return dev->wireless_handlers->get_wireless_stats(dev);
 
@@ -498,7 +498,7 @@
  */
 static inline int call_commit_handler(struct net_device *	dev)
 {
-	if((netif_running(dev)) &&
+	if ((netif_running(dev)) &&
 	   (dev->wireless_handlers->standard[0] != NULL)) {
 		/* Call the commit handler on the driver */
 		return dev->wireless_handlers->standard[0](dev, NULL,
@@ -559,7 +559,7 @@
 		wrqu->data.length = sizeof(struct iw_statistics);
 
 		/* Check if we need to clear the updated flag */
-		if(wrqu->data.flags != 0)
+		if (wrqu->data.flags != 0)
 			stats->qual.updated &= ~IW_QUAL_ALL_UPDATED;
 		return 0;
 	} else
@@ -578,12 +578,12 @@
 				  char *			extra)
 {
 	/* Check if the driver has something to export */
-	if((dev->wireless_handlers->num_private_args == 0) ||
+	if ((dev->wireless_handlers->num_private_args == 0) ||
 	   (dev->wireless_handlers->private_args == NULL))
 		return -EOPNOTSUPP;
 
 	/* Check if there is enough buffer up there */
-	if(wrqu->data.length < dev->wireless_handlers->num_private_args) {
+	if (wrqu->data.length < dev->wireless_handlers->num_private_args) {
 		/* User space can't know in advance how large the buffer
 		 * needs to be. Give it a hint, so that we can support
 		 * any size buffer we want somewhat efficiently... */
@@ -717,7 +717,7 @@
 	int					ret = -EINVAL;
 
 	/* Get the description of the IOCTL */
-	if((cmd - SIOCIWFIRST) >= standard_ioctl_num)
+	if ((cmd - SIOCIWFIRST) >= standard_ioctl_num)
 		return -EOPNOTSUPP;
 	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
 
@@ -732,14 +732,14 @@
 	info.flags = 0;
 
 	/* Check if we have a pointer to user space data or not */
-	if(descr->header_type != IW_HEADER_TYPE_POINT) {
+	if (descr->header_type != IW_HEADER_TYPE_POINT) {
 
 		/* No extra arguments. Trivial to handle */
 		ret = handler(dev, &info, &(iwr->u), NULL);
 
 #ifdef WE_SET_EVENT
 		/* Generate an event to notify listeners of the change */
-		if((descr->flags & IW_DESCR_FLAG_EVENT) &&
+		if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
 		   ((ret == 0) || (ret == -EIWCOMMIT)))
 			wireless_send_event(dev, cmd, &(iwr->u), NULL);
 #endif	/* WE_SET_EVENT */
@@ -782,19 +782,19 @@
 		iwr->u.data.length -= essid_compat;
 
 		/* Check what user space is giving us */
-		if(IW_IS_SET(cmd)) {
+		if (IW_IS_SET(cmd)) {
 			/* Check NULL pointer */
-			if((iwr->u.data.pointer == NULL) &&
+			if ((iwr->u.data.pointer == NULL) &&
 			   (iwr->u.data.length != 0))
 				return -EFAULT;
 			/* Check if number of token fits within bounds */
-			if(iwr->u.data.length > descr->max_tokens)
+			if (iwr->u.data.length > descr->max_tokens)
 				return -E2BIG;
-			if(iwr->u.data.length < descr->min_tokens)
+			if (iwr->u.data.length < descr->min_tokens)
 				return -EINVAL;
 		} else {
 			/* Check NULL pointer */
-			if(iwr->u.data.pointer == NULL)
+			if (iwr->u.data.pointer == NULL)
 				return -EFAULT;
 			/* Save user space buffer size for checking */
 			user_length = iwr->u.data.length;
@@ -804,7 +804,7 @@
 			 * implied by the test at the end. */
 
 			/* Support for very large requests */
-			if((descr->flags & IW_DESCR_FLAG_NOMAX) &&
+			if ((descr->flags & IW_DESCR_FLAG_NOMAX) &&
 			   (user_length > descr->max_tokens)) {
 				/* Allow userspace to GET more than max so
 				 * we can support any size GET requests.
@@ -830,7 +830,7 @@
 		}
 
 		/* If it is a SET, get all the extra data in here */
-		if(IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
+		if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
 			err = copy_from_user(extra, iwr->u.data.pointer,
 					     iwr->u.data.length *
 					     descr->token_size);
@@ -853,7 +853,7 @@
 		/* If we have something to return to the user */
 		if (!ret && IW_IS_GET(cmd)) {
 			/* Check if there is enough buffer up there */
-			if(user_length < iwr->u.data.length) {
+			if (user_length < iwr->u.data.length) {
 				kfree(extra);
 				return -E2BIG;
 			}
@@ -872,9 +872,9 @@
 
 #ifdef WE_SET_EVENT
 		/* Generate an event to notify listeners of the change */
-		if((descr->flags & IW_DESCR_FLAG_EVENT) &&
+		if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
 		   ((ret == 0) || (ret == -EIWCOMMIT))) {
-			if(descr->flags & IW_DESCR_FLAG_RESTRICT)
+			if (descr->flags & IW_DESCR_FLAG_RESTRICT)
 				/* If the event is restricted, don't
 				 * export the payload */
 				wireless_send_event(dev, cmd, &(iwr->u), NULL);
@@ -889,7 +889,7 @@
 	}
 
 	/* Call commit handler if needed and defined */
-	if(ret == -EIWCOMMIT)
+	if (ret == -EIWCOMMIT)
 		ret = call_commit_handler(dev);
 
 	/* Here, we will generate the appropriate event if needed */
@@ -926,8 +926,8 @@
 	int				ret = -EINVAL;
 
 	/* Get the description of the IOCTL */
-	for(i = 0; i < dev->wireless_handlers->num_private_args; i++)
-		if(cmd == dev->wireless_handlers->private_args[i].cmd) {
+	for (i = 0; i < dev->wireless_handlers->num_private_args; i++)
+		if (cmd == dev->wireless_handlers->private_args[i].cmd) {
 			descr = &(dev->wireless_handlers->private_args[i]);
 			break;
 		}
@@ -935,7 +935,7 @@
 #ifdef WE_IOCTL_DEBUG
 	printk(KERN_DEBUG "%s (WE) : Found private handler for 0x%04X\n",
 	       ifr->ifr_name, cmd);
-	if(descr) {
+	if (descr) {
 		printk(KERN_DEBUG "%s (WE) : Name %s, set %X, get %X\n",
 		       dev->name, descr->name,
 		       descr->set_args, descr->get_args);
@@ -943,11 +943,11 @@
 #endif	/* WE_IOCTL_DEBUG */
 
 	/* Compute the size of the set/get arguments */
-	if(descr != NULL) {
-		if(IW_IS_SET(cmd)) {
+	if (descr != NULL) {
+		if (IW_IS_SET(cmd)) {
 			int	offset = 0;	/* For sub-ioctls */
 			/* Check for sub-ioctl handler */
-			if(descr->name[0] == '\0')
+			if (descr->name[0] == '\0')
 				/* Reserve one int for sub-ioctl index */
 				offset = sizeof(__u32);
 
@@ -955,7 +955,7 @@
 			extra_size = get_priv_size(descr->set_args);
 
 			/* Does it fits in iwr ? */
-			if((descr->set_args & IW_PRIV_SIZE_FIXED) &&
+			if ((descr->set_args & IW_PRIV_SIZE_FIXED) &&
 			   ((extra_size + offset) <= IFNAMSIZ))
 				extra_size = 0;
 		} else {
@@ -963,7 +963,7 @@
 			extra_size = get_priv_size(descr->get_args);
 
 			/* Does it fits in iwr ? */
-			if((descr->get_args & IW_PRIV_SIZE_FIXED) &&
+			if ((descr->get_args & IW_PRIV_SIZE_FIXED) &&
 			   (extra_size <= IFNAMSIZ))
 				extra_size = 0;
 		}
@@ -974,7 +974,7 @@
 	info.flags = 0;
 
 	/* Check if we have a pointer to user space data or not. */
-	if(extra_size == 0) {
+	if (extra_size == 0) {
 		/* No extra arguments. Trivial to handle */
 		ret = handler(dev, &info, &(iwr->u), (char *) &(iwr->u));
 	} else {
@@ -982,19 +982,19 @@
 		int	err;
 
 		/* Check what user space is giving us */
-		if(IW_IS_SET(cmd)) {
+		if (IW_IS_SET(cmd)) {
 			/* Check NULL pointer */
-			if((iwr->u.data.pointer == NULL) &&
+			if ((iwr->u.data.pointer == NULL) &&
 			   (iwr->u.data.length != 0))
 				return -EFAULT;
 
 			/* Does it fits within bounds ? */
-			if(iwr->u.data.length > (descr->set_args &
+			if (iwr->u.data.length > (descr->set_args &
 						 IW_PRIV_SIZE_MASK))
 				return -E2BIG;
 		} else {
 			/* Check NULL pointer */
-			if(iwr->u.data.pointer == NULL)
+			if (iwr->u.data.pointer == NULL)
 				return -EFAULT;
 		}
 
@@ -1011,7 +1011,7 @@
 		}
 
 		/* If it is a SET, get all the extra data in here */
-		if(IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
+		if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
 			err = copy_from_user(extra, iwr->u.data.pointer,
 					     extra_size);
 			if (err) {
@@ -1053,7 +1053,7 @@
 
 
 	/* Call commit handler if needed and defined */
-	if(ret == -EIWCOMMIT)
+	if (ret == -EIWCOMMIT)
 		ret = call_commit_handler(dev);
 
 	return ret;
@@ -1080,51 +1080,50 @@
 	/* A bunch of special cases, then the generic case...
 	 * Note that 'cmd' is already filtered in dev_ioctl() with
 	 * (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST) */
-	switch(cmd)
-	{
-		case SIOCGIWSTATS:
-			/* Get Wireless Stats */
+	switch (cmd) {
+	case SIOCGIWSTATS:
+		/* Get Wireless Stats */
+		return ioctl_standard_call(dev,
+					   ifr,
+					   cmd,
+					   &iw_handler_get_iwstats);
+
+	case SIOCGIWPRIV:
+		/* Check if we have some wireless handlers defined */
+		if (dev->wireless_handlers != NULL) {
+			/* We export to user space the definition of
+			 * the private handler ourselves */
 			return ioctl_standard_call(dev,
 						   ifr,
 						   cmd,
-						   &iw_handler_get_iwstats);
-
-		case SIOCGIWPRIV:
-			/* Check if we have some wireless handlers defined */
-			if(dev->wireless_handlers != NULL) {
-				/* We export to user space the definition of
-				 * the private handler ourselves */
+						   &iw_handler_get_private);
+		}
+		// ## Fall-through for old API ##
+	default:
+		/* Generic IOCTL */
+		/* Basic check */
+		if (!netif_device_present(dev))
+			return -ENODEV;
+		/* New driver API : try to find the handler */
+		handler = get_handler(dev, cmd);
+		if (handler != NULL) {
+			/* Standard and private are not the same */
+			if (cmd < SIOCIWFIRSTPRIV)
 				return ioctl_standard_call(dev,
 							   ifr,
 							   cmd,
-							   &iw_handler_get_private);
-			}
-			// ## Fall-through for old API ##
-		default:
-			/* Generic IOCTL */
-			/* Basic check */
-			if (!netif_device_present(dev))
-				return -ENODEV;
-			/* New driver API : try to find the handler */
-			handler = get_handler(dev, cmd);
-			if(handler != NULL) {
-				/* Standard and private are not the same */
-				if(cmd < SIOCIWFIRSTPRIV)
-					return ioctl_standard_call(dev,
-								   ifr,
-								   cmd,
-								   handler);
-				else
-					return ioctl_private_call(dev,
-								  ifr,
-								  cmd,
-								  handler);
-			}
-			/* Old driver API : call driver ioctl handler */
-			if (dev->do_ioctl) {
-				return dev->do_ioctl(dev, ifr, cmd);
-			}
-			return -EOPNOTSUPP;
+							   handler);
+			else
+				return ioctl_private_call(dev,
+							  ifr,
+							  cmd,
+							  handler);
+		}
+		/* Old driver API : call driver ioctl handler */
+		if (dev->do_ioctl) {
+			return dev->do_ioctl(dev, ifr, cmd);
+		}
+		return -EOPNOTSUPP;
 	}
 	/* Not reached */
 	return -EINVAL;
@@ -1178,7 +1177,7 @@
 
 	/* Get the description of the Request */
 	cmd = request->cmd;
-	if((cmd - SIOCIWFIRST) >= standard_ioctl_num)
+	if ((cmd - SIOCIWFIRST) >= standard_ioctl_num)
 		return -EOPNOTSUPP;
 	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
 
@@ -1190,7 +1189,7 @@
 
 	/* Check if wrqu is complete */
 	hdr_len = event_type_size[descr->header_type];
-	if(request_len < hdr_len) {
+	if (request_len < hdr_len) {
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG
 		       "%s (WE.r) : Wireless request too short (%d)\n",
@@ -1204,7 +1203,7 @@
 	info.flags = 0;
 
 	/* Check if we have extra data in the reply or not */
-	if(descr->header_type != IW_HEADER_TYPE_POINT) {
+	if (descr->header_type != IW_HEADER_TYPE_POINT) {
 
 		/* Create the kernel buffer that we will return.
 		 * It's at an offset to match the TYPE_POINT case... */
@@ -1236,7 +1235,7 @@
 		 * for max space. Easier, and won't last long... */
 		extra_size = descr->max_tokens * descr->token_size;
 		/* Support for very large requests */
-		if((descr->flags & IW_DESCR_FLAG_NOMAX) &&
+		if ((descr->flags & IW_DESCR_FLAG_NOMAX) &&
 		   (wrqu_point.data.length > descr->max_tokens))
 			extra_size = (wrqu_point.data.length
 				      * descr->token_size);
@@ -1281,7 +1280,7 @@
 #endif	/* WE_RTNETLINK_DEBUG */
 
 		/* Check if there is enough buffer up there */
-		if(wrqu_point.data.length < wrqu->data.length)
+		if (wrqu_point.data.length < wrqu->data.length)
 			ret = -E2BIG;
 	}
 
@@ -1291,7 +1290,7 @@
 		*p_len = request->len;
 	} else {
 		/* Cleanup */
-		if(buffer)
+		if (buffer)
 			kfree(buffer);
 	}
 
@@ -1320,7 +1319,7 @@
 
 	/* Get the description of the Request */
 	cmd = request->cmd;
-	if((cmd - SIOCIWFIRST) >= standard_ioctl_num)
+	if ((cmd - SIOCIWFIRST) >= standard_ioctl_num)
 		return -EOPNOTSUPP;
 	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
 
@@ -1335,7 +1334,7 @@
 
 	/* Check if wrqu is complete */
 	hdr_len = event_type_size[descr->header_type];
-	if(request_len < hdr_len) {
+	if (request_len < hdr_len) {
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG
 		       "%s (WE.r) : Wireless request too short (%d)\n",
@@ -1349,7 +1348,7 @@
 	info.flags = 0;
 
 	/* Check if we have extra data in the request or not */
-	if(descr->header_type != IW_HEADER_TYPE_POINT) {
+	if (descr->header_type != IW_HEADER_TYPE_POINT) {
 
 		/* No extra arguments. Trivial to handle */
 		ret = handler(dev, &info, wrqu, NULL);
@@ -1364,16 +1363,16 @@
 		wrqu = &wrqu_point;
 
 		/* Check if number of token fits within bounds */
-		if(wrqu_point.data.length > descr->max_tokens)
+		if (wrqu_point.data.length > descr->max_tokens)
 			return -E2BIG;
-		if(wrqu_point.data.length < descr->min_tokens)
+		if (wrqu_point.data.length < descr->min_tokens)
 			return -EINVAL;
 
 		/* Real length of payload */
 		extra_len = wrqu_point.data.length * descr->token_size;
 
 		/* Check if request is self consistent */
-		if((request_len - hdr_len) < extra_len) {
+		if ((request_len - hdr_len) < extra_len) {
 #ifdef WE_RTNETLINK_DEBUG
 			printk(KERN_DEBUG "%s (WE.r) : Wireless request data too short (%d)\n",
 			       dev->name, extra_size);
@@ -1402,9 +1401,9 @@
 
 #ifdef WE_SET_EVENT
 	/* Generate an event to notify listeners of the change */
-	if((descr->flags & IW_DESCR_FLAG_EVENT) &&
+	if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
 	   ((ret == 0) || (ret == -EIWCOMMIT))) {
-		if(descr->flags & IW_DESCR_FLAG_RESTRICT)
+		if (descr->flags & IW_DESCR_FLAG_RESTRICT)
 			/* If the event is restricted, don't
 			 * export the payload */
 			wireless_send_event(dev, cmd, wrqu, NULL);
@@ -1414,11 +1413,11 @@
 #endif	/* WE_SET_EVENT */
 
 	/* Cleanup - I told you it wasn't that long ;-) */
-	if(extra)
+	if (extra)
 		kfree(extra);
 
 	/* Call commit handler if needed and defined */
-	if(ret == -EIWCOMMIT)
+	if (ret == -EIWCOMMIT)
 		ret = call_commit_handler(dev);
 
 	return ret;
@@ -1459,12 +1458,12 @@
 
 	/* Get the description of the Request */
 	cmd = request->cmd;
-	for(i = 0; i < dev->wireless_handlers->num_private_args; i++)
-		if(cmd == dev->wireless_handlers->private_args[i].cmd) {
+	for (i = 0; i < dev->wireless_handlers->num_private_args; i++)
+		if (cmd == dev->wireless_handlers->private_args[i].cmd) {
 			descr = &(dev->wireless_handlers->private_args[i]);
 			break;
 		}
-	if(descr == NULL)
+	if (descr == NULL)
 		return -EOPNOTSUPP;
 
 #ifdef WE_RTNETLINK_DEBUG
@@ -1478,7 +1477,7 @@
 	extra_size = get_priv_size(descr->get_args);
 
 	/* Does it fits in wrqu ? */
-	if((descr->get_args & IW_PRIV_SIZE_FIXED) &&
+	if ((descr->get_args & IW_PRIV_SIZE_FIXED) &&
 	   (extra_size <= IFNAMSIZ)) {
 		hdr_len = extra_size;
 		extra_size = 0;
@@ -1487,7 +1486,7 @@
 	}
 
 	/* Check if wrqu is complete */
-	if(request_len < hdr_len) {
+	if (request_len < hdr_len) {
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG
 		       "%s (WE.r) : Wireless request too short (%d)\n",
@@ -1501,7 +1500,7 @@
 	info.flags = 0;
 
 	/* Check if we have a pointer to user space data or not. */
-	if(extra_size == 0) {
+	if (extra_size == 0) {
 
 		/* Create the kernel buffer that we will return.
 		 * It's at an offset to match the TYPE_POINT case... */
@@ -1573,7 +1572,7 @@
 		*p_len = request->len;
 	} else {
 		/* Cleanup */
-		if(buffer)
+		if (buffer)
 			kfree(buffer);
 	}
 
@@ -1614,12 +1613,12 @@
 
 	/* Get the description of the Request */
 	cmd = request->cmd;
-	for(i = 0; i < dev->wireless_handlers->num_private_args; i++)
-		if(cmd == dev->wireless_handlers->private_args[i].cmd) {
+	for (i = 0; i < dev->wireless_handlers->num_private_args; i++)
+		if (cmd == dev->wireless_handlers->private_args[i].cmd) {
 			descr = &(dev->wireless_handlers->private_args[i]);
 			break;
 		}
-	if(descr == NULL)
+	if (descr == NULL)
 		return -EOPNOTSUPP;
 
 #ifdef WE_RTNETLINK_DEBUG
@@ -1631,7 +1630,7 @@
 
 	/* Compute the size of the set arguments */
 	/* Check for sub-ioctl handler */
-	if(descr->name[0] == '\0')
+	if (descr->name[0] == '\0')
 		/* Reserve one int for sub-ioctl index */
 		offset = sizeof(__u32);
 
@@ -1639,7 +1638,7 @@
 	extra_size = get_priv_size(descr->set_args);
 
 	/* Does it fits in wrqu ? */
-	if((descr->set_args & IW_PRIV_SIZE_FIXED) &&
+	if ((descr->set_args & IW_PRIV_SIZE_FIXED) &&
 	   (extra_size <= IFNAMSIZ)) {
 		hdr_len = IW_EV_LCP_LEN + extra_size;
 		extra_size = 0;
@@ -1651,7 +1650,7 @@
 	wrqu = &request->u;
 
 	/* Check if wrqu is complete */
-	if(request_len < hdr_len) {
+	if (request_len < hdr_len) {
 #ifdef WE_RTNETLINK_DEBUG
 		printk(KERN_DEBUG
 		       "%s (WE.r) : Wireless request too short (%d)\n",
@@ -1665,7 +1664,7 @@
 	info.flags = 0;
 
 	/* Check if we have a pointer to user space data or not. */
-	if(extra_size == 0) {
+	if (extra_size == 0) {
 
 		/* No extra arguments. Trivial to handle */
 		ret = handler(dev, &info, wrqu, (char *) wrqu);
@@ -1678,7 +1677,7 @@
 		       wrqu, IW_EV_POINT_LEN - IW_EV_LCP_LEN);
 
 		/* Does it fits within bounds ? */
-		if(wrqu_point.data.length > (descr->set_args &
+		if (wrqu_point.data.length > (descr->set_args &
 					     IW_PRIV_SIZE_MASK))
 			return -E2BIG;
 
@@ -1686,7 +1685,7 @@
 		extra_len = adjust_priv_size(descr->set_args, &wrqu_point);
 
 		/* Check if request is self consistent */
-		if((request_len - hdr_len) < extra_len) {
+		if ((request_len - hdr_len) < extra_len) {
 #ifdef WE_RTNETLINK_DEBUG
 			printk(KERN_DEBUG "%s (WE.r) : Wireless request data too short (%d)\n",
 			       dev->name, extra_size);
@@ -1716,7 +1715,7 @@
 	}
 
 	/* Call commit handler if needed and defined */
-	if(ret == -EIWCOMMIT)
+	if (ret == -EIWCOMMIT)
 		ret = call_commit_handler(dev);
 
 	return ret;
@@ -1738,21 +1737,21 @@
 	iw_handler		handler;
 
 	/* Check length */
-	if(len < IW_EV_LCP_LEN) {
+	if (len < IW_EV_LCP_LEN) {
 		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request too short (%d)\n",
 		       dev->name, len);
 		return -EINVAL;
 	}
 
 	/* ReCheck length (len may have padding) */
-	if(request->len > len) {
+	if (request->len > len) {
 		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request len invalid (%d-%d)\n",
 		       dev->name, request->len, len);
 		return -EINVAL;
 	}
 
 	/* Only accept GET requests in here */
-	if(!IW_IS_GET(request->cmd))
+	if (!IW_IS_GET(request->cmd))
 		return -EOPNOTSUPP;
 
 	/* If command is `get the encoding parameters', check if
@@ -1764,16 +1763,16 @@
 	}
 
 	/* Special cases */
-	if(request->cmd == SIOCGIWSTATS)
+	if (request->cmd == SIOCGIWSTATS)
 		/* Get Wireless Stats */
 		return rtnetlink_standard_get(dev,
 					      request,
 					      request->len,
 					      &iw_handler_get_iwstats,
 					      p_buf, p_len);
-	if(request->cmd == SIOCGIWPRIV) {
+	if (request->cmd == SIOCGIWPRIV) {
 		/* Check if we have some wireless handlers defined */
-		if(dev->wireless_handlers == NULL)
+		if (dev->wireless_handlers == NULL)
 			return -EOPNOTSUPP;
 		/* Get Wireless Stats */
 		return rtnetlink_standard_get(dev,
@@ -1789,9 +1788,9 @@
 
 	/* Try to find the handler */
 	handler = get_handler(dev, request->cmd);
-	if(handler != NULL) {
+	if (handler != NULL) {
 		/* Standard and private are not the same */
-		if(request->cmd < SIOCIWFIRSTPRIV)
+		if (request->cmd < SIOCIWFIRSTPRIV)
 			return rtnetlink_standard_get(dev,
 						      request,
 						      request->len,
@@ -1822,21 +1821,21 @@
 	iw_handler		handler;
 
 	/* Check length */
-	if(len < IW_EV_LCP_LEN) {
+	if (len < IW_EV_LCP_LEN) {
 		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request too short (%d)\n",
 		       dev->name, len);
 		return -EINVAL;
 	}
 
 	/* ReCheck length (len may have padding) */
-	if(request->len > len) {
+	if (request->len > len) {
 		printk(KERN_DEBUG "%s (WE.r) : RtNetlink request len invalid (%d-%d)\n",
 		       dev->name, request->len, len);
 		return -EINVAL;
 	}
 
 	/* Only accept SET requests in here */
-	if(!IW_IS_SET(request->cmd))
+	if (!IW_IS_SET(request->cmd))
 		return -EOPNOTSUPP;
 
 	/* Basic check */
@@ -1845,9 +1844,9 @@
 
 	/* New driver API : try to find the handler */
 	handler = get_handler(dev, request->cmd);
-	if(handler != NULL) {
+	if (handler != NULL) {
 		/* Standard and private are not the same */
-		if(request->cmd < SIOCIWFIRSTPRIV)
+		if (request->cmd < SIOCIWFIRSTPRIV)
 			return rtnetlink_standard_set(dev,
 						      request,
 						      request->len,
@@ -1997,17 +1996,17 @@
 	unsigned	cmd_index;		/* *MUST* be unsigned */
 
 	/* Get the description of the Event */
-	if(cmd <= SIOCIWLAST) {
+	if (cmd <= SIOCIWLAST) {
 		cmd_index = cmd - SIOCIWFIRST;
-		if(cmd_index < standard_ioctl_num)
+		if (cmd_index < standard_ioctl_num)
 			descr = &(standard_ioctl[cmd_index]);
 	} else {
 		cmd_index = cmd - IWEVFIRST;
-		if(cmd_index < standard_event_num)
+		if (cmd_index < standard_event_num)
 			descr = &(standard_event[cmd_index]);
 	}
 	/* Don't accept unknown events */
-	if(descr == NULL) {
+	if (descr == NULL) {
 		/* Note : we don't return an error to the driver, because
 		 * the driver would not know what to do about it. It can't
 		 * return an error to the user, because the event is not
@@ -2026,18 +2025,18 @@
 #endif	/* WE_EVENT_DEBUG */
 
 	/* Check extra parameters and set extra_len */
-	if(descr->header_type == IW_HEADER_TYPE_POINT) {
+	if (descr->header_type == IW_HEADER_TYPE_POINT) {
 		/* Check if number of token fits within bounds */
-		if(wrqu->data.length > descr->max_tokens) {
+		if (wrqu->data.length > descr->max_tokens) {
 			printk(KERN_ERR "%s (WE) : Wireless Event too big (%d)\n", dev->name, wrqu->data.length);
 			return;
 		}
-		if(wrqu->data.length < descr->min_tokens) {
+		if (wrqu->data.length < descr->min_tokens) {
 			printk(KERN_ERR "%s (WE) : Wireless Event too small (%d)\n", dev->name, wrqu->data.length);
 			return;
 		}
 		/* Calculate extra_len - extra is NULL for restricted events */
-		if(extra != NULL)
+		if (extra != NULL)
 			extra_len = wrqu->data.length * descr->token_size;
 		/* Always at an offset in wrqu */
 		wrqu_off = IW_EV_POINT_OFF;
@@ -2056,14 +2055,14 @@
 
 	/* Create temporary buffer to hold the event */
 	event = kmalloc(event_len, GFP_ATOMIC);
-	if(event == NULL)
+	if (event == NULL)
 		return;
 
 	/* Fill event */
 	event->len = event_len;
 	event->cmd = cmd;
 	memcpy(&event->u, ((char *) wrqu) + wrqu_off, hdr_len - IW_EV_LCP_LEN);
-	if(extra != NULL)
+	if (extra != NULL)
 		memcpy(((char *) event) + hdr_len, extra, extra_len);
 
 #ifdef WE_EVENT_RTNETLINK
@@ -2098,7 +2097,7 @@
 static inline struct iw_spy_data * get_spydata(struct net_device *dev)
 {
 	/* This is the new way */
-	if(dev->wireless_data)
+	if (dev->wireless_data)
 		return(dev->wireless_data->spy_data);
 	return NULL;
 }
@@ -2116,7 +2115,7 @@
 	struct sockaddr *	address = (struct sockaddr *) extra;
 
 	/* Make sure driver is not buggy or using the old API */
-	if(!spydata)
+	if (!spydata)
 		return -EOPNOTSUPP;
 
 	/* Disable spy collection while we copy the addresses.
@@ -2133,11 +2132,11 @@
 	smp_wmb();
 
 	/* Are there are addresses to copy? */
-	if(wrqu->data.length > 0) {
+	if (wrqu->data.length > 0) {
 		int i;
 
 		/* Copy addresses */
-		for(i = 0; i < wrqu->data.length; i++)
+		for (i = 0; i < wrqu->data.length; i++)
 			memcpy(spydata->spy_address[i], address[i].sa_data,
 			       ETH_ALEN);
 		/* Reset stats */
@@ -2181,23 +2180,23 @@
 	int			i;
 
 	/* Make sure driver is not buggy or using the old API */
-	if(!spydata)
+	if (!spydata)
 		return -EOPNOTSUPP;
 
 	wrqu->data.length = spydata->spy_number;
 
 	/* Copy addresses. */
-	for(i = 0; i < spydata->spy_number; i++) 	{
+	for (i = 0; i < spydata->spy_number; i++) 	{
 		memcpy(address[i].sa_data, spydata->spy_address[i], ETH_ALEN);
 		address[i].sa_family = AF_UNIX;
 	}
 	/* Copy stats to the user buffer (just after). */
-	if(spydata->spy_number > 0)
+	if (spydata->spy_number > 0)
 		memcpy(extra  + (sizeof(struct sockaddr) *spydata->spy_number),
 		       spydata->spy_stat,
 		       sizeof(struct iw_quality) * spydata->spy_number);
 	/* Reset updated flags. */
-	for(i = 0; i < spydata->spy_number; i++)
+	for (i = 0; i < spydata->spy_number; i++)
 		spydata->spy_stat[i].updated &= ~IW_QUAL_ALL_UPDATED;
 	return 0;
 }
@@ -2215,7 +2214,7 @@
 	struct iw_thrspy *	threshold = (struct iw_thrspy *) extra;
 
 	/* Make sure driver is not buggy or using the old API */
-	if(!spydata)
+	if (!spydata)
 		return -EOPNOTSUPP;
 
 	/* Just do it */
@@ -2245,7 +2244,7 @@
 	struct iw_thrspy *	threshold = (struct iw_thrspy *) extra;
 
 	/* Make sure driver is not buggy or using the old API */
-	if(!spydata)
+	if (!spydata)
 		return -EOPNOTSUPP;
 
 	/* Just do it */
@@ -2309,7 +2308,7 @@
 	int			match = -1;
 
 	/* Make sure driver is not buggy or using the old API */
-	if(!spydata)
+	if (!spydata)
 		return;
 
 #ifdef WE_SPY_DEBUG
@@ -2317,8 +2316,8 @@
 #endif	/* WE_SPY_DEBUG */
 
 	/* Update all records that match */
-	for(i = 0; i < spydata->spy_number; i++)
-		if(!compare_ether_addr(address, spydata->spy_address[i])) {
+	for (i = 0; i < spydata->spy_number; i++)
+		if (!compare_ether_addr(address, spydata->spy_address[i])) {
 			memcpy(&(spydata->spy_stat[i]), wstats,
 			       sizeof(struct iw_quality));
 			match = i;
@@ -2328,15 +2327,15 @@
 	 * To avoid event storms, we have a simple hysteresis : we generate
 	 * event only when we go under the low threshold or above the
 	 * high threshold. */
-	if(match >= 0) {
-		if(spydata->spy_thr_under[match]) {
-			if(wstats->level > spydata->spy_thr_high.level) {
+	if (match >= 0) {
+		if (spydata->spy_thr_under[match]) {
+			if (wstats->level > spydata->spy_thr_high.level) {
 				spydata->spy_thr_under[match] = 0;
 				iw_send_thrspy_event(dev, spydata,
 						     address, wstats);
 			}
 		} else {
-			if(wstats->level < spydata->spy_thr_low.level) {
+			if (wstats->level < spydata->spy_thr_low.level) {
 				spydata->spy_thr_under[match] = 1;
 				iw_send_thrspy_event(dev, spydata,
 						     address, wstats);
--- net-2.6.22.orig/net/core/pktgen.c	2007-03-08 12:48:49.000000000 -0800
+++ net-2.6.22/net/core/pktgen.c	2007-03-08 12:48:52.000000000 -0800
@@ -644,7 +644,7 @@
 	if (pkt_dev->nr_labels) {
 		unsigned i;
 		seq_printf(seq, "     mpls: ");
-		for(i = 0; i < pkt_dev->nr_labels; i++)
+		for (i = 0; i < pkt_dev->nr_labels; i++)
 			seq_printf(seq, "%08x%s", ntohl(pkt_dev->labels[i]),
 				   i == pkt_dev->nr_labels-1 ? "\n" : ", ");
 	}
@@ -749,7 +749,7 @@
 	int i = 0;
 	*num = 0;
 
-	for(; i < maxlen; i++) {
+	for (; i < maxlen; i++) {
 		char c;
 		*num <<= 4;
 		if (get_user(c, &user_buffer[i]))
@@ -857,7 +857,7 @@
 		n++;
 		if (n >= MAX_MPLS_LABELS)
 			return -E2BIG;
-	} while(c == ',');
+	} while (c == ',');
 
 	pkt_dev->nr_labels = n;
 	return i;
@@ -1486,7 +1486,7 @@
 		if (len < 0) { return len; }
 		i += len;
 		offset = sprintf(pg_result, "OK: mpls=");
-		for(n = 0; n < pkt_dev->nr_labels; n++)
+		for (n = 0; n < pkt_dev->nr_labels; n++)
 			offset += sprintf(pg_result + offset,
 					  "%08x%s", ntohl(pkt_dev->labels[n]),
 					  n == pkt_dev->nr_labels-1 ? "" : ",");
@@ -2147,7 +2147,7 @@
 
 	if (pkt_dev->flags & F_MPLS_RND) {
 		unsigned i;
-		for(i = 0; i < pkt_dev->nr_labels; i++)
+		for (i = 0; i < pkt_dev->nr_labels; i++)
 			if (pkt_dev->labels[i] & MPLS_STACK_BOTTOM)
 				pkt_dev->labels[i] = MPLS_STACK_BOTTOM |
 					     ((__force __be32)random32() &
@@ -2280,7 +2280,7 @@
 static void mpls_push(__be32 *mpls, struct pktgen_dev *pkt_dev)
 {
 	unsigned i;
-	for(i = 0; i < pkt_dev->nr_labels; i++) {
+	for (i = 0; i < pkt_dev->nr_labels; i++) {
 		*mpls++ = pkt_dev->labels[i] & ~MPLS_STACK_BOTTOM;
 	}
 	mpls--;
@@ -2340,7 +2340,7 @@
 		mpls_push(mpls, pkt_dev);
 
 	if (pkt_dev->vlan_id != 0xffff) {
-		if(pkt_dev->svlan_id != 0xffff) {
+		if (pkt_dev->svlan_id != 0xffff) {
 			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
 			*svlan_tci = build_tci(pkt_dev->svlan_id,
 					       pkt_dev->svlan_cfi,
@@ -2676,7 +2676,7 @@
 		mpls_push(mpls, pkt_dev);
 
 	if (pkt_dev->vlan_id != 0xffff) {
-		if(pkt_dev->svlan_id != 0xffff) {
+		if (pkt_dev->svlan_id != 0xffff) {
 			svlan_tci = (__be16 *)skb_put(skb, sizeof(__be16));
 			*svlan_tci = build_tci(pkt_dev->svlan_id,
 					       pkt_dev->svlan_cfi,
--- net-2.6.22.orig/net/compat.c	2007-03-08 12:48:49.000000000 -0800
+++ net-2.6.22/net/compat.c	2007-03-08 12:48:52.000000000 -0800
@@ -34,11 +34,11 @@
 {
 	int tot_len = 0;
 
-	while(niov > 0) {
+	while (niov > 0) {
 		compat_uptr_t buf;
 		compat_size_t len;
 
-		if(get_user(len, &uiov32->iov_len) ||
+		if (get_user(len, &uiov32->iov_len) ||
 		   get_user(buf, &uiov32->iov_base)) {
 			tot_len = -EFAULT;
 			break;
@@ -78,12 +78,12 @@
 {
 	int tot_len;
 
-	if(kern_msg->msg_namelen) {
-		if(mode==VERIFY_READ) {
+	if (kern_msg->msg_namelen) {
+		if (mode==VERIFY_READ) {
 			int err = move_addr_to_kernel(kern_msg->msg_name,
 						      kern_msg->msg_namelen,
 						      kern_address);
-			if(err < 0)
+			if (err < 0)
 				return err;
 		}
 		kern_msg->msg_name = kern_address;
@@ -93,7 +93,7 @@
 	tot_len = iov_from_user_compat_to_kern(kern_iov,
 					  (struct compat_iovec __user *)kern_msg->msg_iov,
 					  kern_msg->msg_iovlen);
-	if(tot_len >= 0)
+	if (tot_len >= 0)
 		kern_msg->msg_iov = kern_iov;
 
 	return tot_len;
@@ -146,8 +146,8 @@
 	kcmlen = 0;
 	kcmsg_base = kcmsg = (struct cmsghdr *)stackbuf;
 	ucmsg = CMSG_COMPAT_FIRSTHDR(kmsg);
-	while(ucmsg != NULL) {
-		if(get_user(ucmlen, &ucmsg->cmsg_len))
+	while (ucmsg != NULL) {
+		if (get_user(ucmlen, &ucmsg->cmsg_len))
 			return -EFAULT;
 
 		/* Catch bogons. */
@@ -160,7 +160,7 @@
 		kcmlen += tmp;
 		ucmsg = cmsg_compat_nxthdr(kmsg, ucmsg, ucmlen);
 	}
-	if(kcmlen == 0)
+	if (kcmlen == 0)
 		return -EINVAL;
 
 	/* The kcmlen holds the 64-bit version of the control length.
@@ -176,7 +176,7 @@
 	/* Now copy them over neatly. */
 	memset(kcmsg, 0, kcmlen);
 	ucmsg = CMSG_COMPAT_FIRSTHDR(kmsg);
-	while(ucmsg != NULL) {
+	while (ucmsg != NULL) {
 		if (__get_user(ucmlen, &ucmsg->cmsg_len))
 			goto Efault;
 		if (!CMSG_COMPAT_OK(ucmlen, ucmsg, kmsg))
@@ -219,7 +219,7 @@
 	struct compat_cmsghdr cmhdr;
 	int cmlen;
 
-	if(cm == NULL || kmsg->msg_controllen < sizeof(*cm)) {
+	if (cm == NULL || kmsg->msg_controllen < sizeof(*cm)) {
 		kmsg->msg_flags |= MSG_CTRUNC;
 		return 0; /* XXX: return error? check spec. */
 	}
@@ -233,7 +233,7 @@
 	}
 
 	cmlen = CMSG_COMPAT_LEN(len);
-	if(kmsg->msg_controllen < cmlen) {
+	if (kmsg->msg_controllen < cmlen) {
 		kmsg->msg_flags |= MSG_CTRUNC;
 		cmlen = kmsg->msg_controllen;
 	}
@@ -241,9 +241,9 @@
 	cmhdr.cmsg_type = type;
 	cmhdr.cmsg_len = cmlen;
 
-	if(copy_to_user(cm, &cmhdr, sizeof cmhdr))
+	if (copy_to_user(cm, &cmhdr, sizeof cmhdr))
 		return -EFAULT;
-	if(copy_to_user(CMSG_COMPAT_DATA(cm), data, cmlen - sizeof(struct compat_cmsghdr)))
+	if (copy_to_user(CMSG_COMPAT_DATA(cm), data, cmlen - sizeof(struct compat_cmsghdr)))
 		return -EFAULT;
 	cmlen = CMSG_COMPAT_SPACE(len);
 	kmsg->msg_control += cmlen;
@@ -622,7 +622,7 @@
 	a0 = a[0];
 	a1 = a[1];
 
-	switch(call) {
+	switch (call) {
 	case SYS_SOCKET:
 		ret = sys_socket(a0, a1, a[2]);
 		break;

--
Stephen Hemminger <shemminger@linux-foundation.org>

