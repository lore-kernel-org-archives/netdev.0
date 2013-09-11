From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 2/2] tg3: Use pci_dev pm_cap
Date: Wed, 11 Sep 2013 11:22:40 -0700
Message-ID: <1378923760-16232-2-git-send-email-jdmason@kudzu.us>
References: <1378923760-16232-1-git-send-email-jdmason@kudzu.us>
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:55251 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070Ab3IKSV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:21:28 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so9362970pbc.21
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:21:28 -0700 (PDT)
In-Reply-To: <1378923760-16232-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the already existing pm_cap variable in struct pci_dev for
determining the power management offset.  This saves the driver from
having to keep track of an extra variable.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    5 ++---
 drivers/net/ethernet/broadcom/tg3.h |    1 -
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 5701f3d..938e05c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -16192,12 +16192,12 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 			 * So explicitly force the chip into D0 here.
 			 */
 			pci_read_config_dword(tp->pdev,
-					      tp->pm_cap + PCI_PM_CTRL,
+					      tp->pdev->pm_cap + PCI_PM_CTRL,
 					      &pm_reg);
 			pm_reg &= ~PCI_PM_CTRL_STATE_MASK;
 			pm_reg |= PCI_PM_CTRL_PME_ENABLE | 0 /* D0 */;
 			pci_write_config_dword(tp->pdev,
-					       tp->pm_cap + PCI_PM_CTRL,
+					       tp->pdev->pm_cap + PCI_PM_CTRL,
 					       pm_reg);
 
 			/* Also, force SERR#/PERR# in PCI command. */
@@ -17346,7 +17346,6 @@ static int tg3_init_one(struct pci_dev *pdev,
 	tp = netdev_priv(dev);
 	tp->pdev = pdev;
 	tp->dev = dev;
-	tp->pm_cap = pdev->pm_cap;
 	tp->rx_mode = TG3_DEF_RX_MODE;
 	tp->tx_mode = TG3_DEF_TX_MODE;
 	tp->irq_sync = 1;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index ddb8be1..7025780 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3234,7 +3234,6 @@ struct tg3 {
 	u8				pci_lat_timer;
 
 	int				pci_fn;
-	int				pm_cap;
 	int				msi_cap;
 	int				pcix_cap;
 	int				pcie_readrq;
-- 
1.7.10.4
