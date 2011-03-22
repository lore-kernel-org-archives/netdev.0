From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 4/5] be2net: cancel be_worker in be_shutdown() even when i/f is down
Date: Tue, 22 Mar 2011 12:19:28 +0530
Message-ID: <b5846e8b-c476-4506-8239-0204d2007b02@exht1.ad.emulex.com>
References: <1300776569-15586-1-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-2-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-3-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-4-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Sathya Perla <sathya.perla@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:5041 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754732Ab1CVGvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 02:51:11 -0400
In-Reply-To: <1300776569-15586-4-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the be_worker() workqueue is scheduled in be_probe() it must
be canceled unconditionally in be_shutdown().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 3bf79d1..8638913 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3155,8 +3155,7 @@ static void be_shutdown(struct pci_dev *pdev)
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev =  adapter->netdev;
 
-	if (netif_running(netdev))
-		cancel_delayed_work_sync(&adapter->work);
+	cancel_delayed_work_sync(&adapter->work);
 
 	netif_device_detach(netdev);
 
-- 
1.6.5.2

