From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 1/3] be2net: Disabling and enabling interrupts in suspend
 and resume
Date: Fri, 22 Nov 2013 12:51:09 -0600
Message-ID: <20131122185109.GA4148@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:34635 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab3KVSvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 13:51:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interrupts need to be enabled in be_resume, when adapter boots back up from D3cold.

disabling interrupts in be_suspend() just to be symmetric to be_resume().

Signed-off-by: Ravikumar Nelavelli <ravikumar.nelavelli@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index abde974..9b148cf 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4599,6 +4599,7 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (adapter->wol)
 		be_setup_wol(adapter, true);
 
+	be_intr_set(adapter, false);
 	cancel_delayed_work_sync(&adapter->func_recovery_work);
 
 	netif_device_detach(netdev);
@@ -4634,6 +4635,7 @@ static int be_resume(struct pci_dev *pdev)
 	if (status)
 		return status;
 
+	be_intr_set(adapter, true);
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
 	if (status)
-- 
1.8.1.2
