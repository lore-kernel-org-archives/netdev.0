From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 5/6] be2net: cancel be_worker() in be_shutdown() even when i/f is down
Date: Fri, 18 Mar 2011 18:51:01 +0530
Message-ID: <9cae7c88-bf0c-492e-ab6e-9f842e75b2b3@exht1.ad.emulex.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-3-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-4-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-5-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:9939 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756546Ab1CRNVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 09:21:39 -0400
In-Reply-To: <1300454462-1234-5-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the be_worker() workqueue is scheduled in be_probe() it must
be canceled unconditionally in be_shutdown().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 0efa639..acd53e6 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3150,8 +3150,7 @@ static void be_shutdown(struct pci_dev *pdev)
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev =  adapter->netdev;
 
-	if (netif_running(netdev))
-		cancel_delayed_work_sync(&adapter->work);
+	cancel_delayed_work_sync(&adapter->work);
 
 	netif_device_detach(netdev);
 
-- 
1.6.5.2

