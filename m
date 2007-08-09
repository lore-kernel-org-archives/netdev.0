From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 13/24] make atomic_read() behave consistently on mips
Date: Thu, 9 Aug 2007 10:00:04 -0400
Message-ID: <20070809140004.GA17112@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:49731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934050AbXHIOAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:00:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic[64]_t on mips.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-mips/atomic.h	2007-08-08 17:48:53.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-mips/atomic.h	2007-08-09 07:02:50.000000000 -0400
@@ -20,7 +20,7 @@
 #include <asm/war.h>
 #include <asm/system.h>
 
-typedef struct { volatile int counter; } atomic_t;
+typedef struct { int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)    { (i) }
 
@@ -30,7 +30,7 @@ typedef struct { volatile int counter; }
  *
  * Atomically reads the value of @v.
  */
-#define atomic_read(v)		((v)->counter)
+#define atomic_read(v)		(*(volatile int *)&(v)->counter)
 
 /*
  * atomic_set - set atomic variable
@@ -404,7 +404,7 @@ static __inline__ int atomic_add_unless(
 
 #ifdef CONFIG_64BIT
 
-typedef struct { volatile long counter; } atomic64_t;
+typedef struct { long counter; } atomic64_t;
 
 #define ATOMIC64_INIT(i)    { (i) }
 
@@ -413,7 +413,7 @@ typedef struct { volatile long counter; 
  * @v: pointer of type atomic64_t
  *
  */
-#define atomic64_read(v)	((v)->counter)
+#define atomic64_read(v)	(*(volatile long *)&(v)->counter)
 
 /*
  * atomic64_set - set atomic variable
