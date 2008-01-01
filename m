From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 08/26] atl1: additional DMA engine configuration
Date: Mon, 31 Dec 2007 20:22:35 -0600
Message-ID: <1199154173-4058-9-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:63805 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYAAC2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:12 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DMA engine configuration tweaks per current vendor atl1 driver version
1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   10 ++++++++++
 drivers/net/atlx/atlx.h |    6 ++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index c93cf19..fb0a0af 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -666,6 +666,7 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
 	u32 value;
+	u16 x;
 
 	/* clear interrupt status */
 	iowrite32(0xffffffff, adapter->hw.hw_addr + REG_ISR);
@@ -797,6 +798,15 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	iowrite32(value, hw->hw_addr + REG_RXQ_CTRL);
 
 	/* config DMA Engine */
+	value = ioread32(hw->hw_addr + REG_DEVICE_CTRL);
+	x = (value >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT) &
+		DEVICE_CTRL_MAX_PAYLOAD_MASK;
+	if (x < hw->dmaw_block)
+		hw->dmaw_block = x;
+	x = (value >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT) &
+		DEVICE_CTRL_MAX_RREQ_SZ_MASK;
+	if (x < hw->dmar_block)
+		hw->dmar_block = x;
 	value = ((((u32) hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
 		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
 		((((u32) hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN_MASK)
diff --git a/drivers/net/atlx/atlx.h b/drivers/net/atlx/atlx.h
index 3be7c09..43b8531 100644
--- a/drivers/net/atlx/atlx.h
+++ b/drivers/net/atlx/atlx.h
@@ -53,6 +53,12 @@ MODULE_VERSION(ATLX_DRIVER_VERSION);
 
 #define REG_PCIE_CAP_LIST		0x58
 
+#define REG_DEVICE_CTRL			0x60
+#define DEVICE_CTRL_MAX_PAYLOAD_MASK	0x7
+#define DEVICE_CTRL_MAX_PAYLOAD_SHIFT	5
+#define DEVICE_CTRL_MAX_RREQ_SZ_MASK	0x7
+#define DEVICE_CTRL_MAX_RREQ_SZ_SHIFT	12
+
 #define REG_VPD_CAP			0x6C
 #define VPD_CAP_ID_MASK			0xFF
 #define VPD_CAP_ID_SHIFT		0
-- 
1.5.3.3

