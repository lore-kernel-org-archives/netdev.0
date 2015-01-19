From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] s2io: use snprintf() as a safety feature
Date: Mon, 19 Jan 2015 22:34:51 +0300
Message-ID: <20150119193451.GB32634@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35361 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbASTeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 14:34:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"sp->desc[i]" has 25 characters.  "dev->name" has 15 characters.  If we
used all 15 characters then the sprintf() would overflow.

I changed the "sprintf(sp->name, "%s Neterion %s"" to snprintf(), as
well, even though it can't overflow just to be consistent.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This driver is quite old.

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
 0529cad..a4cdf2f 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -6987,7 +6987,9 @@ static int s2io_add_isr(struct s2io_nic *sp)
 			if (sp->s2io_entries[i].in_use == MSIX_FLG) {
 				if (sp->s2io_entries[i].type ==
 				    MSIX_RING_TYPE) {
-					sprintf(sp->desc[i], "%s:MSI-X-%d-RX",
+					snprintf(sp->desc[i],
+						sizeof(sp->desc[i]),
+						"%s:MSI-X-%d-RX",
 						dev->name, i);
 					err = request_irq(sp->entries[i].vector,
 							  s2io_msix_ring_handle,
@@ -6996,7 +6998,9 @@ static int s2io_add_isr(struct s2io_nic *sp)
 							  sp->s2io_entries[i].arg);
 				} else if (sp->s2io_entries[i].type ==
 					   MSIX_ALARM_TYPE) {
-					sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
+					snprintf(sp->desc[i],
+						sizeof(sp->desc[i]),
+						"%s:MSI-X-%d-TX",
 						dev->name, i);
 					err = request_irq(sp->entries[i].vector,
 							  s2io_msix_fifo_handle,
@@ -8154,7 +8158,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 			  "%s: UDP Fragmentation Offload(UFO) enabled\n",
 			  dev->name);
 	/* Initialize device name */
-	sprintf(sp->name, "%s Neterion %s", dev->name, sp->product_name);
+	snprintf(sp->name, sizeof(sp->name), "%s Neterion %s", dev->name,
+		 sp->product_name);
 
 	if (vlan_tag_strip)
 		sp->vlan_strip_flag = 1;
