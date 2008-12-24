From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] qlge: bugfix: Fix register access error checking.
Date: Wed, 24 Dec 2008 10:21:36 -0800
Message-ID: <1230142896-15533-5-git-send-email-ron.mercer@qlogic.com>
References: <20081224181834.GA15470@susedev.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:27618 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbYLXSVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:21:37 -0500
In-Reply-To: <20081224181834.GA15470@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some indexed register do not have error bits.  In this case a
value of zero should be used for error checking.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index b58f5df..db226c5 100755
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -257,7 +257,7 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 		{
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MW, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
 			if (status)
 				goto exit;
 			ql_write32(qdev, MAC_ADDR_IDX, (offset++) | /* offset */
@@ -265,13 +265,13 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 				   MAC_ADDR_ADR | MAC_ADDR_RS | type); /* type */
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MR, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MR, 0);
 			if (status)
 				goto exit;
 			*value++ = ql_read32(qdev, MAC_ADDR_DATA);
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MW, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
 			if (status)
 				goto exit;
 			ql_write32(qdev, MAC_ADDR_IDX, (offset++) | /* offset */
@@ -279,14 +279,14 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 				   MAC_ADDR_ADR | MAC_ADDR_RS | type); /* type */
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MR, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MR, 0);
 			if (status)
 				goto exit;
 			*value++ = ql_read32(qdev, MAC_ADDR_DATA);
 			if (type == MAC_ADDR_TYPE_CAM_MAC) {
 				status =
 				    ql_wait_reg_rdy(qdev,
-					MAC_ADDR_IDX, MAC_ADDR_MW, MAC_ADDR_E);
+					MAC_ADDR_IDX, MAC_ADDR_MW, 0);
 				if (status)
 					goto exit;
 				ql_write32(qdev, MAC_ADDR_IDX, (offset++) | /* offset */
@@ -294,7 +294,7 @@ int ql_get_mac_addr_reg(struct ql_adapter *qdev, u32 type, u16 index,
 					   MAC_ADDR_ADR | MAC_ADDR_RS | type); /* type */
 				status =
 				    ql_wait_reg_rdy(qdev, MAC_ADDR_IDX,
-						    MAC_ADDR_MR, MAC_ADDR_E);
+						    MAC_ADDR_MR, 0);
 				if (status)
 					goto exit;
 				*value++ = ql_read32(qdev, MAC_ADDR_DATA);
@@ -344,7 +344,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MW, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
 			if (status)
 				goto exit;
 			ql_write32(qdev, MAC_ADDR_IDX, (offset++) | /* offset */
@@ -353,7 +353,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			ql_write32(qdev, MAC_ADDR_DATA, lower);
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MW, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
 			if (status)
 				goto exit;
 			ql_write32(qdev, MAC_ADDR_IDX, (offset++) | /* offset */
@@ -362,7 +362,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			ql_write32(qdev, MAC_ADDR_DATA, upper);
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MW, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
 			if (status)
 				goto exit;
 			ql_write32(qdev, MAC_ADDR_IDX, (offset) |	/* offset */
@@ -400,7 +400,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 
 			status =
 			    ql_wait_reg_rdy(qdev,
-				MAC_ADDR_IDX, MAC_ADDR_MW, MAC_ADDR_E);
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
 			if (status)
 				goto exit;
 			ql_write32(qdev, MAC_ADDR_IDX, offset |	/* offset */
@@ -431,13 +431,13 @@ int ql_get_routing_reg(struct ql_adapter *qdev, u32 index, u32 *value)
 	if (status)
 		goto exit;
 
-	status = ql_wait_reg_rdy(qdev, RT_IDX, RT_IDX_MW, RT_IDX_E);
+	status = ql_wait_reg_rdy(qdev, RT_IDX, RT_IDX_MW, 0);
 	if (status)
 		goto exit;
 
 	ql_write32(qdev, RT_IDX,
 		   RT_IDX_TYPE_NICQ | RT_IDX_RS | (index << RT_IDX_IDX_SHIFT));
-	status = ql_wait_reg_rdy(qdev, RT_IDX, RT_IDX_MR, RT_IDX_E);
+	status = ql_wait_reg_rdy(qdev, RT_IDX, RT_IDX_MR, 0);
 	if (status)
 		goto exit;
 	*value = ql_read32(qdev, RT_DATA);
-- 
1.6.0

