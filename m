From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 6/7] netpoll: handle xmit_lock recursion similarly
Date: Thu, 03 Mar 2005 14:46:32 -0600
Message-ID: <7.454130102@selenic.com>
References: <6.454130102@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <6.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Handle possible recursion on xmit_lock while we're at it.

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: rc4/net/core/netpoll.c
===================================================================
--- rc4.orig/net/core/netpoll.c	2005-02-17 22:40:05.000000000 -0600
+++ rc4/net/core/netpoll.c	2005-02-17 22:40:07.000000000 -0600
@@ -247,8 +247,9 @@
 		return;
 	}
 
-	/* avoid ->poll recursion */
-	if(np->poll_owner == __smp_processor_id()) {
+	/* avoid recursion */
+	if(np->poll_owner == __smp_processor_id() ||
+	   np->dev->xmit_lock_owner == __smp_processor_id()) {
 		if (np->drop)
 			np->drop(skb);
 		else
