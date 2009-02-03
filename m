From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH 1/1 net-next] s2io: Formatting log message
Date: Tue, 03 Feb 2009 10:39:35 -0200
Message-ID: <49883B07.9030009@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: sreenivasa.honnur@neterion.com, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:55503 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbZBCMjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 07:39:43 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp03.br.ibm.com (8.13.1/8.13.1) with ESMTP id n13CcQv6026256
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 10:38:26 -0200
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n13Dd46D3682476
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 10:39:05 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n13CdaHW030848
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 10:39:36 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

S2IO driver is printing dev->name before the name being allocated, which
display eth%d instead of eth0, eth1, etc. Example: 

eth%d: Enabling MSIX failed
eth%d: MSI-X requested but failed to enable

This patch just change eth%d to s2io.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

---

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index f5c57c0..a63a496 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3862,7 +3862,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	ret = pci_enable_msix(nic->pdev, nic->entries, nic->num_entries);
 	/* We fail init if error or we get less vectors than min required */
 	if (ret) {
-		DBG_PRINT(ERR_DBG, "%s: Enabling MSIX failed\n", nic->dev->name);
+		DBG_PRINT(ERR_DBG, "s2io: Enabling MSI-X failed\n");
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
 			+= (nic->num_entries * sizeof(struct msix_entry));
@@ -8009,8 +8009,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		if (ret) {
 
 			DBG_PRINT(ERR_DBG,
-			  "%s: MSI-X requested but failed to enable\n",
-			  dev->name);
+			  "s2io: MSI-X requested but failed to enable\n");
 			sp->config.intr_type = INTA;
 		}
 	}
