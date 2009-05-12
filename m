From: akpm@linux-foundation.org
Subject: [patch 1/2] sfc: modify allocation error message
Date: Tue, 12 May 2009 13:48:36 -0700
Message-ID: <200905122107.n4CL7p7c010639@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, travis@sgi.com,
	bhutchings@solarflare.com, mingo@elte.hu, rusty@rustcorp.com.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60289 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753235AbZELVMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 17:12:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Travis <travis@sgi.com>

Change error message when alloc_cpumask_var fails.

Repairs "cpumask: convert drivers/net/sfc".

Signed-off-by: Mike Travis <travis@sgi.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
Acked-by: David S. Miller <davem@davemloft.net>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sfc/efx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/sfc/efx.c~sfc-modify-allocation-error-message drivers/net/sfc/efx.c
--- a/drivers/net/sfc/efx.c~sfc-modify-allocation-error-message
+++ a/drivers/net/sfc/efx.c
@@ -894,9 +894,9 @@ static int efx_wanted_rx_queues(void)
 	int count;
 	int cpu;
 
-	if (!alloc_cpumask_var(&core_mask, GFP_KERNEL)) {
+	if (unlikely(!alloc_cpumask_var(&core_mask, GFP_KERNEL))) {
 		printk(KERN_WARNING
-		       "efx.c: allocation failure, irq balancing hobbled\n");
+		       "sfc: RSS disabled due to allocation failure\n");
 		return 1;
 	}
 
_
