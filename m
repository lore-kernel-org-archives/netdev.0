From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/1] bnx2x: Force fundamental reset for EEH recovery
Date: Wed, 04 Mar 2015 08:09:44 -0600
Message-ID: <201503041410.t24EAAix006027@d03av03.boulder.ibm.com>
Cc: netdev@vger.kernel.org, cascardo@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com, stable@vger.kernel.org
To: ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:48403 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706AbbCDOKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 09:10:48 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brking@linux.vnet.ibm.com>;
	Wed, 4 Mar 2015 07:10:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


EEH recovery for bnx2x based adapters is not reliable on all Power
systems using the default hot reset, which can result in an
unrecoverable EEH error. Forcing the use of fundamental reset
during EEH recovery fixes this.

Cc: stable<stable@vger.kernel.org>
Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c~bnx2x_needs_freset drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
--- linux/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c~bnx2x_needs_freset	2015-03-03 08:46:09.281961703 -0600
+++ linux-bjking1/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	2015-03-03 08:46:09.287961639 -0600
@@ -12722,6 +12722,9 @@ static int bnx2x_init_dev(struct bnx2x *
 	pci_write_config_dword(bp->pdev, PCICFG_GRC_ADDRESS,
 			       PCICFG_VENDOR_ID_OFFSET);
 
+	/* Set PCIe reset type to fundamental for EEH recovery */
+	pdev->needs_freset = 1;
+
 	/* AER (Advanced Error reporting) configuration */
 	rc = pci_enable_pcie_error_reporting(pdev);
 	if (!rc)
_
