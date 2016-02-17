From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 4/9] amd-xgbe: Verify forced speed matches the
 active speedset
Date: Wed, 17 Feb 2016 11:48:39 -0600
Message-ID: <20160217174839.26246.5006.stgit@tlendack-t1.amdoffice.net>
References: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0057.outbound.protection.outlook.com ([207.46.100.57]:28575
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964878AbcBQRsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:48:45 -0500
In-Reply-To: <20160217174758.26246.15641.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using ethtool to set the speed for the device, verify that the
specified speed is valid within the active speedset.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 6040293..11d9f0c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
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
@@ -318,8 +318,20 @@ static int xgbe_set_settings(struct net_device *netdev,
 	if (cmd->autoneg == AUTONEG_DISABLE) {
 		switch (speed) {
 		case SPEED_10000:
+			break;
 		case SPEED_2500:
+			if (pdata->speed_set != XGBE_SPEEDSET_2500_10000) {
+				netdev_err(netdev, "unsupported speed %u\n",
+					   speed);
+				return -EINVAL;
+			}
+			break;
 		case SPEED_1000:
+			if (pdata->speed_set != XGBE_SPEEDSET_1000_10000) {
+				netdev_err(netdev, "unsupported speed %u\n",
+					   speed);
+				return -EINVAL;
+			}
 			break;
 		default:
 			netdev_err(netdev, "unsupported speed %u\n", speed);
