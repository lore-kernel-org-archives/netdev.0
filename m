From: Steven Whitehouse <steve@gw.chygwyn.com>
Subject: ip_gre.c:ipgre_tunnel_xmit() duplicated code ?
Date: Mon, 21 Apr 2003 11:21:59 +0100 (BST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200304211021.LAA21942@gw.chygwyn.com>
References: <20030418.034241.38698733.davem@redhat.com>
Reply-To: Steve Whitehouse <Steve@ChyGwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030418.034241.38698733.davem@redhat.com> from "David S. Miller" at Apr 18, 2003 03:42:41 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I found some code in ip_gre.c which looks to be duplicated. Is the attached
the right fix or did I miss something? 

Steve.
-----------------------------------------------------------------------------

diff -Nru linux-2.5.68/net/ipv4/ip_gre.c linux/net/ipv4/ip_gre.c
--- linux-2.5.68/net/ipv4/ip_gre.c	Sun Apr 20 03:28:01 2003
+++ linux/net/ipv4/ip_gre.c	Mon Apr 21 03:05:23 2003
@@ -777,9 +777,6 @@
 		skb->dst->ops->update_pmtu(skb->dst, mtu);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
-		if (skb->dst)
-			skb->dst->ops->update_pmtu(skb->dst, mtu);
-
 		df |= (old_iph->frag_off&htons(IP_DF));
 
 		if ((old_iph->frag_off&htons(IP_DF)) &&
