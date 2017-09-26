From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix format truncation warning reported by
 gcc 7.1.1
Date: Tue, 26 Sep 2017 11:48:27 -0700
Message-ID: <20170926184827.GA3512@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0059.outbound.protection.outlook.com ([104.47.37.59]:59643
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754339AbdIZSsb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 14:48:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

gcc 7.1.1 with -Wformat-truncation reports these warnings:

drivers/net/ethernet/cavium/liquidio/lio_core.c: In function `octeon_setup_interrupt':
drivers/net/ethernet/cavium/liquidio/lio_core.c:1003:41: warning: `%u' directive output may be truncated writing between 1 and 10 bytes into a region of size between 0 and 13 [-Wformat-truncation=]
       INTRNAMSIZ, "LiquidIO%u-pf%u-rxtx-%u",
                                         ^~
drivers/net/ethernet/cavium/liquidio/lio_core.c:1003:19: note: directive argument in the range [0, 2147483647]
       INTRNAMSIZ, "LiquidIO%u-pf%u-rxtx-%u",
                   ^~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/cavium/liquidio/lio_core.c:1002:5: note: `snprintf' output between 21 and 43 bytes into a destination of size 32
     snprintf(&queue_irq_names[IRQ_NAME_OFF(i)],
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       INTRNAMSIZ, "LiquidIO%u-pf%u-rxtx-%u",
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       oct->octeon_id, oct->pf_num, i);
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/cavium/liquidio/lio_core.c:1008:41: warning: `%u' directive output may be truncated writing between 1 and 10 bytes into a region of size between 0 and 13 [-Wformat-truncation=]
       INTRNAMSIZ, "LiquidIO%u-vf%u-rxtx-%u",
                                         ^~
drivers/net/ethernet/cavium/liquidio/lio_core.c:1008:19: note: directive argument in the range [0, 2147483647]
       INTRNAMSIZ, "LiquidIO%u-vf%u-rxtx-%u",
                   ^~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/cavium/liquidio/lio_core.c:1007:5: note: `snprintf' output between 21 and 43 bytes into a destination of size 32
     snprintf(&queue_irq_names[IRQ_NAME_OFF(i)],
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       INTRNAMSIZ, "LiquidIO%u-vf%u-rxtx-%u",
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       oct->octeon_id, oct->vf_num, i);
       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Fix them by changing the type of the "i" local variable from int to short.

Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 23f6b60..55c5d44 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -899,11 +899,12 @@ int octeon_setup_interrupt(struct octeon_device *oct, u32 num_ioqs)
 {
 	struct msix_entry *msix_entries;
 	char *queue_irq_names = NULL;
-	int i, num_interrupts = 0;
+	int num_interrupts = 0;
 	int num_alloc_ioq_vectors;
 	char *aux_irq_name = NULL;
 	int num_ioq_vectors;
 	int irqret, err;
+	short i;
 
 	oct->num_msix_irqs = num_ioqs;
 	if (oct->msix_on) {
