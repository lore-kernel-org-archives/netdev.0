From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 22/24] make atomic_read() behave consistently on x86_64
Date: Thu, 9 Aug 2007 10:18:59 -0400
Message-ID: <20070809141859.GA19381@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:56207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765537AbXHIOTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:19:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Make atomic_read() consistent with atomic64_read() and other architectures
on x86_64.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-x86_64/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-x86_64/atomic.h	2007-08-09 07:51:40.000000000 -0400
@@ -32,7 +32,7 @@ typedef struct { int counter; } atomic_t
  * 
  * Atomically reads the value of @v.
  */ 
-#define atomic_read(v)		((v)->counter)
+#define atomic_read(v)		(*(volatile int *)&(v)->counter)
 
 /**
  * atomic_set - set atomic variable
@@ -206,7 +206,7 @@ static __inline__ int atomic_sub_return(
 
 /* An 64bit atomic type */
 
-typedef struct { volatile long counter; } atomic64_t;
+typedef struct { long counter; } atomic64_t;
 
 #define ATOMIC64_INIT(i)	{ (i) }
 
@@ -217,7 +217,7 @@ typedef struct { volatile long counter; 
  * Atomically reads the value of @v.
  * Doesn't imply a read memory barrier.
  */
-#define atomic64_read(v)		((v)->counter)
+#define atomic64_read(v)		(*(volatile long *)&(v)->counter)
 
 /**
  * atomic64_set - set atomic64 variable
