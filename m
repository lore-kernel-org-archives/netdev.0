From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: [PATCH][2.6] fix compilation w/o CONFIG_XFRM
Date: Sat, 18 Oct 2003 03:01:03 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0310180300500.2831@montezuma.fsmlabs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Index: linux-2.6.0-test8/net/ipv6/sit.c
===================================================================
RCS file: /build/cvsroot/linux-2.6.0-test8/net/ipv6/sit.c,v
retrieving revision 1.1.1.1
diff -u -p -B -r1.1.1.1 sit.c
--- linux-2.6.0-test8/net/ipv6/sit.c	18 Oct 2003 01:37:19 -0000	1.1.1.1
+++ linux-2.6.0-test8/net/ipv6/sit.c	18 Oct 2003 04:13:21 -0000
@@ -377,8 +377,10 @@ static int ipip6_rcv(struct sk_buff *skb
 
 	read_lock(&ipip6_lock);
 	if ((tunnel = ipip6_tunnel_lookup(iph->saddr, iph->daddr)) != NULL) {
+#ifdef CONFIG_XFRM
 		secpath_put(skb->sp);
 		skb->sp = NULL;
+#endif
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = skb->data;
 		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
