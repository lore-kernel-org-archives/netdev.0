From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 2/9] amd-xgbe: Change from napi_complete to
 napi_complete_done
Date: Fri, 12 Feb 2016 08:32:34 -0600
Message-ID: <20160212143234.23973.42418.stgit@tlendack-t1.amdoffice.net>
References: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0079.outbound.protection.outlook.com ([157.56.111.79]:31217
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750863AbcBLOrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:47:48 -0500
In-Reply-To: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change from using napi_complete to napi_complete_done to allow for the
use of gro_flush_timeout in tuning network processing.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 8a9b493..2aebbe2 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -6,7 +6,7 @@
  *
  * License 1: GPLv2
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  *
  * This file is free software; you may copy, redistribute and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,7 +56,7 @@
  *
  * License 2: Modified BSD
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -2062,7 +2062,7 @@ static int xgbe_one_poll(struct napi_struct *napi, int budget)
 	/* If we processed everything, we are done */
 	if (processed < budget) {
 		/* Turn off polling */
-		napi_complete(napi);
+		napi_complete_done(napi, processed);
 
 		/* Enable Tx and Rx interrupts */
 		enable_irq(channel->dma_irq);
@@ -2104,7 +2104,7 @@ static int xgbe_all_poll(struct napi_struct *napi, int budget)
 	/* If we processed everything, we are done */
 	if (processed < budget) {
 		/* Turn off polling */
-		napi_complete(napi);
+		napi_complete_done(napi, processed);
 
 		/* Enable Tx and Rx interrupts */
 		xgbe_enable_rx_tx_ints(pdata);
