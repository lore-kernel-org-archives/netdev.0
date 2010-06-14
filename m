From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/3] netxen: fix memory leaks in error path
Date: Mon, 14 Jun 2010 02:39:03 -0700
Message-ID: <1276508345-17070-2-git-send-email-amit.salecha@qlogic.com>
References: <1276508345-17070-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:55822 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755878Ab0FNJjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 05:39:06 -0400
In-Reply-To: <1276508345-17070-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes memory leak in error path when memory allocation
for adapter data structures fails.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_ctx.c  |    3 ++-
 drivers/net/netxen/netxen_nic_init.c |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index f26e547..3a41b6a 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -629,7 +629,8 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	if (addr == NULL) {
 		dev_err(&pdev->dev, "%s: failed to allocate tx desc ring\n",
 				netdev->name);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_out_free;
 	}
 
 	tx_ring->desc_head = (struct cmd_desc_type0 *)addr;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 045a7c8..e08527f 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -218,7 +218,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	if (cmd_buf_arr == NULL) {
 		dev_err(&pdev->dev, "%s: failed to allocate cmd buffer ring\n",
 		       netdev->name);
-		return -ENOMEM;
+		goto err_out;
 	}
 	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
@@ -230,7 +230,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	if (rds_ring == NULL) {
 		dev_err(&pdev->dev, "%s: failed to allocate rds ring struct\n",
 		       netdev->name);
-		return -ENOMEM;
+		goto err_out;
 	}
 	recv_ctx->rds_rings = rds_ring;
 
-- 
1.6.0.2

