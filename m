From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/3] qlge: bugfix: Add missing netif_napi_del call.
Date: Mon,  2 Feb 2009 13:41:54 -0800
Message-ID: <1233610914-7448-3-git-send-email-ron.mercer@qlogic.com>
References: <1233610914-7448-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12624 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739AbZBBVnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:43:51 -0500
In-Reply-To: <1233610914-7448-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c6c0704..3d1d7b6 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3836,7 +3836,7 @@ static int qlge_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	int err;
+	int err, i;
 
 	netif_device_detach(ndev);
 
@@ -3846,6 +3846,9 @@ static int qlge_suspend(struct pci_dev *pdev, pm_message_t state)
 			return err;
 	}
 
+	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++)
+		netif_napi_del(&qdev->rx_ring[i].napi);
+
 	err = pci_save_state(pdev);
 	if (err)
 		return err;
-- 
1.6.0.2

