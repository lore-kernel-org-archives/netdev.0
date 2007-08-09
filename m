From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 10/24] make atomic_read() behave consistently on m32r
Date: Thu, 9 Aug 2007 09:53:48 -0400
Message-ID: <20070809135348.GA16389@shell.boston.redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:47348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791AbXHINyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 09:54:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Purify volatile use for atomic_t on m32r.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- linux-2.6.23-rc2-orig/include/asm-m32r/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-m32r/atomic.h	2007-08-09 06:55:53.000000000 -0400
@@ -22,7 +22,7 @@
  * on us. We need to use _exactly_ the address the user gave us,
  * not some alias that contains the same information.
  */
-typedef struct { volatile int counter; } atomic_t;
+typedef struct { int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)	{ (i) }
 
@@ -32,7 +32,7 @@ typedef struct { volatile int counter; }
  *
  * Atomically reads the value of @v.
  */
-#define atomic_read(v)	((v)->counter)
+#define atomic_read(v)	(*(volatile int *)&(v)->counter)
 
 /**
  * atomic_set - set atomic variable
