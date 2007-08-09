From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 19/24] make atomic_read() behave consistently on sparc64
Date: Thu, 9 Aug 2007 10:12:05 -0400
Message-ID: <20070809141205.GA18672@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:54325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S940399AbXHIOMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:12:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic[64]_t on sparc64.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-sparc64/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-sparc64/atomic.h	2007-08-09 07:48:01.000000000 -0400
@@ -11,14 +11,18 @@
 #include <linux/types.h>
 #include <asm/system.h>
 
-typedef struct { volatile int counter; } atomic_t;
-typedef struct { volatile __s64 counter; } atomic64_t;
+typedef struct { int counter; } atomic_t;
+typedef struct { __s64 counter; } atomic64_t;
 
 #define ATOMIC_INIT(i)		{ (i) }
 #define ATOMIC64_INIT(i)	{ (i) }
 
-#define atomic_read(v)		((v)->counter)
-#define atomic64_read(v)	((v)->counter)
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
+#define atomic_read(v)		(*(volatile int *)&(v)->counter)
+#define atomic64_read(v)	(*(volatile __s64 *)&(v)->counter)
 
 #define atomic_set(v, i)	(((v)->counter) = i)
 #define atomic64_set(v, i)	(((v)->counter) = i)
