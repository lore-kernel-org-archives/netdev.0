From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Thu, 03 Mar 2005 14:46:32 -0600
Message-ID: <8.454130102@selenic.com>
References: <7.454130102@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <7.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Packets that have destructors should not be zapped here as that might
produce additional printk warnings via netconsole.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: np/net/core/netpoll.c
===================================================================
--- np.orig/net/core/netpoll.c	2005-03-03 14:16:29.579809668 -0600
+++ np/net/core/netpoll.c	2005-03-03 14:17:21.167652225 -0600
@@ -192,7 +192,8 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			__kfree_skb(skb);
+			if(!skb->destructor)
+				__kfree_skb(skb);
 		}
 	}
 
