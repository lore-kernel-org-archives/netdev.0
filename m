From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: sfc fixup patch
Date: Mon, 23 Mar 2015 14:10:32 +1100
Message-ID: <1427080232.4770.212.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51731 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbbCWDKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 23:10:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Shradha !

While merging some EEH changes, I noticed a breakage in the SFC driver
due to it using an API we didn't mean driver to use directly and that
is going away. I've done this small fixup patch, any objection to me
sticking it in the original series (as to avoid bisection breaks)
before I send it to Linus ?

Cheers,
Ben.

net/ethernet/sfc: Don't use of_node_to_eeh_dev()

This is deprecated, it forces the driver to hop via the OF node
that may or may not exist, instead use pci_dev_to_eeh_dev() which
is simpler.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/sfc/efx.c   | 4 +---
 drivers/net/ethernet/sfc/siena.c | 3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 2384824..77d6453 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2523,9 +2523,7 @@ int efx_try_recovery(struct efx_nic *efx)
 	 * schedule a 'recover or reset', leading to this recovery handler.
 	 * Manually call the eeh failure check function.
 	 */
-	struct eeh_dev *eehdev =
-		of_node_to_eeh_dev(pci_device_to_OF_node(efx->pci_dev));
-
+	struct eeh_dev *eehdev = pci_dev_to_eeh_dev(efx->pci_dev);
 	if (eeh_dev_check_failure(eehdev)) {
 		/* The EEH mechanisms will handle the error and reset the
 		 * device if necessary.
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 3583f02..f12c811 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -205,8 +205,7 @@ static int siena_map_reset_flags(u32 *flags)
  */
 static void siena_monitor(struct efx_nic *efx)
 {
-	struct eeh_dev *eehdev =
-		of_node_to_eeh_dev(pci_device_to_OF_node(efx->pci_dev));
+	struct eeh_dev *eehdev = pci_dev_to_eeh_dev(efx->pci_dev);
 
 	eeh_dev_check_failure(eehdev);
 }
