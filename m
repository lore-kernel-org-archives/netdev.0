From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 6/6] bnx2x: prevent crash in shutdown flow with CNIC
Date: Tue, 16 Jul 2013 18:21:47 +0300
Message-ID: <1373988107-305-7-git-send-email-dmitry@broadcom.com>
References: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933165Ab3GPPWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 11:22:11 -0400
In-Reply-To: <1373988107-305-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>

There might be a crash as during shutdown flow CNIC might try
to access resources already freed by bnx2x.
Change bnx2x_close() into dev_close() in __bnx2x_remove (shutdown flow)
to guarantee CNIC is notified of the device's change of status.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9394b7d..2fdc8e6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12838,8 +12838,7 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 		unregister_netdev(dev);
 	} else {
 		rtnl_lock();
-		if (netif_running(dev))
-			bnx2x_close(dev);
+		dev_close(dev);
 		rtnl_unlock();
 	}
 
-- 
1.8.1.4
