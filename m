From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [SCTP] Fix incestuous header relations
Date: Sun, 30 Nov 2003 09:06:23 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031129220623.GA11019@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="5mCyUwZo2JvN/JJP"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch fixes the sm.h + sctp.h inclusion loop by including sm.h only
in the files that need it.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/include/net/sctp/sctp.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/sctp/sctp.h,v
retrieving revision 1.1.1.13
diff -u -r1.1.1.13 sctp.h
--- kernel-source-2.5/include/net/sctp/sctp.h	8 Oct 2003 19:24:03 -0000	1.1.1.13
+++ kernel-source-2.5/include/net/sctp/sctp.h	29 Nov 2003 21:49:45 -0000
@@ -90,7 +90,6 @@
 #include <net/snmp.h>
 #include <net/sctp/structs.h>
 #include <net/sctp/constants.h>
-#include <net/sctp/sm.h>
 
 
 /* Set SCTP_DEBUG flag via config if not already set. */
Index: kernel-source-2.5/net/sctp/associola.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/sctp/associola.c,v
retrieving revision 1.1.1.14
diff -u -r1.1.1.14 associola.c
--- kernel-source-2.5/net/sctp/associola.c	8 Oct 2003 19:24:01 -0000	1.1.1.14
+++ kernel-source-2.5/net/sctp/associola.c	29 Nov 2003 21:49:54 -0000
@@ -58,6 +58,7 @@
 #include <linux/in.h>
 #include <net/ipv6.h>
 #include <net/sctp/sctp.h>
+#include <net/sctp/sm.h>
 
 /* Forward declarations for internal functions. */
 static void sctp_assoc_bh_rcv(struct sctp_association *asoc);
Index: kernel-source-2.5/net/sctp/outqueue.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/sctp/outqueue.c,v
retrieving revision 1.1.1.10
diff -u -r1.1.1.10 outqueue.c
--- kernel-source-2.5/net/sctp/outqueue.c	27 Jul 2003 17:00:11 -0000	1.1.1.10
+++ kernel-source-2.5/net/sctp/outqueue.c	29 Nov 2003 21:56:18 -0000
@@ -53,6 +53,7 @@
 #include <net/sock.h>	  /* For skb_set_owner_w */
 
 #include <net/sctp/sctp.h>
+#include <net/sctp/sm.h>
 
 /* Declare internal functions here.  */
 static int sctp_acked(struct sctp_sackhdr *sack, __u32 tsn);
Index: kernel-source-2.5/net/sctp/socket.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/sctp/socket.c,v
retrieving revision 1.1.1.14
diff -u -r1.1.1.14 socket.c
--- kernel-source-2.5/net/sctp/socket.c	8 Oct 2003 19:24:53 -0000	1.1.1.14
+++ kernel-source-2.5/net/sctp/socket.c	29 Nov 2003 22:02:02 -0000
@@ -77,6 +77,7 @@
 #include <linux/socket.h> /* for sa_family_t */
 #include <net/sock.h>
 #include <net/sctp/sctp.h>
+#include <net/sctp/sm.h>
 
 /* WARNING:  Please do not remove the SCTP_STATIC attribute to
  * any of the functions below as they are used to export functions
Index: kernel-source-2.5/net/sctp/transport.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/sctp/transport.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 transport.c
--- kernel-source-2.5/net/sctp/transport.c	27 Jul 2003 16:57:51 -0000	1.1.1.8
+++ kernel-source-2.5/net/sctp/transport.c	29 Nov 2003 21:57:55 -0000
@@ -50,6 +50,7 @@
 
 #include <linux/types.h>
 #include <net/sctp/sctp.h>
+#include <net/sctp/sm.h>
 
 /* 1st Level Abstractions.  */
 

--5mCyUwZo2JvN/JJP--
