From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 2/4] be2net: fix wrong handling of be_setup() failure in be_probe()
Date: Fri, 28 Sep 2012 20:09:42 +0530
Message-ID: <b02d091e-153e-4d6a-b767-158394d0d990@CMEXHTCAS2.ad.emulex.com>
References: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49344 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758437Ab2I1PD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 11:03:28 -0400
In-Reply-To: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fa17430..b712091 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3889,7 +3889,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 	status = be_setup(adapter);
 	if (status)
-		goto msix_disable;
+		goto stats_clean;
 
 	be_netdev_init(netdev);
 	status = register_netdev(netdev);
@@ -3910,8 +3910,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 unsetup:
 	be_clear(adapter);
-msix_disable:
-	be_msix_disable(adapter);
 stats_clean:
 	be_stats_cleanup(adapter);
 ctrl_clean:
-- 
1.7.4
