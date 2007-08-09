From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 2/24] make atomic_read() behave consistently on arm
Date: Thu, 9 Aug 2007 09:30:28 -0400
Message-ID: <20070809133028.GA13241@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:38745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935578AbXHINbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 09:31:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic_t on arm.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-arm/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-arm/atomic.h	2007-08-09 06:30:40.000000000 -0400
@@ -14,13 +14,17 @@
 #include <linux/compiler.h>
 #include <asm/system.h>
 
-typedef struct { volatile int counter; } atomic_t;
+typedef struct { int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)	{ (i) }
 
 #ifdef __KERNEL__
 
-#define atomic_read(v)	((v)->counter)
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
+#define atomic_read(v)	(*(volatile int *)&(v)->counter)
 
 #if __LINUX_ARM_ARCH__ >= 6
 
