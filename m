From: akpm@linux-foundation.org
Subject: [patch 08/11] nsc-ircc: default to dongle type 9 on IBM hardware
Date: Wed, 30 Jul 2008 12:37:40 -0700
Message-ID: <200807301937.m6UJbfsn012452@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	mjg59@srcf.ucam.org, ben.collins@canonical.com, samuel@sortiz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59991 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbYG3TxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:53:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Garrett <mjg59@srcf.ucam.org>

This is necessary to set the dongle type on the nsc driver in order to get
it to work correctly.  Thinkpads all appear to use dongle type 9.  This
patch defaults nsc devices with an IBM PnP descriptor to use type 9.

Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Matthew Garrett <mjg59@srcf.ucam.org>
Signed-off-by: Ben Collins <ben.collins@canonical.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/nsc-ircc.c |    7 +++++--
 drivers/net/irda/nsc-ircc.h |    3 +++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff -puN drivers/net/irda/nsc-ircc.c~nsc-ircc-default-to-dongle-type-9-on-ibm-hardware drivers/net/irda/nsc-ircc.c
--- a/drivers/net/irda/nsc-ircc.c~nsc-ircc-default-to-dongle-type-9-on-ibm-hardware
+++ a/drivers/net/irda/nsc-ircc.c
@@ -151,8 +151,8 @@ static char *dongle_types[] = {
 static chipio_t pnp_info;
 static const struct pnp_device_id nsc_ircc_pnp_table[] = {
 	{ .id = "NSC6001", .driver_data = 0 },
-	{ .id = "IBM0071", .driver_data = 0 },
 	{ .id = "HWPC224", .driver_data = 0 },
+	{ .id = "IBM0071", .driver_data = NSC_FORCE_DONGLE_TYPE9 },
 	{ }
 };
 
@@ -930,7 +930,10 @@ static int nsc_ircc_pnp_probe(struct pnp
 	pnp_info.dma = -1;
 	pnp_succeeded = 1;
 
-	/* There don't seem to be any way to get the cfg_base.
+	if (id->driver_data & NSC_FORCE_DONGLE_TYPE9)
+		dongle_id = 0x9;
+
+	/* There doesn't seem to be any way of getting the cfg_base.
 	 * On my box, cfg_base is in the PnP descriptor of the
 	 * motherboard. Oh well... Jean II */
 
diff -puN drivers/net/irda/nsc-ircc.h~nsc-ircc-default-to-dongle-type-9-on-ibm-hardware drivers/net/irda/nsc-ircc.h
--- a/drivers/net/irda/nsc-ircc.h~nsc-ircc-default-to-dongle-type-9-on-ibm-hardware
+++ a/drivers/net/irda/nsc-ircc.h
@@ -35,6 +35,9 @@
 #include <linux/types.h>
 #include <asm/io.h>
 
+/* Features for chips (set in driver_data) */
+#define NSC_FORCE_DONGLE_TYPE9	0x00000001
+
 /* DMA modes needed */
 #define DMA_TX_MODE     0x08    /* Mem to I/O, ++, demand. */
 #define DMA_RX_MODE     0x04    /* I/O to mem, ++, demand. */
_
