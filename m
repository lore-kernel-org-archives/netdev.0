From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 08/18] net/ena: change sizeof() argument to be the type pointer
Date: Sun, 20 Nov 2016 10:45:37 +0200
Message-ID: <1479631547-29354-9-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38270 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753411AbcKTIqP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:46:15 -0500
Received: by mail-wm0-f47.google.com with SMTP id f82so98677182wmf.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:46:15 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using:
memset(ptr, 0x0, sizeof(struct ...))
use:
memset(ptr, 0x0, sizeor(*ptr))

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 366c2c5..edb2e81 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -329,7 +329,7 @@ static int ena_com_init_io_sq(struct ena_com_dev *ena_dev,
 	size_t size;
 	int dev_node = 0;
 
-	memset(&io_sq->desc_addr, 0x0, sizeof(struct ena_com_io_desc_addr));
+	memset(&io_sq->desc_addr, 0x0, sizeof(io_sq->desc_addr));
 
 	io_sq->desc_entry_size =
 		(io_sq->direction == ENA_COM_IO_QUEUE_DIRECTION_TX) ?
@@ -383,7 +383,7 @@ static int ena_com_init_io_cq(struct ena_com_dev *ena_dev,
 	size_t size;
 	int prev_node = 0;
 
-	memset(&io_cq->cdesc_addr, 0x0, sizeof(struct ena_com_io_desc_addr));
+	memset(&io_cq->cdesc_addr, 0x0, sizeof(io_cq->cdesc_addr));
 
 	/* Use the basic completion descriptor for Rx */
 	io_cq->cdesc_entry_size_in_bytes =
@@ -681,7 +681,7 @@ static int ena_com_destroy_io_sq(struct ena_com_dev *ena_dev,
 	u8 direction;
 	int ret;
 
-	memset(&destroy_cmd, 0x0, sizeof(struct ena_admin_aq_destroy_sq_cmd));
+	memset(&destroy_cmd, 0x0, sizeof(destroy_cmd));
 
 	if (io_sq->direction == ENA_COM_IO_QUEUE_DIRECTION_TX)
 		direction = ENA_ADMIN_SQ_DIRECTION_TX;
@@ -963,7 +963,7 @@ static int ena_com_create_io_sq(struct ena_com_dev *ena_dev,
 	u8 direction;
 	int ret;
 
-	memset(&create_cmd, 0x0, sizeof(struct ena_admin_aq_create_sq_cmd));
+	memset(&create_cmd, 0x0, sizeof(create_cmd));
 
 	create_cmd.aq_common_descriptor.opcode = ENA_ADMIN_CREATE_SQ;
 
@@ -1155,7 +1155,7 @@ int ena_com_create_io_cq(struct ena_com_dev *ena_dev,
 	struct ena_admin_acq_create_cq_resp_desc cmd_completion;
 	int ret;
 
-	memset(&create_cmd, 0x0, sizeof(struct ena_admin_aq_create_cq_cmd));
+	memset(&create_cmd, 0x0, sizeof(create_cmd));
 
 	create_cmd.aq_common_descriptor.opcode = ENA_ADMIN_CREATE_CQ;
 
@@ -1263,7 +1263,7 @@ int ena_com_destroy_io_cq(struct ena_com_dev *ena_dev,
 	struct ena_admin_acq_destroy_cq_resp_desc destroy_resp;
 	int ret;
 
-	memset(&destroy_cmd, 0x0, sizeof(struct ena_admin_aq_destroy_sq_cmd));
+	memset(&destroy_cmd, 0x0, sizeof(destroy_cmd));
 
 	destroy_cmd.cq_idx = io_cq->idx;
 	destroy_cmd.aq_common_descriptor.opcode = ENA_ADMIN_DESTROY_CQ;
@@ -1613,8 +1613,8 @@ int ena_com_create_io_queue(struct ena_com_dev *ena_dev,
 	io_sq = &ena_dev->io_sq_queues[ctx->qid];
 	io_cq = &ena_dev->io_cq_queues[ctx->qid];
 
-	memset(io_sq, 0x0, sizeof(struct ena_com_io_sq));
-	memset(io_cq, 0x0, sizeof(struct ena_com_io_cq));
+	memset(io_sq, 0x0, sizeof(*io_sq));
+	memset(io_cq, 0x0, sizeof(*io_cq));
 
 	/* Init CQ */
 	io_cq->q_depth = ctx->queue_size;
-- 
1.9.1
