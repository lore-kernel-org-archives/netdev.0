From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/7] qlcnic: fix memory leaks
Date: Mon, 17 May 2010 04:22:08 -0700
Message-ID: <1274095334-32362-2-git-send-email-amit.salecha@qlogic.com>
References: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5233 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751052Ab0EQKVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 06:21:50 -0400
In-Reply-To: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Fixes memory leak in error path when memory allocation
for adapter data structures fails.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ctx.c  |    3 ++-
 drivers/net/qlcnic/qlcnic_init.c |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 0a6a399..c2c1f5c 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -421,7 +421,8 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 
 	if (addr == NULL) {
 		dev_err(&pdev->dev, "failed to allocate tx desc ring\n");
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err_out_free;
 	}
 
 	tx_ring->desc_head = (struct cmd_desc_type0 *)addr;
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 77bfdab..dccd8c3 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -210,7 +210,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	cmd_buf_arr = vmalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
 		dev_err(&netdev->dev, "failed to allocate cmd buffer ring\n");
-		return -ENOMEM;
+		goto err_out;
 	}
 	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
@@ -221,7 +221,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	rds_ring = kzalloc(size, GFP_KERNEL);
 	if (rds_ring == NULL) {
 		dev_err(&netdev->dev, "failed to allocate rds ring struct\n");
-		return -ENOMEM;
+		goto err_out;
 	}
 	recv_ctx->rds_rings = rds_ring;
 
-- 
1.5.6.1

