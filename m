From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/7] sky2: rename BMU register
Date: Mon, 04 Jun 2007 17:23:23 -0700
Message-ID: <20070605002738.767572717@linux-foundation.org>
References: <20070605002320.868185090@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38978 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753822AbXFEAnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:43:20 -0400
Content-Disposition: inline; filename=sky2-f-test.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This register is more of a test and control register on Yukon2.
So rename it to Q_TEST and give some bit definitions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    2 +-
 drivers/net/sky2.h |   29 +++++++++++------------------
 2 files changed, 12 insertions(+), 19 deletions(-)

--- a/drivers/net/sky2.c	2007-06-04 08:46:41.000000000 -0700
+++ b/drivers/net/sky2.c	2007-06-04 08:46:43.000000000 -0700
@@ -1140,7 +1140,7 @@ static int sky2_rx_start(struct sky2_por
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
 	    (hw->chip_rev == CHIP_REV_YU_EC_U_A1
 	     || hw->chip_rev == CHIP_REV_YU_EC_U_B0))
-		sky2_write32(hw, Q_ADDR(rxq, Q_F), F_M_RX_RAM_DIS);
+		sky2_write32(hw, Q_ADDR(rxq, Q_TEST), F_M_RX_RAM_DIS);
 
 	sky2_prefetch_init(hw, rxq, sky2->rx_le_map, RX_LE_SIZE - 1);
 
--- a/drivers/net/sky2.h	2007-06-04 08:46:41.000000000 -0700
+++ b/drivers/net/sky2.h	2007-06-04 08:46:43.000000000 -0700
@@ -592,23 +592,15 @@ enum {
 enum {
 	B8_Q_REGS = 0x0400, /* base of Queue registers */
 	Q_D	= 0x00,	/* 8*32	bit	Current Descriptor */
-	Q_DA_L	= 0x20,	/* 32 bit	Current Descriptor Address Low dWord */
-	Q_DA_H	= 0x24,	/* 32 bit	Current Descriptor Address High dWord */
+	Q_VLAN  = 0x20, /* 16 bit	Current VLAN Tag */
+	Q_DONE	= 0x24,	/* 16 bit	Done Index */
 	Q_AC_L	= 0x28,	/* 32 bit	Current Address Counter Low dWord */
 	Q_AC_H	= 0x2c,	/* 32 bit	Current Address Counter High dWord */
 	Q_BC	= 0x30,	/* 32 bit	Current Byte Counter */
 	Q_CSR	= 0x34,	/* 32 bit	BMU Control/Status Register */
-	Q_F	= 0x38,	/* 32 bit	Flag Register */
-	Q_T1	= 0x3c,	/* 32 bit	Test Register 1 */
-	Q_T1_TR	= 0x3c,	/*  8 bit	Test Register 1 Transfer SM */
-	Q_T1_WR	= 0x3d,	/*  8 bit	Test Register 1 Write Descriptor SM */
-	Q_T1_RD	= 0x3e,	/*  8 bit	Test Register 1 Read Descriptor SM */
-	Q_T1_SV	= 0x3f,	/*  8 bit	Test Register 1 Supervisor SM */
-	Q_T2	= 0x40,	/* 32 bit	Test Register 2	*/
-	Q_T3	= 0x44,	/* 32 bit	Test Register 3	*/
+	Q_TEST	= 0x38,	/* 32 bit	Test/Control Register */
 
 /* Yukon-2 */
-	Q_DONE	= 0x24,	/* 16 bit	Done Index 		(Yukon-2 only) */
 	Q_WM	= 0x40,	/* 16 bit	FIFO Watermark */
 	Q_AL	= 0x42,	/*  8 bit	FIFO Alignment */
 	Q_RSP	= 0x44,	/* 16 bit	FIFO Read Shadow Pointer */
@@ -622,15 +614,16 @@ enum {
 };
 #define Q_ADDR(reg, offs) (B8_Q_REGS + (reg) + (offs))
 
-/*	Q_F				32 bit	Flag Register */
+/*	Q_TEST				32 bit	Test Register */
 enum {
-	F_ALM_FULL	= 1<<27, /* Rx FIFO: almost full */
-	F_EMPTY		= 1<<27, /* Tx FIFO: empty flag */
-	F_FIFO_EOF	= 1<<26, /* Tag (EOF Flag) bit in FIFO */
-	F_WM_REACHED	= 1<<25, /* Watermark reached */
+	/* Transmit */
+	F_TX_CHK_AUTO_OFF = 1<<31, /* Tx checksum auto calc off (Yukon EX) */
+	F_TX_CHK_AUTO_ON  = 1<<30, /* Tx checksum auto calc off (Yukon EX) */
+
+	/* Receive */
 	F_M_RX_RAM_DIS	= 1<<24, /* MAC Rx RAM Read Port disable */
-	F_FIFO_LEVEL	= 0x1fL<<16, /* Bit 23..16:	# of Qwords in FIFO */
-	F_WATER_MARK	= 0x0007ffL, /* Bit 10.. 0:	Watermark */
+
+	/* Hardware testbits not used */
 };
 
 /* Queue Prefetch Unit Offsets, use Y2_QADDR() to address (Yukon-2 only)*/

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

