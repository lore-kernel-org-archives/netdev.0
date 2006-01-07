From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] net/ipv4/ip_output.c: make ip_fragment() static
Date: Sat, 7 Jan 2006 19:15:33 +0100
Message-ID: <20060107181533.GO3774@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030538AbWAGSPf@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since there's no longer any external user of ip_fragment() we can make 
it static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/ip.h     |    1 -
 net/ipv4/ip_output.c |    5 +++--
 2 files changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.15-mm2-full/include/net/ip.h.old	2006-01-07 17:12:04.000000000 +0100
+++ linux-2.6.15-mm2-full/include/net/ip.h	2006-01-07 17:12:11.000000000 +0100
@@ -95,7 +95,6 @@
 extern int		ip_mr_input(struct sk_buff *skb);
 extern int		ip_output(struct sk_buff *skb);
 extern int		ip_mc_output(struct sk_buff *skb);
-extern int		ip_fragment(struct sk_buff *skb, int (*out)(struct sk_buff*));
 extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
 extern int		ip_queue_xmit(struct sk_buff *skb, int ipfragok);
--- linux-2.6.15-mm2-full/net/ipv4/ip_output.c.old	2006-01-07 17:12:21.000000000 +0100
+++ linux-2.6.15-mm2-full/net/ipv4/ip_output.c	2006-01-07 17:21:33.000000000 +0100
@@ -85,6 +85,8 @@
 
 int sysctl_ip_default_ttl = IPDEFTTL;
 
+static int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*));
+
 /* Generate a checksum for an outgoing IP datagram. */
 __inline__ void ip_send_check(struct iphdr *iph)
 {
@@ -409,7 +411,7 @@
  *	single device frame, and queue such a frame for sending.
  */
 
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
+static int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 {
 	struct iphdr *iph;
 	int raw = 0;
@@ -1391,7 +1393,6 @@
 #endif
 }
 
-EXPORT_SYMBOL(ip_fragment);
 EXPORT_SYMBOL(ip_generic_getfrag);
 EXPORT_SYMBOL(ip_queue_xmit);
 EXPORT_SYMBOL(ip_send_check);
