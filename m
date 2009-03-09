From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 08/12] qlge: Clear shadow registers before use.
Date: Mon,  9 Mar 2009 13:59:24 -0700
Message-ID: <1236632368-22079-9-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbZCIVDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:10 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 45ad4cc..75ad4db 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2142,6 +2142,7 @@ static int ql_alloc_shadow_space(struct ql_adapter *qdev)
 			"Allocation of RX shadow space failed.\n");
 		return -ENOMEM;
 	}
+	memset(qdev->rx_ring_shadow_reg_area, 0, PAGE_SIZE);
 	qdev->tx_ring_shadow_reg_area =
 	    pci_alloc_consistent(qdev->pdev, PAGE_SIZE,
 				 &qdev->tx_ring_shadow_reg_dma);
@@ -2150,6 +2151,7 @@ static int ql_alloc_shadow_space(struct ql_adapter *qdev)
 			"Allocation of TX shadow space failed.\n");
 		goto err_wqp_sh_area;
 	}
+	memset(qdev->tx_ring_shadow_reg_area, 0, PAGE_SIZE);
 	return 0;
 
 err_wqp_sh_area:
-- 
1.6.0.2

