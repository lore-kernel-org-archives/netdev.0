From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e/i40evf: Fix output of i40e_debug_aq() for big endian machines
Date: Wed, 25 Feb 2015 00:58:26 -0800
Message-ID: <1424854720-18825-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20292 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbbBYI6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:45 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>

The function i40e_debug_aq() prints information helpful in debugging
admin queue commands, but it doesn't do so correctly on big endian machines.
This patch adds the appropriate LExx_TO_CPU wrappers for big endian
architectures.

Also update the copyright year.

Change-ID: I4b2dc229ed5bf6dfe35632a58cddf53c21aff4b0
Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 31 +++++++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 29 ++++++++++++++---------
 2 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 8dbf7dd..6d630a0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -94,16 +94,19 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 
 	i40e_debug(hw, mask,
 		   "AQ CMD: opcode 0x%04X, flags 0x%04X, datalen 0x%04X, retval 0x%04X\n",
-		   aq_desc->opcode, aq_desc->flags, aq_desc->datalen,
-		   aq_desc->retval);
+		   le16_to_cpu(aq_desc->opcode),
+		   le16_to_cpu(aq_desc->flags),
+		   le16_to_cpu(aq_desc->datalen),
+		   le16_to_cpu(aq_desc->retval));
 	i40e_debug(hw, mask, "\tcookie (h,l) 0x%08X 0x%08X\n",
-		   aq_desc->cookie_high, aq_desc->cookie_low);
+		   le32_to_cpu(aq_desc->cookie_high),
+		   le32_to_cpu(aq_desc->cookie_low));
 	i40e_debug(hw, mask, "\tparam (0,1)  0x%08X 0x%08X\n",
-		   aq_desc->params.internal.param0,
-		   aq_desc->params.internal.param1);
+		   le32_to_cpu(aq_desc->params.internal.param0),
+		   le32_to_cpu(aq_desc->params.internal.param1));
 	i40e_debug(hw, mask, "\taddr (h,l)   0x%08X 0x%08X\n",
-		   aq_desc->params.external.addr_high,
-		   aq_desc->params.external.addr_low);
+		   le32_to_cpu(aq_desc->params.external.addr_high),
+		   le32_to_cpu(aq_desc->params.external.addr_low));
 
 	if ((buffer != NULL) && (aq_desc->datalen != 0)) {
 		memset(data, 0, sizeof(data));
@@ -116,15 +119,19 @@ void i40e_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 			if ((i % 16) == 15) {
 				i40e_debug(hw, mask,
 					   "\t0x%04X  %08X %08X %08X %08X\n",
-					   i - 15, data[0], data[1], data[2],
-					   data[3]);
+					   i - 15, le32_to_cpu(data[0]),
+					   le32_to_cpu(data[1]),
+					   le32_to_cpu(data[2]),
+					   le32_to_cpu(data[3]));
 				memset(data, 0, sizeof(data));
 			}
 		}
 		if ((i % 16) != 0)
 			i40e_debug(hw, mask, "\t0x%04X  %08X %08X %08X %08X\n",
-				   i - (i % 16), data[0], data[1], data[2],
-				   data[3]);
+				   i - (i % 16), le32_to_cpu(data[0]),
+				   le32_to_cpu(data[1]),
+				   le32_to_cpu(data[2]),
+				   le32_to_cpu(data[3]));
 	}
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 28c40c5..50b0ee5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -94,16 +94,19 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 
 	i40e_debug(hw, mask,
 		   "AQ CMD: opcode 0x%04X, flags 0x%04X, datalen 0x%04X, retval 0x%04X\n",
-		   aq_desc->opcode, aq_desc->flags, aq_desc->datalen,
-		   aq_desc->retval);
+		   le16_to_cpu(aq_desc->opcode),
+		   le16_to_cpu(aq_desc->flags),
+		   le16_to_cpu(aq_desc->datalen),
+		   le16_to_cpu(aq_desc->retval));
 	i40e_debug(hw, mask, "\tcookie (h,l) 0x%08X 0x%08X\n",
-		   aq_desc->cookie_high, aq_desc->cookie_low);
+		   le32_to_cpu(aq_desc->cookie_high),
+		   le32_to_cpu(aq_desc->cookie_low));
 	i40e_debug(hw, mask, "\tparam (0,1)  0x%08X 0x%08X\n",
-		   aq_desc->params.internal.param0,
-		   aq_desc->params.internal.param1);
+		   le32_to_cpu(aq_desc->params.internal.param0),
+		   le32_to_cpu(aq_desc->params.internal.param1));
 	i40e_debug(hw, mask, "\taddr (h,l)   0x%08X 0x%08X\n",
-		   aq_desc->params.external.addr_high,
-		   aq_desc->params.external.addr_low);
+		   le32_to_cpu(aq_desc->params.external.addr_high),
+		   le32_to_cpu(aq_desc->params.external.addr_low));
 
 	if ((buffer != NULL) && (aq_desc->datalen != 0)) {
 		memset(data, 0, sizeof(data));
@@ -116,15 +119,19 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
 			if ((i % 16) == 15) {
 				i40e_debug(hw, mask,
 					   "\t0x%04X  %08X %08X %08X %08X\n",
-					   i - 15, data[0], data[1], data[2],
-					   data[3]);
+					   i - 15, le32_to_cpu(data[0]),
+					   le32_to_cpu(data[1]),
+					   le32_to_cpu(data[2]),
+					   le32_to_cpu(data[3]));
 				memset(data, 0, sizeof(data));
 			}
 		}
 		if ((i % 16) != 0)
 			i40e_debug(hw, mask, "\t0x%04X  %08X %08X %08X %08X\n",
-				   i - (i % 16), data[0], data[1], data[2],
-				   data[3]);
+				   i - (i % 16), le32_to_cpu(data[0]),
+				   le32_to_cpu(data[1]),
+				   le32_to_cpu(data[2]),
+				   le32_to_cpu(data[3]));
 	}
 }
 
-- 
1.9.3
