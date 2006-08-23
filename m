From: shemminger@osdl.org
Subject: [PATCH 4/4] bridge-netfilter: debug message fixes
Date: Tue, 22 Aug 2006 17:10:54 -0700
Message-ID: <20060823001231.358194000@localhost.localdomain>
References: <20060823001050.363374000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:38622 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750971AbWHWATX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 20:19:23 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=br-nf-msg.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_NETFILTER_DEBUG is enabled, it shouldn't change the
actions of the filtering. The message about skb->dst being NULL
is commonly triggered by dhclient, so it is useless. Make sure all
messages end in newline.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br-nf.orig/net/bridge/br_netfilter.c	2006-08-22 16:48:56.000000000 -0700
+++ br-nf/net/bridge/br_netfilter.c	2006-08-22 17:07:28.000000000 -0700
@@ -718,16 +718,6 @@
 	else
 		pf = PF_INET6;
 
-#ifdef CONFIG_NETFILTER_DEBUG
-	/* Sometimes we get packets with NULL ->dst here (for example,
-	 * running a dhcp client daemon triggers this). This should now
-	 * be fixed, but let's keep the check around. */
-	if (skb->dst == NULL) {
-		printk(KERN_CRIT "br_netfilter: skb->dst == NULL.");
-		return NF_ACCEPT;
-	}
-#endif
-
 	nf_bridge = skb->nf_bridge;
 	nf_bridge->physoutdev = skb->dev;
 	realindev = nf_bridge->physindev;
@@ -809,7 +799,7 @@
 	 * keep the check just to be sure... */
 	if (skb->mac.raw < skb->head || skb->mac.raw + ETH_HLEN > skb->data) {
 		printk(KERN_CRIT "br_netfilter: Argh!! br_nf_post_routing: "
-		       "bad mac.raw pointer.");
+		       "bad mac.raw pointer.\n");
 		goto print_error;
 	}
 #endif
@@ -827,7 +817,7 @@
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	if (skb->dst == NULL) {
-		printk(KERN_CRIT "br_netfilter: skb->dst == NULL.");
+		printk(KERN_INFO "br_netfilter post_routing: skb->dst == NULL\n");
 		goto print_error;
 	}
 #endif
@@ -864,6 +854,7 @@
 	}
 	printk(" head:%p, raw:%p, data:%p\n", skb->head, skb->mac.raw,
 	       skb->data);
+	dump_stack();
 	return NF_ACCEPT;
 #endif
 }

--


