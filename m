From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/12] ipv6: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:08 -0700
Message-ID: <fdf669362718dc52457a796e642a6df739bd0d8a.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3464 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756710Ab1GATnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2011 15:43:47 -0400
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the case labels the same indent as the switch.

git diff -w shows 80 column reflowing,
removal of a useless break after return, and moving
open brace after case instead of separate line.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/raw.c |  145 ++++++++++++++++++++++++++-----------------------------
 1 files changed, 69 insertions(+), 76 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index cc7313b..6a79f30 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -959,57 +959,54 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 		return -EFAULT;
 
 	switch (optname) {
-		case IPV6_CHECKSUM:
-			if (inet_sk(sk)->inet_num == IPPROTO_ICMPV6 &&
-			    level == IPPROTO_IPV6) {
-				/*
-				 * RFC3542 tells that IPV6_CHECKSUM socket
-				 * option in the IPPROTO_IPV6 level is not
-				 * allowed on ICMPv6 sockets.
-				 * If you want to set it, use IPPROTO_RAW
-				 * level IPV6_CHECKSUM socket option
-				 * (Linux extension).
-				 */
-				return -EINVAL;
-			}
+	case IPV6_CHECKSUM:
+		if (inet_sk(sk)->inet_num == IPPROTO_ICMPV6 &&
+		    level == IPPROTO_IPV6) {
+			/*
+			 * RFC3542 tells that IPV6_CHECKSUM socket
+			 * option in the IPPROTO_IPV6 level is not
+			 * allowed on ICMPv6 sockets.
+			 * If you want to set it, use IPPROTO_RAW
+			 * level IPV6_CHECKSUM socket option
+			 * (Linux extension).
+			 */
+			return -EINVAL;
+		}
 
-			/* You may get strange result with a positive odd offset;
-			   RFC2292bis agrees with me. */
-			if (val > 0 && (val&1))
-				return -EINVAL;
-			if (val < 0) {
-				rp->checksum = 0;
-			} else {
-				rp->checksum = 1;
-				rp->offset = val;
-			}
+		/* You may get strange result with a positive odd offset;
+		   RFC2292bis agrees with me. */
+		if (val > 0 && (val&1))
+			return -EINVAL;
+		if (val < 0) {
+			rp->checksum = 0;
+		} else {
+			rp->checksum = 1;
+			rp->offset = val;
+		}
 
-			return 0;
-			break;
+		return 0;
 
-		default:
-			return -ENOPROTOOPT;
+	default:
+		return -ENOPROTOOPT;
 	}
 }
 
 static int rawv6_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, unsigned int optlen)
 {
-	switch(level) {
-		case SOL_RAW:
-			break;
+	switch (level) {
+	case SOL_RAW:
+		break;
 
-		case SOL_ICMPV6:
-			if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
-				return -EOPNOTSUPP;
-			return rawv6_seticmpfilter(sk, level, optname, optval,
-						   optlen);
-		case SOL_IPV6:
-			if (optname == IPV6_CHECKSUM)
-				break;
-		default:
-			return ipv6_setsockopt(sk, level, optname, optval,
-					       optlen);
+	case SOL_ICMPV6:
+		if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
+			return -EOPNOTSUPP;
+		return rawv6_seticmpfilter(sk, level, optname, optval, optlen);
+	case SOL_IPV6:
+		if (optname == IPV6_CHECKSUM)
+			break;
+	default:
+		return ipv6_setsockopt(sk, level, optname, optval, optlen);
 	}
 
 	return do_rawv6_setsockopt(sk, level, optname, optval, optlen);
@@ -1075,21 +1072,19 @@ static int do_rawv6_getsockopt(struct sock *sk, int level, int optname,
 static int rawv6_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
-	switch(level) {
-		case SOL_RAW:
-			break;
+	switch (level) {
+	case SOL_RAW:
+		break;
 
-		case SOL_ICMPV6:
-			if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
-				return -EOPNOTSUPP;
-			return rawv6_geticmpfilter(sk, level, optname, optval,
-						   optlen);
-		case SOL_IPV6:
-			if (optname == IPV6_CHECKSUM)
-				break;
-		default:
-			return ipv6_getsockopt(sk, level, optname, optval,
-					       optlen);
+	case SOL_ICMPV6:
+		if (inet_sk(sk)->inet_num != IPPROTO_ICMPV6)
+			return -EOPNOTSUPP;
+		return rawv6_geticmpfilter(sk, level, optname, optval, optlen);
+	case SOL_IPV6:
+		if (optname == IPV6_CHECKSUM)
+			break;
+	default:
+		return ipv6_getsockopt(sk, level, optname, optval, optlen);
 	}
 
 	return do_rawv6_getsockopt(sk, level, optname, optval, optlen);
@@ -1119,31 +1114,29 @@ static int compat_rawv6_getsockopt(struct sock *sk, int level, int optname,
 
 static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
-	switch(cmd) {
-		case SIOCOUTQ:
-		{
-			int amount = sk_wmem_alloc_get(sk);
+	switch (cmd) {
+	case SIOCOUTQ: {
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
-			if (skb != NULL)
-				amount = skb->tail - skb->transport_header;
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
-			return put_user(amount, (int __user *)arg);
-		}
+		return put_user(amount, (int __user *)arg);
+	}
+	case SIOCINQ: {
+		struct sk_buff *skb;
+		int amount = 0;
+
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb != NULL)
+			amount = skb->tail - skb->transport_header;
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		return put_user(amount, (int __user *)arg);
+	}
 
-		default:
+	default:
 #ifdef CONFIG_IPV6_MROUTE
-			return ip6mr_ioctl(sk, cmd, (void __user *)arg);
+		return ip6mr_ioctl(sk, cmd, (void __user *)arg);
 #else
-			return -ENOIOCTLCMD;
+		return -ENOIOCTLCMD;
 #endif
 	}
 }
-- 
1.7.6.rc1

