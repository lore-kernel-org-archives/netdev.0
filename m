From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/8] udp: ipv4 whitespace cleanup
Date: Thu, 08 Mar 2007 12:52:15 -0800
Message-ID: <20070308205305.582324346@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35771 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933313AbXCHUy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:27 -0500
Content-Disposition: inline; filename=udp-1
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix whitespace around keywords.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/udp.c |   95 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 48 insertions(+), 47 deletions(-)

--- net-2.6.22.orig/net/ipv4/udp.c	2007-03-07 10:18:04.000000000 -0800
+++ net-2.6.22/net/ipv4/udp.c	2007-03-07 10:26:57.000000000 -0800
@@ -175,7 +175,8 @@
 			;
 		}
 		result = best;
-		for(i = 0; i < (1 << 16) / UDP_HTABLE_SIZE; i++, result += UDP_HTABLE_SIZE) {
+		for (i = 0; i < (1 << 16) / UDP_HTABLE_SIZE;
+		     i++, result += UDP_HTABLE_SIZE) {
 			if (result > sysctl_local_port_range[1])
 				result = sysctl_local_port_range[0]
 					+ ((result - sysctl_local_port_range[0]) &
@@ -270,10 +271,10 @@
 					continue;
 				score+=2;
 			}
-			if(score == 9) {
+			if (score == 9) {
 				result = sk;
 				break;
-			} else if(score > badness) {
+			} else if (score > badness) {
 				result = sk;
 				badness = score;
 			}
@@ -765,38 +766,38 @@
 
 int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
-	switch(cmd)
+	switch (cmd) {
+	case SIOCOUTQ:
 	{
-		case SIOCOUTQ:
-		{
-			int amount = atomic_read(&sk->sk_wmem_alloc);
-			return put_user(amount, (int __user *)arg);
-		}
+		int amount = atomic_read(&sk->sk_wmem_alloc);
+		return put_user(amount, (int __user *)arg);
+	}
 
-		case SIOCINQ:
-		{
-			struct sk_buff *skb;
-			unsigned long amount;
-
-			amount = 0;
-			spin_lock_bh(&sk->sk_receive_queue.lock);
-			skb = skb_peek(&sk->sk_receive_queue);
-			if (skb != NULL) {
-				/*
-				 * We will only return the amount
-				 * of this packet since that is all
-				 * that will be read.
-				 */
-				amount = skb->len - sizeof(struct udphdr);
-			}
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
-			return put_user(amount, (int __user *)arg);
+	case SIOCINQ:
+	{
+		struct sk_buff *skb;
+		unsigned long amount;
+
+		amount = 0;
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb != NULL) {
+			/*
+			 * We will only return the amount
+			 * of this packet since that is all
+			 * that will be read.
+			 */
+			amount = skb->len - sizeof(struct udphdr);
 		}
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		return put_user(amount, (int __user *)arg);
+	}
 
-		default:
-			return -ENOIOCTLCMD;
+	default:
+		return -ENOIOCTLCMD;
 	}
-	return(0);
+
+	return 0;
 }
 
 /*
@@ -958,7 +959,7 @@
 		/* Check if this is a keepalive packet.  If so, eat it. */
 		if (len == 1 && udpdata[0] == 0xff) {
 			return 0;
-		} else if (len > sizeof(struct ip_esp_hdr) && udpdata32[0] != 0 ) {
+		} else if (len > sizeof(struct ip_esp_hdr) && udpdata32[0] != 0) {
 			/* ESP Packet without Non-ESP header */
 			len = sizeof(struct udphdr);
 		} else
@@ -1141,10 +1142,10 @@
 
 			sknext = udp_v4_mcast_next(sk_next(sk), uh->dest, daddr,
 						   uh->source, saddr, dif);
-			if(sknext)
+			if (sknext)
 				skb1 = skb_clone(skb, GFP_ATOMIC);
 
-			if(skb1) {
+			if (skb1) {
 				int ret = udp_queue_rcv_skb(sk, skb1);
 				if (ret > 0)
 					/* we should probably re-process instead
@@ -1152,7 +1153,7 @@
 					kfree_skb(skb1);
 			}
 			sk = sknext;
-		} while(sknext);
+		} while (sknext);
 	} else
 		kfree_skb(skb);
 	read_unlock(&udp_hash_lock);
@@ -1230,7 +1231,7 @@
 	if (udp4_csum_init(skb, uh, proto))
 		goto csum_error;
 
-	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
+	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
 	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
@@ -1264,7 +1265,7 @@
 	 * don't wanna listen.  Ignore it.
 	 */
 	kfree_skb(skb);
-	return(0);
+	return 0;
 
 short_packet:
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: short packet: From %u.%u.%u.%u:%u %d/%d to %u.%u.%u.%u:%u\n",
@@ -1292,7 +1293,7 @@
 drop:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
-	return(0);
+	return 0;
 }
 
 __inline__ int udp_rcv(struct sk_buff *skb)
@@ -1319,13 +1320,13 @@
 	int val;
 	int err = 0;
 
-	if(optlen<sizeof(int))
+	if (optlen<sizeof(int))
 		return -EINVAL;
 
 	if (get_user(val, (int __user *)optval))
 		return -EFAULT;
 
-	switch(optname) {
+	switch (optname) {
 	case UDP_CORK:
 		if (val != 0) {
 			up->corkflag = 1;
@@ -1379,7 +1380,7 @@
 	default:
 		err = -ENOPROTOOPT;
 		break;
-	};
+	}
 
 	return err;
 }
@@ -1410,15 +1411,15 @@
 	struct udp_sock *up = udp_sk(sk);
 	int val, len;
 
-	if(get_user(len,optlen))
+	if (get_user(len,optlen))
 		return -EFAULT;
 
 	len = min_t(unsigned int, len, sizeof(int));
 
-	if(len < 0)
+	if (len < 0)
 		return -EINVAL;
 
-	switch(optname) {
+	switch (optname) {
 	case UDP_CORK:
 		val = up->corkflag;
 		break;
@@ -1439,11 +1440,11 @@
 
 	default:
 		return -ENOPROTOOPT;
-	};
+	}
 
-	if(put_user(len, optlen))
+	if (put_user(len, optlen))
 		return -EFAULT;
-	if(copy_to_user(optval, &val,len))
+	if (copy_to_user(optval, &val,len))
 		return -EFAULT;
 	return 0;
 }
@@ -1575,7 +1576,7 @@
 	struct sock *sk = udp_get_first(seq);
 
 	if (sk)
-		while(pos && (sk = udp_get_next(seq, sk)) != NULL)
+		while (pos && (sk = udp_get_next(seq, sk)) != NULL)
 			--pos;
 	return pos ? NULL : sk;
 }

--
Stephen Hemminger <shemminger@linux-foundation.org>

