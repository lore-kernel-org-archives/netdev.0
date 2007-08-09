From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 20/24] make atomic_read() behave consistently on sparc
Date: Thu, 9 Aug 2007 10:14:47 -0400
Message-ID: <20070809141447.GA18787@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935516AbXHIOPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:15:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic_t on sparc.
Leave atomic24_t alone, since it's only used by sparc-specific code.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-sparc/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-sparc/atomic.h	2007-08-09 07:29:31.000000000 -0400
@@ -13,7 +13,7 @@
 
 #include <linux/types.h>
 
-typedef struct { volatile int counter; } atomic_t;
+typedef struct { int counter; } atomic_t;
 
 #ifdef __KERNEL__
 
@@ -61,7 +61,11 @@ extern int atomic_cmpxchg(atomic_t *, in
 extern int atomic_add_unless(atomic_t *, int, int);
 extern void atomic_set(atomic_t *, int);
 
-#define atomic_read(v)          ((v)->counter)
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
+#define atomic_read(v)          (*(volatile int *)&(v)->counter)
 
 #define atomic_add(i, v)	((void)__atomic_add_return( (int)(i), (v)))
 #define atomic_sub(i, v)	((void)__atomic_add_return(-(int)(i), (v)))
