From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] linux/net.h: bye bye struct net_proto
Date: Thu, 3 Apr 2003 11:40:03 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030403144003.GA17155@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/net-2.5

	Still the same tree, not yet updated to linus's.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1003, 2003-04-03 11:08:27-03:00, acme@conectiva.com.br
  o linux/net.h: bye bye struct net_proto
  
  struct net_proto is not anymore needed, as the protocols
  have their init functions marked as __init, not needing
  explicit calling.


 include/linux/atm.h      |   11 -----------
 include/linux/if_pppox.h |    2 --
 include/linux/inet.h     |    7 +------
 include/linux/net.h      |   10 ----------
 include/net/af_unix.h    |    1 -
 net/atm/common.c         |    3 +--
 net/atm/pvc.c            |    7 +++----
 net/atm/svc.c            |    7 +++----
 net/ipv4/af_inet.c       |    2 +-
 net/unix/af_unix.c       |    5 ++---
 10 files changed, 11 insertions(+), 44 deletions(-)


diff -Nru a/include/linux/atm.h b/include/linux/atm.h
--- a/include/linux/atm.h	Thu Apr  3 11:23:28 2003
+++ b/include/linux/atm.h	Thu Apr  3 11:23:28 2003
@@ -236,15 +236,4 @@
 };
 
 typedef unsigned short atm_backend_t;
-
-#ifdef __KERNEL__
-
-#include <linux/net.h>	/* struct net_proto */
-
-
-void atmpvc_proto_init(struct net_proto *pro);
-void atmsvc_proto_init(struct net_proto *pro);
-
-#endif /* __KERNEL__ */
-
 #endif
diff -Nru a/include/linux/if_pppox.h b/include/linux/if_pppox.h
--- a/include/linux/if_pppox.h	Thu Apr  3 11:23:28 2003
+++ b/include/linux/if_pppox.h	Thu Apr  3 11:23:28 2003
@@ -158,8 +158,6 @@
 
 extern struct ppp_channel_ops pppoe_chan_ops;
 
-extern int pppox_proto_init(struct net_proto *np);
-
 #endif /* __KERNEL__ */
 
 #endif /* !(__LINUX_IF_PPPOX_H) */
diff -Nru a/include/linux/inet.h b/include/linux/inet.h
--- a/include/linux/inet.h	Thu Apr  3 11:23:28 2003
+++ b/include/linux/inet.h	Thu Apr  3 11:23:28 2003
@@ -43,11 +43,6 @@
 #define _LINUX_INET_H
 
 #ifdef __KERNEL__
-
-#include <linux/net.h>
-
-extern void		inet_proto_init(struct net_proto *pro);
-extern __u32		in_aton(const char *str);
-
+extern __u32 in_aton(const char *str);
 #endif
 #endif	/* _LINUX_INET_H */
diff -Nru a/include/linux/net.h b/include/linux/net.h
--- a/include/linux/net.h	Thu Apr  3 11:23:28 2003
+++ b/include/linux/net.h	Thu Apr  3 11:23:28 2003
@@ -136,16 +136,6 @@
 	short	encrypt_net;
 };
 
-/**
- *  struct socket - network interface with the file system
- *  @name - Protocol name
- *  @init_func - Bootstrap
- */
-struct net_proto {
-	const char *name;
-	void	  (*init_func)(struct net_proto *pro);
-};
-
 extern int	     sock_wake_async(struct socket *sk, int how, int band);
 extern int	     sock_register(struct net_proto_family *fam);
 extern int	     sock_unregister(int family);
diff -Nru a/include/net/af_unix.h b/include/net/af_unix.h
--- a/include/net/af_unix.h	Thu Apr  3 11:23:28 2003
+++ b/include/net/af_unix.h	Thu Apr  3 11:23:28 2003
@@ -1,6 +1,5 @@
 #ifndef __LINUX_NET_AFUNIX_H
 #define __LINUX_NET_AFUNIX_H
-extern void unix_proto_init(struct net_proto *pro);
 extern void unix_inflight(struct file *fp);
 extern void unix_notinflight(struct file *fp);
 typedef struct sock unix_socket;
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Apr  3 11:23:28 2003
+++ b/net/atm/common.c	Thu Apr  3 11:23:28 2003
@@ -6,8 +6,7 @@
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kmod.h>
-#include <linux/net.h>		/* struct socket, struct net_proto, struct
-				   proto_ops */
+#include <linux/net.h>		/* struct socket, struct proto_ops */
 #include <linux/atm.h>		/* ATM stuff */
 #include <linux/atmdev.h>
 #include <linux/atmclip.h>	/* CLIP_*ENCAP */
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Thu Apr  3 11:23:28 2003
+++ b/net/atm/pvc.c	Thu Apr  3 11:23:28 2003
@@ -4,8 +4,7 @@
 
 
 #include <linux/config.h>
-#include <linux/net.h>		/* struct socket, struct net_proto,
-				   struct proto_ops */
+#include <linux/net.h>		/* struct socket, struct proto_ops */
 #include <linux/atm.h>		/* ATM stuff */
 #include <linux/atmdev.h>	/* ATM devices */
 #include <linux/atmclip.h>	/* Classical IP over ATM */
@@ -111,8 +110,8 @@
 
 
 static struct net_proto_family pvc_family_ops = {
-	.family =PF_ATMPVC,
-	.create =pvc_create,
+	.family = PF_ATMPVC,
+	.create = pvc_create,
 };
 
 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Thu Apr  3 11:23:28 2003
+++ b/net/atm/svc.c	Thu Apr  3 11:23:28 2003
@@ -4,8 +4,7 @@
 
 
 #include <linux/string.h>
-#include <linux/net.h>		/* struct socket, struct net_proto,
-				   struct proto_ops */
+#include <linux/net.h>		/* struct socket, struct proto_ops */
 #include <linux/errno.h>	/* error codes */
 #include <linux/kernel.h>	/* printk */
 #include <linux/skbuff.h>
@@ -430,8 +429,8 @@
 
 
 static struct net_proto_family svc_family_ops = {
-	.family =PF_ATMSVC,
-	.create =svc_create,
+	.family = PF_ATMSVC,
+	.create = svc_create,
 };
 
 
diff -Nru a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c	Thu Apr  3 11:23:28 2003
+++ b/net/ipv4/af_inet.c	Thu Apr  3 11:23:28 2003
@@ -1122,7 +1122,7 @@
 	printk(KERN_INFO "NET4: Linux TCP/IP 1.0 for NET4.0\n");
 
 	if (sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb)) {
-		printk(KERN_CRIT "inet_proto_init: panic\n");
+		printk(KERN_CRIT "%s: panic\n", __FUNCTION__);
 		return -EINVAL;
 	}
 
diff -Nru a/net/unix/af_unix.c b/net/unix/af_unix.c
--- a/net/unix/af_unix.c	Thu Apr  3 11:23:28 2003
+++ b/net/unix/af_unix.c	Thu Apr  3 11:23:28 2003
@@ -1945,9 +1945,8 @@
 	struct sk_buff *dummy_skb;
 
 	printk(banner);
-	if (sizeof(struct unix_skb_parms) > sizeof(dummy_skb->cb))
-	{
-		printk(KERN_CRIT "unix_proto_init: panic\n");
+	if (sizeof(struct unix_skb_parms) > sizeof(dummy_skb->cb)) {
+		printk(KERN_CRIT "%s: panic\n", __FUNCTION__);
 		return -1;
 	}
         /* allocate our sock slab cache */

===================================================================


This BitKeeper patch contains the following changesets:
1.1003
## Wrapped with gzip_uu ##


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
6HV_S27P:>H'O0D-C_0O4A,_X^2$     
 
