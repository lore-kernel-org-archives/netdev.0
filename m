From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 2/9] amd-xgbe: Change from napi_complete to
 napi_complete_done
Date: Wed, 17 Feb 2016 11:48:19 -0600
Message-ID: <20160217174819.26246.82239.stgit@tlendack-t1.amdoffice.net>
References: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0070.outbound.protection.outlook.com ([157.56.110.70]:18496
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964878AbcBQRsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:48:32 -0500
In-Reply-To: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change from using napi_complete to napi_complete_done to allow for the
use of gro_flush_timeout in tuning network processing.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index cfd3f7e..5a4d9ca 100644
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
@@ -2068,7 +2068,7 @@ static int xgbe_one_poll(struct napi_struct *napi, int budget)
 	/* If we processed everything, we are done */
 	if (processed < budget) {
 		/* Turn off polling */
-		napi_complete(napi);
+		napi_complete_done(napi, processed);
 
 		/* Enable Tx and Rx interrupts */
 		enable_irq(channel->dma_irq);
@@ -2110,7 +2110,7 @@ static int xgbe_all_poll(struct napi_struct *napi, int budget)
 	/* If we processed everything, we are done */
 	if (processed < budget) {
 		/* Turn off polling */
-		napi_complete(napi);
+		napi_complete_done(napi, processed);
 
 		/* Enable Tx and Rx interrupts */
 		xgbe_enable_rx_tx_ints(pdata);
