From: Julian Anastasov <ja@ssi.bg>
Subject: tunnel xmit and h.raw
Date: Fri, 3 Oct 2003 03:00:27 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310030252070.1394-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	Is the following change needed? May be yes for all kernels
where the nearest skb_shared checks are actual.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1356  -> 1.1357 
#	   net/ipv4/ip_gre.c	1.30    -> 1.31   
#	      net/ipv6/sit.c	1.28    -> 1.29   
#	     net/ipv4/ipip.c	1.32    -> 1.33   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/03	ja@ssi.bg	1.1357
# [IPV4/IPV6]: tunnel xmit must load skb->h.raw after all reallocations
# --------------------------------------------
#
diff -Nru a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
--- a/net/ipv4/ip_gre.c	Fri Oct  3 02:43:29 2003
+++ b/net/ipv4/ip_gre.c	Fri Oct  3 02:43:29 2003
@@ -803,8 +803,6 @@
 			tunnel->err_count = 0;
 	}
 
-	skb->h.raw = skb->nh.raw;
-
 	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen;
 
 	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shared(skb)) {
@@ -823,6 +821,7 @@
 		old_iph = skb->nh.iph;
 	}
 
+	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, gre_hlen);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	dst_release(skb->dst);
diff -Nru a/net/ipv4/ipip.c b/net/ipv4/ipip.c
--- a/net/ipv4/ipip.c	Fri Oct  3 02:43:29 2003
+++ b/net/ipv4/ipip.c	Fri Oct  3 02:43:29 2003
@@ -596,8 +596,6 @@
 			tunnel->err_count = 0;
 	}
 
-	skb->h.raw = skb->nh.raw;
-
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
@@ -619,6 +617,7 @@
 		old_iph = skb->nh.iph;
 	}
 
+	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	dst_release(skb->dst);
diff -Nru a/net/ipv6/sit.c b/net/ipv6/sit.c
--- a/net/ipv6/sit.c	Fri Oct  3 02:43:29 2003
+++ b/net/ipv6/sit.c	Fri Oct  3 02:43:29 2003
@@ -530,8 +530,6 @@
 			tunnel->err_count = 0;
 	}
 
-	skb->h.raw = skb->nh.raw;
-
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
@@ -553,6 +551,7 @@
 		iph6 = skb->nh.ipv6h;
 	}
 
+	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	dst_release(skb->dst);


Regards

--
Julian Anastasov <ja@ssi.bg>
