From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] replace sppp_of macro with inline
Date: Tue, 16 Sep 2003 16:55:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916165537.310229e6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace macro with inline and get some type checking.

diff -Nru a/include/net/syncppp.h b/include/net/syncppp.h
--- a/include/net/syncppp.h	Tue Sep 16 16:54:39 2003
+++ b/include/net/syncppp.h	Tue Sep 16 16:54:39 2003
@@ -57,8 +57,11 @@
 	struct sppp sppp;	/* Synchronous PPP */
 };
 
-#define sppp_of(dev)	\
-	    (&((struct ppp_device *)(*(unsigned long *)((dev)->priv)))->sppp)
+static inline struct sppp *sppp_of(struct net_device *dev) 
+{
+	struct ppp_device *ppp = dev->priv;
+	return &ppp->sppp;
+}
 
 #define PP_KEEPALIVE    0x01    /* use keepalive protocol */
 #define PP_CISCO        0x02    /* use Cisco protocol instead of PPP */
