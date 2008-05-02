From: akpm@linux-foundation.org
Subject: [patch 2/2] nsc-ircc: wrap PNP probe code in #ifdef CONFIG_PNP
Date: Fri, 02 May 2008 13:40:24 -0700
Message-ID: <200805022040.m42KeOP9013649@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	bjorn.helgaas@hp.com, kamalesh@linux.vnet.ibm.com,
	sfr@canb.auug.org.au
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41598 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936876AbYEBUqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:46:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bjorn.helgaas@hp.com>

Wrap PNP probe code in #ifdef CONFIG_PNP.

Without this change, we'll have unresolved references to pnp_get_resource()
function when CONFIG_PNP=n.  (This is a new interface that's not in mainline
yet.)

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/nsc-ircc.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff -puN drivers/net/irda/nsc-ircc.c~nsc-ircc-wrap-pnp-probe-code-in-ifdef-config_pnp drivers/net/irda/nsc-ircc.c
--- a/drivers/net/irda/nsc-ircc.c~nsc-ircc-wrap-pnp-probe-code-in-ifdef-config_pnp
+++ a/drivers/net/irda/nsc-ircc.c
@@ -100,7 +100,6 @@ static int nsc_ircc_probe_39x(nsc_chip_t
 static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info);
 static int nsc_ircc_init_338(nsc_chip_t *chip, chipio_t *info);
 static int nsc_ircc_init_39x(nsc_chip_t *chip, chipio_t *info);
-static int nsc_ircc_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *id);
 
 /* These are the known NSC chips */
 static nsc_chip_t chips[] = {
@@ -145,8 +144,10 @@ static char *dongle_types[] = {
 	"No dongle connected",
 };
 
-/* PNP probing */
 static chipio_t pnp_info;
+
+#ifdef CONFIG_PNP
+/* PNP probing */
 static const struct pnp_device_id nsc_ircc_pnp_table[] = {
 	{ .id = "NSC6001", .driver_data = 0 },
 	{ .id = "IBM0071", .driver_data = 0 },
@@ -155,11 +156,16 @@ static const struct pnp_device_id nsc_ir
 
 MODULE_DEVICE_TABLE(pnp, nsc_ircc_pnp_table);
 
+static int nsc_ircc_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *id);
+
 static struct pnp_driver nsc_ircc_pnp_driver = {
 	.name = "nsc-ircc",
 	.id_table = nsc_ircc_pnp_table,
 	.probe = nsc_ircc_pnp_probe,
 };
+#else
+static struct pnp_driver nsc_ircc_pnp_driver;
+#endif
 
 /* Some prototypes */
 static int  nsc_ircc_open(chipio_t *info);
@@ -916,6 +922,7 @@ static int nsc_ircc_probe_39x(nsc_chip_t
 	return 0;
 }
 
+#ifdef CONFIG_PNP
 /* PNP probing */
 static int nsc_ircc_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *id)
 {
@@ -952,6 +959,7 @@ static int nsc_ircc_pnp_probe(struct pnp
 
 	return 0;
 }
+#endif
 
 /*
  * Function nsc_ircc_setup (info)
_
