From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] qlge: bugfix: Fix register access error checking.
Date: Tue, 30 Dec 2008 13:12:25 -0800
Message-ID: <1230671545-19084-5-git-send-email-ron.mercer@qlogic.com>
References: <20081230211122.GD16018@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, bhutchings@solarflare.com, hch@infradead.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38470 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295AbYL3VM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 16:12:26 -0500
In-Reply-To: <20081230211122.GD16018@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some indexed registers do not have error bits. In these cases a
value of zero should be used for error checking.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index ffa2100..837be72 100644
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

