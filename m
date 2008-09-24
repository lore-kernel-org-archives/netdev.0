From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 3/4] enic: Bug fix: Free MSI intr with correct data handle
Date: Wed, 24 Sep 2008 11:23:42 -0700
Message-ID: <20080924182342.22778.94916.stgit@palito_client100.nuovasystems.com>
References: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:22077 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867AbYIXSYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 14:24:33 -0400
In-Reply-To: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: Bug fix: Free MSI intr with correct data handle

Bug fix: Free MSI intr with correct data handle
Use davem proposed naming for MSI-X tx/rx vectors (ethX-tx-0, ethX-rx-0)

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index c741bbf..14e59a7 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1134,9 +1134,11 @@ static void enic_free_intr(struct enic *enic)
 
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	case VNIC_DEV_INTR_MODE_INTX:
-	case VNIC_DEV_INTR_MODE_MSI:
 		free_irq(enic->pdev->irq, netdev);
 		break;
+	case VNIC_DEV_INTR_MODE_MSI:
+		free_irq(enic->pdev->irq, enic);
+		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
 		for (i = 0; i < ARRAY_SIZE(enic->msix); i++)
 			if (enic->msix[i].requested)
@@ -1171,12 +1173,12 @@ static int enic_request_intr(struct enic *enic)
 	case VNIC_DEV_INTR_MODE_MSIX:
 
 		sprintf(enic->msix[ENIC_MSIX_RQ].devname,
-			"%.11s-rx", netdev->name);
+			"%.11s-rx-0", netdev->name);
 		enic->msix[ENIC_MSIX_RQ].isr = enic_isr_msix_rq;
 		enic->msix[ENIC_MSIX_RQ].devid = enic;
 
 		sprintf(enic->msix[ENIC_MSIX_WQ].devname,
-			"%.11s-tx", netdev->name);
+			"%.11s-tx-0", netdev->name);
 		enic->msix[ENIC_MSIX_WQ].isr = enic_isr_msix_wq;
 		enic->msix[ENIC_MSIX_WQ].devid = enic;
 

