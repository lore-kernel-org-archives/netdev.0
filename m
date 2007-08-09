From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 16/24] make atomic_read() behave consistently on s390
Date: Thu, 9 Aug 2007 10:06:55 -0400
Message-ID: <20070809140655.GA17731@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:52284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938318AbXHIOHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:07:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Make atomic[64]_read() volatile on s390, to ensure memory is actually read
each time.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-s390/atomic.h	2007-08-08 17:48:53.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-s390/atomic.h	2007-08-09 07:18:56.000000000 -0400
@@ -67,7 +67,11 @@ typedef struct {
 
 #endif /* __GNUC__ */
 
-#define atomic_read(v)          ((v)->counter)
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
+#define atomic_read(v)          (*(volatile int *)&(v)->counter)
 #define atomic_set(v,i)         (((v)->counter) = (i))
 
 static __inline__ int atomic_add_return(int i, atomic_t * v)
@@ -182,7 +186,7 @@ typedef struct {
 
 #endif /* __GNUC__ */
 
-#define atomic64_read(v)          ((v)->counter)
+#define atomic64_read(v)          (*(volatile long long *)&(v)->counter)
 #define atomic64_set(v,i)         (((v)->counter) = (i))
 
 static __inline__ long long atomic64_add_return(long long i, atomic64_t * v)
