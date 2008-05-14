From: akpm@linux-foundation.org
Subject: [patch 3/8] linux/atm_tcp.h linux/atm.h: cleanup for userspace
Date: Wed, 14 May 2008 16:19:42 -0700
Message-ID: <200805142319.m4ENJhts026557@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	vapier@gentoo.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34782 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754206AbYENXUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>

The atm_tcp.h uses types from linux/atm.h, but does not include it.  It
should also use the standard __u## types from linux/types.h rather than
the uint##_t types since the former can be found with the kernel already.

Same goes for linux/atm.h.  The linux/socket.h include there also gets
dropped as atm.h does not actually use anything from socket.h.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/atm.h     |    7 ++-----
 include/linux/atm_tcp.h |   12 +++++-------
 2 files changed, 7 insertions(+), 12 deletions(-)

diff -puN include/linux/atm.h~linux-atm_tcph-linux-atmh-cleanup-for-userspace include/linux/atm.h
--- a/include/linux/atm.h~linux-atm_tcph-linux-atmh-cleanup-for-userspace
+++ a/include/linux/atm.h
@@ -16,14 +16,11 @@
  * documentation. Do not change them.
  */
 
-#ifdef __KERNEL__
-#include <linux/socket.h>
-#include <linux/types.h>
-#endif
 #include <linux/compiler.h>
 #include <linux/atmapi.h>
 #include <linux/atmsap.h>
 #include <linux/atmioc.h>
+#include <linux/types.h>
 
 
 /* general ATM constants */
@@ -212,7 +209,7 @@ struct sockaddr_atmsvc {
         char		pub[ATM_E164_LEN+1]; /* public address (E.164) */
     					/* unused addresses must be bzero'ed */
 	char		lij_type;	/* role in LIJ call; one of ATM_LIJ* */
-	uint32_t	lij_id;		/* LIJ call identifier */
+	__u32	lij_id;		/* LIJ call identifier */
     } sas_addr __ATM_API_ALIGN;		/* SVC address */
 };
 
diff -puN include/linux/atm_tcp.h~linux-atm_tcph-linux-atmh-cleanup-for-userspace include/linux/atm_tcp.h
--- a/include/linux/atm_tcp.h~linux-atm_tcph-linux-atmh-cleanup-for-userspace
+++ a/include/linux/atm_tcp.h
@@ -8,11 +8,9 @@
 #define LINUX_ATM_TCP_H
 
 #include <linux/atmapi.h>
-
-#ifdef __KERNEL__
-#include <linux/types.h>
-#endif
+#include <linux/atm.h>
 #include <linux/atmioc.h>
+#include <linux/types.h>
 
 
 /*
@@ -20,9 +18,9 @@
  */
 
 struct atmtcp_hdr {
-	uint16_t	vpi;
-	uint16_t	vci;
-	uint32_t	length;		/* ... of data part */
+	__u16	vpi;
+	__u16	vci;
+	__u32	length;		/* ... of data part */
 };
 
 /*
_
