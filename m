From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net:Creating/destroying queues regardless
	of netif_running() in suspend/resume path
Date: Thu, 13 Aug 2009 12:31:29 +0530
Message-ID: <20090813070119.GA28043@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:58543 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753148AbZHMHB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 03:01:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: sarveshwarb <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 2db879c..45507d8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1972,9 +1972,9 @@ static int be_suspend(struct pci_dev *pd
 	if (netif_running(netdev)) {
 		rtnl_lock();
 		be_close(netdev);
-		be_clear(adapter);
 		rtnl_unlock();
 	}
+	be_clear(adapter);
 
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
@@ -1997,9 +1997,9 @@ static int be_resume(struct pci_dev *pde
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
 
+	be_setup(adapter);
 	if (netif_running(netdev)) {
 		rtnl_lock();
-		be_setup(adapter);
 		be_open(netdev);
 		rtnl_unlock();
 	}
-- 
1.4.0

