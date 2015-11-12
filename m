From: Pavel Fedin <p.fedin@samsung.com>
Subject: [PATCH] net: thunder: Fix crash upon shutdown after failed probe
Date: Thu, 12 Nov 2015 14:55:18 +0300
Message-ID: <1447329318-7840-1-git-send-email-p.fedin@samsung.com>
Cc: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>, youngmin.lee@cavium.com,
	kin-yip.liu@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.w1.samsung.com ([210.118.77.13]:52231 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbbKLLza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 06:55:30 -0500
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NXP00IXCAGG2A30@mailout3.w1.samsung.com> for
 netdev@vger.kernel.org; Thu, 12 Nov 2015 11:55:28 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device probe fails, driver remains bound to the PCI device. However,
driver data has been reset to NULL. This causes crash upon dereferencing
it in nicvf_remove()

Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index a937772..372c39e 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1600,6 +1600,9 @@ static void nicvf_remove(struct pci_dev *pdev)
 
 static void nicvf_shutdown(struct pci_dev *pdev)
 {
+	if (!pci_get_drvdata(pdev))
+		return;
+
 	nicvf_remove(pdev);
 }
 
-- 
2.4.4
