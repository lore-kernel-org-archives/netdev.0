From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Thu, 9 Aug 2007 09:41:50 -0400
Message-ID: <20070809134150.GA14890@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:43122 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758447AbXHINm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 09:42:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Make atomic_read() volatile on frv.  This ensures that busy-waiting
for an interrupt handler to change an atomic_t won't get compiled to an
infinite loop, consistent with SMP architectures.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-frv/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-frv/atomic.h	2007-08-09 06:41:48.000000000 -0400
@@ -40,7 +40,12 @@ typedef struct {
 } atomic_t;
 
 #define ATOMIC_INIT(i)		{ (i) }
-#define atomic_read(v)		((v)->counter)
+
+/*
+ * Casting to volatile here minimizes the need for barriers,
+ * without having to declare the type itself as volatile.
+ */
+#define atomic_read(v)		(*(volatile int *)&(v)->counter)
 #define atomic_set(v, i)	(((v)->counter) = (i))
 
 #ifndef CONFIG_FRV_OUTOFLINE_ATOMIC_OPS
