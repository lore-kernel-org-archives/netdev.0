From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 5/5] be2net: call FLR after setup wol in
 be_shutdown
Date: Wed, 6 Apr 2011 23:08:43 -0500
Message-ID: <20110407040843.GA4247@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55059 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751052Ab1DGEJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:09:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling setup_wol after a reset is inconsequential.
The WOL setting should be programmed before FLR.
And yes, FLR does not erase wol information.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 6a43b26..a7a2dec 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3188,11 +3188,11 @@ static void be_shutdown(struct pci_dev *pdev)
 
 	netif_device_detach(netdev);
 
-	be_cmd_reset_function(adapter);
-
 	if (adapter->wol)
 		be_setup_wol(adapter, true);
 
+	be_cmd_reset_function(adapter);
+
 	pci_disable_device(pdev);
 }
 
-- 
1.7.1

