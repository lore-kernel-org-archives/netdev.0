From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 03/10] bna: Fix ethtool register dump and reordered an API
Date: Tue, 21 Dec 2010 23:23:09 -0800
Message-ID: <1293002596-3239-4-git-send-email-rmody@brocade.com>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54134 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752128Ab0LVHn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 02:43:26 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBM7ML8u021240
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:21 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0b-000f0801.pphosted.com with ESMTP id tb71ag48e-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:21 -0800
In-Reply-To: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
	- Removed semaphore register dump from ethtool
	- Moved netif_carrier_off() call to before calling bna_init()

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c         |    8 +++-----
 drivers/net/bna/bnad_ethtool.c |    4 ----
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 7bf7977..348ebf9 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -3061,6 +3061,9 @@ bnad_pci_probe(struct pci_dev *pdev,
 	/* Initialize netdev structure, set up ethtool ops */
 	bnad_netdev_init(bnad, using_dac);
 
+	/* Set link to down state */
+	netif_carrier_off(netdev);
+
 	bnad_enable_msix(bnad);
 
 	/* Get resource requirement form bna */
@@ -3114,11 +3117,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 	mutex_unlock(&bnad->conf_mutex);
 
-	/*
-	 * Make sure the link appears down to the stack
-	 */
-	netif_carrier_off(netdev);
-
 	/* Finally, reguister with net_device layer */
 	err = register_netdev(netdev);
 	if (err) {
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_ethtool.c
index 11fa2ea..3011110 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -330,10 +330,6 @@ do {								\
 
 	BNAD_GET_REG(PCIE_MISC_REG);
 
-	BNAD_GET_REG(HOST_SEM0_REG);
-	BNAD_GET_REG(HOST_SEM1_REG);
-	BNAD_GET_REG(HOST_SEM2_REG);
-	BNAD_GET_REG(HOST_SEM3_REG);
 	BNAD_GET_REG(HOST_SEM0_INFO_REG);
 	BNAD_GET_REG(HOST_SEM1_INFO_REG);
 	BNAD_GET_REG(HOST_SEM2_INFO_REG);
-- 
1.7.1

