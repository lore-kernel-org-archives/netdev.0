From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 2/5] be2net: fix wrong handling of be_setup() failure in be_probe()
Date: Thu, 27 Sep 2012 12:02:45 +0530
Message-ID: <0aba9ebf-548b-4c2c-a165-f13eb73dc05d@CMEXHTCAS2.ad.emulex.com>
References: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52733 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab2I0G4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 02:56:24 -0400
In-Reply-To: <1348727568-2011-1-git-send-email-sathya.perla@emulex.com>
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
