From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] dst->{in,out}put() clean-up
Date: Thu, 20 Feb 2003 02:28:40 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030220.022840.48274187.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This patch removes dst->input() and dst->output(), and use
dst_input() and dst_output() instead.

Patch is against linux-2.5.62.

Thank you in advance.

-------------------------------------------------------------------
Patch-Name: dst->{in,out}put() clean-up.
Patch-Id: FIX_2_5_62_CLEANUP-20030219
Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Credit: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>,
	David Miller <davem@redhat.com>
-------------------------------------------------------------------
Index: include/net/dn_route.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/net/dn_route.h,v
retrieving revision 1.1.1.2
retrieving revision 1.1.1.2.18.1
diff -u -r1.1.1.2 -r1.1.1.2.18.1
--- include/net/dn_route.h	14 Oct 2002 13:07:48 -0000	1.1.1.2
+++ include/net/dn_route.h	19 Feb 2003 13:46:37 -0000	1.1.1.2.18.1
@@ -122,7 +122,7 @@
 	if ((dst = sk->dst_cache) && !dst->obsolete) {
 try_again:
 		skb->dst = dst_clone(dst);
-		dst->output(skb);
+		dst_output(skb);
 		return;
 	}
 
Index: net/decnet/dn_nsp_out.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/decnet/dn_nsp_out.c,v
retrieving revision 1.1.1.1
retrieving revision 1.1.1.1.24.1
diff -u -r1.1.1.1 -r1.1.1.1.24.1
--- net/decnet/dn_nsp_out.c	7 Oct 2002 10:20:39 -0000	1.1.1.1
+++ net/decnet/dn_nsp_out.c	19 Feb 2003 13:44:54 -0000	1.1.1.1.24.1
@@ -593,7 +593,7 @@
 	 * associations.
 	 */
 	skb->dst = dst_clone(dst);
-	skb->dst->output(skb);
+	dst_output(skb);
 }
 
 
Index: net/decnet/dn_route.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/decnet/dn_route.c,v
retrieving revision 1.1.1.4
retrieving revision 1.1.1.4.8.1
diff -u -r1.1.1.4 -r1.1.1.4.8.1
--- net/decnet/dn_route.c	11 Nov 2002 04:09:01 -0000	1.1.1.4
+++ net/decnet/dn_route.c	19 Feb 2003 13:44:54 -0000	1.1.1.4.8.1
@@ -389,7 +389,7 @@
 	int err;
 
 	if ((err = dn_route_input(skb)) == 0)
-		return skb->dst->input(skb);
+		return dst_input(skb);
 
 	if (decnet_debug_level & 4) {
 		char *devname = skb->dev ? skb->dev->name : "???";
Index: net/ipv4/igmp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/igmp.c,v
retrieving revision 1.1.1.4
retrieving revision 1.1.1.4.14.1
diff -u -r1.1.1.4 -r1.1.1.4.14.1
--- net/ipv4/igmp.c	30 Oct 2002 09:43:15 -0000	1.1.1.4
+++ net/ipv4/igmp.c	19 Feb 2003 13:44:54 -0000	1.1.1.4.14.1
@@ -184,12 +184,12 @@
 
 #define IGMP_SIZE (sizeof(struct igmphdr)+sizeof(struct iphdr)+4)
 
-/* Don't just hand NF_HOOK skb->dst->output, in case netfilter hook
+/* Don't just hand NF_HOOK dst_output, in case netfilter hook
    changes route */
 static inline int
 output_maybe_reroute(struct sk_buff *skb)
 {
-	return skb->dst->output(skb);
+	return dst_output(skb);
 }
 
 static int igmp_send_report(struct net_device *dev, u32 group, int type)
Index: net/ipv4/ip_input.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/ip_input.c,v
retrieving revision 1.1.1.6
retrieving revision 1.1.1.6.6.1
diff -u -r1.1.1.6 -r1.1.1.6.6.1
--- net/ipv4/ip_input.c	9 Jan 2003 11:14:34 -0000	1.1.1.6
+++ net/ipv4/ip_input.c	19 Feb 2003 13:44:54 -0000	1.1.1.6.6.1
@@ -344,7 +344,7 @@
 		}
 	}
 
-	return skb->dst->input(skb);
+	return dst_input(skb);
 
 inhdr_error:
 	IP_INC_STATS_BH(IpInHdrErrors);
Index: net/ipv4/ipmr.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/ipmr.c,v
retrieving revision 1.1.1.6
retrieving revision 1.1.1.6.8.1
diff -u -r1.1.1.6 -r1.1.1.6.8.1
--- net/ipv4/ipmr.c	11 Nov 2002 04:08:51 -0000	1.1.1.6
+++ net/ipv4/ipmr.c	19 Feb 2003 13:44:54 -0000	1.1.1.6.8.1
@@ -1112,9 +1112,9 @@
 	struct dst_entry *dst = skb->dst;
 
 	if (skb->len <= dst_pmtu(dst))
-		return dst->output(skb);
+		return dst_output(skb);
 	else
-		return ip_fragment(skb, dst->output);
+		return ip_fragment(skb, dst_output);
 }
 
 /*
Index: net/ipv6/exthdrs.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/exthdrs.c,v
retrieving revision 1.1.1.2
retrieving revision 1.1.1.2.6.1
diff -u -r1.1.1.2 -r1.1.1.2.6.1
--- net/ipv6/exthdrs.c	9 Jan 2003 11:14:36 -0000	1.1.1.2
+++ net/ipv6/exthdrs.c	19 Feb 2003 09:44:56 -0000	1.1.1.2.6.1
@@ -288,7 +288,7 @@
 	dst_release(xchg(&skb->dst, NULL));
 	ip6_route_input(skb);
 	if (skb->dst->error) {
-		skb->dst->input(skb);
+		dst_input(skb);
 		return -1;
 	}
 	if (skb->dst->dev->flags&IFF_LOOPBACK) {
@@ -302,7 +302,7 @@
 		goto looped_back;
 	}
 
-	skb->dst->input(skb);
+	dst_input(skb);
 	return -1;
 }
 
Index: net/ipv6/ip6_input.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ip6_input.c,v
retrieving revision 1.1.1.4
retrieving revision 1.1.1.4.8.2
diff -u -r1.1.1.4 -r1.1.1.4.8.2
--- net/ipv6/ip6_input.c	23 Nov 2002 11:09:43 -0000	1.1.1.4
+++ net/ipv6/ip6_input.c	19 Feb 2003 13:44:54 -0000	1.1.1.4.8.2
@@ -47,7 +47,7 @@
 	if (skb->dst == NULL)
 		ip6_route_input(skb);
 
-	return skb->dst->input(skb);
+	return dst_input(skb);
 }
 
 int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt)
@@ -235,7 +235,7 @@
 				skb2 = skb;
 			}
 
-			dst->output(skb2);
+			dst_output(skb2);
 		}
 	}
 #endif
Index: net/ipv6/ip6_output.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ip6_output.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 ip6_output.c
--- net/ipv6/ip6_output.c	30 Oct 2002 09:43:18 -0000	1.1.1.3
+++ net/ipv6/ip6_output.c	19 Feb 2003 13:47:12 -0000
@@ -174,7 +174,7 @@
 		}
 	}
 #endif /* CONFIG_NETFILTER */
-	return skb->dst->output(skb);
+	return dst_output(skb);
 }
 
 /*
@@ -722,7 +722,7 @@
 
 static inline int ip6_forward_finish(struct sk_buff *skb)
 {
-	return skb->dst->output(skb);
+	return dst_output(skb);
 }
 
 int ip6_forward(struct sk_buff *skb)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
