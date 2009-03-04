From: akpm@linux-foundation.org
Subject: [patch 1/1] sfc: modify allocation error message
Date: Wed, 04 Mar 2009 12:03:10 -0800
Message-ID: <200903042003.n24K3BaX028938@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, travis@sgi.com,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43396 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758199AbZCDUDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 15:03:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Travis <travis@sgi.com>

Change error message when alloc_cpumask_var fails.

Signed-off-by: Mike Travis <travis@sgi.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sfc/efx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/sfc/efx.c~sfc-modify-allocation-error-message drivers/net/sfc/efx.c
--- a/drivers/net/sfc/efx.c~sfc-modify-allocation-error-message
+++ a/drivers/net/sfc/efx.c
@@ -857,9 +857,9 @@ static int efx_wanted_rx_queues(void)
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
