From: Joe Perches <joe@perches.com>
Subject: [PATCH 27/49] drivers/net/netxen: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:51 -0700
Message-ID: <61bf7e82bb35693aebdb3a56b30b1c38836bf502.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/netxen/netxen_nic_init.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 95fe552..731077d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -214,13 +214,12 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	tx_ring->num_desc = adapter->num_txd;
 	tx_ring->txq = netdev_get_tx_queue(netdev, 0);
 
-	cmd_buf_arr = vmalloc(TX_BUFF_RINGSIZE(tx_ring));
+	cmd_buf_arr = vzalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
 		dev_err(&pdev->dev, "%s: failed to allocate cmd buffer ring\n",
 		       netdev->name);
 		goto err_out;
 	}
-	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
 
 	recv_ctx = &adapter->recv_ctx;
@@ -279,8 +278,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			break;
 
 		}
-		rds_ring->rx_buf_arr = (struct netxen_rx_buffer *)
-			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
+		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
 			printk(KERN_ERR "%s: Failed to allocate "
 				"rx buffer ring %d\n",
@@ -288,7 +286,6 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			/* free whatever was already allocated */
 			goto err_out;
 		}
-		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
-- 
1.7.3.1.g432b3.dirty
