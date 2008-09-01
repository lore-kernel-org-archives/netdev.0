From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 33/52] sfc: Remove efx_nic_dummy_op_int() as redundant with efx_port_dummy_op_int()
Date: Mon, 1 Sep 2008 12:48:36 +0100
Message-ID: <20080901114835.GA7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:33882 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758720AbYIALsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:38 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update comment on the dummy operation implementations.

Line up the board operation initialisers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5a0494a..c41035a 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1774,7 +1774,7 @@ static struct pci_device_id efx_pci_table[] __devinitdata = {
  *
  * Dummy PHY/MAC/Board operations
  *
- * Can be used where the MAC does not implement this operation
+ * Can be used for some unimplemented operations
  * Needed so all function pointers are valid and do not have to be tested
  * before use
  *
@@ -1795,17 +1795,12 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 	.reset_xaui      = efx_port_dummy_op_void,
 };
 
-/* Dummy board operations */
-static int efx_nic_dummy_op_int(struct efx_nic *nic)
-{
-	return 0;
-}
-
 static struct efx_board efx_dummy_board_info = {
-	.init    = efx_nic_dummy_op_int,
-	.init_leds = efx_port_dummy_op_int,
-	.set_fault_led = efx_port_dummy_op_blink,
-	.fini	= efx_port_dummy_op_void,
+	.init		= efx_port_dummy_op_int,
+	.init_leds	= efx_port_dummy_op_int,
+	.set_fault_led	= efx_port_dummy_op_blink,
+	.blink		= efx_port_dummy_op_blink,
+	.fini		= efx_port_dummy_op_void,
 };
 
 /**************************************************************************
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

