From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] IPv6 MIB:ipv6inetNetToMediaTable
Date: Wed, 14 Jan 2004 16:21:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401141621.26317.mashirle@us.ibm.com>
References: <200311191621.38087.mashirle@us.ibm.com> <200312051351.47962.mashirle@us.ibm.com> <20031205145700.120e9e68.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_QZ8IASFRBJZYX1ZOFHBV"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031205145700.120e9e68.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_QZ8IASFRBJZYX1ZOFHBV
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

This patch is against 2.6.1 kernel.

Thanks
Shirley Ma
IBM Linux Technology Center



--------------Boundary-00=_QZ8IASFRBJZYX1ZOFHBV
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.1-ipv6mib5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.1-ipv6mib5.patch"

diff -urN linux-2.6.1/include/linux/rtnetlink.h linux-2.6.1-ipv6mib5/include/linux/rtnetlink.h
--- linux-2.6.1/include/linux/rtnetlink.h	2004-01-08 22:59:55.000000000 -0800
+++ linux-2.6.1-ipv6mib5/include/linux/rtnetlink.h	2004-01-13 10:38:27.000000000 -0800
@@ -3,6 +3,7 @@
 
 #include <linux/netlink.h>
 
+#define TIME_DELTA(a,b) ((unsigned long)((long)(a) - (long)(b)))
 /****
  *		Routing/neighbour discovery messages.
  ****/
diff -urN linux-2.6.1/net/core/neighbour.c linux-2.6.1-ipv6mib5/net/core/neighbour.c
--- linux-2.6.1/net/core/neighbour.c	2004-01-08 22:59:06.000000000 -0800
+++ linux-2.6.1-ipv6mib5/net/core/neighbour.c	2004-01-14 15:38:57.000000000 -0800
@@ -1339,7 +1339,6 @@
 static int neigh_fill_info(struct sk_buff *skb, struct neighbour *n,
 			   u32 pid, u32 seq, int event)
 {
-	unsigned long now = jiffies;
 	unsigned char *b = skb->tail;
 	struct nda_cacheinfo ci;
 	int locked = 0;
@@ -1357,9 +1356,13 @@
 	ndm->ndm_state	 = n->nud_state;
 	if (n->nud_state & NUD_VALID)
 		RTA_PUT(skb, NDA_LLADDR, n->dev->addr_len, n->ha);
-	ci.ndm_used	 = now - n->used;
-	ci.ndm_confirmed = now - n->confirmed;
-	ci.ndm_updated	 = now - n->updated;
+	ci.ndm_used	 = (__u32)(TIME_DELTA(n->used, INITIAL_JIFFIES)/HZ*100
+			   + TIME_DELTA(n->used, INITIAL_JIFFIES)%HZ*100/HZ);
+	ci.ndm_confirmed = (__u32)(TIME_DELTA(n->confirmed, INITIAL_JIFFIES)/HZ
+			   *100 + TIME_DELTA(n->confirmed, INITIAL_JIFFIES)%HZ
+			   *100/HZ);
+	ci.ndm_updated	 = (__u32)(TIME_DELTA(n->updated, INITIAL_JIFFIES)/HZ*100
+			   + TIME_DELTA(n->updated, INITIAL_JIFFIES)%HZ*100/HZ);
 	ci.ndm_refcnt	 = atomic_read(&n->refcnt) - 1;
 	read_unlock_bh(&n->lock);
 	locked		 = 0;
diff -urN linux-2.6.1/net/ipv6/addrconf.c linux-2.6.1-ipv6mib5/net/ipv6/addrconf.c
--- linux-2.6.1/net/ipv6/addrconf.c	2004-01-08 23:00:03.000000000 -0800
+++ linux-2.6.1-ipv6mib5/net/ipv6/addrconf.c	2004-01-13 10:38:27.000000000 -0800
@@ -93,7 +93,6 @@
 #endif
 
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
-#define TIME_DELTA(a,b) ((unsigned long)((long)(a) - (long)(b)))
 
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev, struct ipv6_devconf *p);

--------------Boundary-00=_QZ8IASFRBJZYX1ZOFHBV--
