From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v4 6/6] bnx2x: prevent crash in shutdown flow with
 CNIC
Date: Tue, 6 Aug 2013 00:35:44 +0300
Message-ID: <1375738544-8695-7-git-send-email-dmitry@broadcom.com>
References: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1269 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603Ab3HEVgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:36:04 -0400
In-Reply-To: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>

There might be a crash as during shutdown flow CNIC might try
to access resources already freed by bnx2x.
Change bnx2x_close() into dev_close() in __bnx2x_remove (shutdown flow)
to guarantee CNIC is notified of the device's change of status.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5c22081..abafb30 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12837,8 +12837,7 @@ static void __bnx2x_remove(struct pci_dev *pdev,
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
