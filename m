From: Joe Perches <joe@perches.com>
Subject: [PATCH 29/49] drivers/net/qlcnic: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:53 -0700
Message-ID: <18c00a444b86cd1f72ab6afa81d4886b11b5e99b.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4137 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799Ab0KEDI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 23:08:56 -0400
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 0d180c6..c5ea2f4 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -236,12 +236,11 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	tx_ring->num_desc = adapter->num_txd;
 	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
 
-	cmd_buf_arr = vmalloc(TX_BUFF_RINGSIZE(tx_ring));
+	cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
 		dev_err(&netdev->dev, "failed to allocate cmd buffer ring\n");
 		goto err_out;
 	}
-	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
 
 	recv_ctx = &adapter->recv_ctx;
@@ -275,14 +274,12 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 				rds_ring->dma_size + NET_IP_ALIGN;
 			break;
 		}
-		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
-			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
+		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
 			dev_err(&netdev->dev, "Failed to allocate "
 				"rx buffer ring %d\n", ring);
 			goto err_out;
 		}
-		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
-- 
1.7.3.1.g432b3.dirty

