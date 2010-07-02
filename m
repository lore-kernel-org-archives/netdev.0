From: kaber@trash.net
Subject: [PATCH 7/9] netfilter: ipt_LOG/ip6t_LOG: remove comparison within loop
Date: Fri,  2 Jul 2010 11:52:20 +0200
Message-ID: <1278064342-19059-8-git-send-email-kaber@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46398 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab0GBJw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 05:52:26 -0400
In-Reply-To: <1278064342-19059-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Remove the comparison within the loop to print the macheader by prepending
the colon to all but the first printk.

Based on suggestion by Jan Engelhardt <jengelh@medozas.de>.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_LOG.c  |   12 ++++++------
 net/ipv6/netfilter/ip6t_LOG.c |    6 +++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 5234f4f..0a452a5 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -411,12 +411,12 @@ ipt_log_packet(u_int8_t pf,
 		    skb->mac_header != skb->network_header) {
 			int i;
 			const unsigned char *p = skb_mac_header(skb);
-			for (i = 0; i < skb->dev->hard_header_len; i++,p++)
-				printk("%02x%c", *p,
-				       i==skb->dev->hard_header_len - 1
-				       ? ' ':':');
-		} else
-			printk(" ");
+
+			printk("%02x", *p++);
+			for (i = 1; i < skb->dev->hard_header_len; i++, p++)
+				printk(":%02x", *p);
+		}
+		printk(" ");
 	}
 
 	dump_packet(loginfo, skb, 0);
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index af4ee11..4c7ddac 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -414,9 +414,9 @@ ip6t_log_packet(u_int8_t pf,
 				p = NULL;
 
 			if (p != NULL) {
-				for (i = 0; i < len; i++)
-					printk("%02x%s", p[i],
-					       i == len - 1 ? "" : ":");
+				printk("%02x", *p++);
+				for (i = 1; i < len; i++)
+					printk(":%02x", p[i]);
 			}
 			printk(" ");
 
-- 
1.7.0.4

