From: "Michael Chan" <mchan@broadcom.com>
Subject: [3/5][BNX2]: Enable DMA on 5709.
Date: Mon, 04 Jun 2007 17:00:48 -0700
Message-ID: <1181001648.5275.14.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3615 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255AbXFDXQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 19:16:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Enable DMA on 5709.

Add missing code to enable DMA on 5709 A1.  The bit is a no-op on
A0 and therefore can be set on all 5709 chips.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index daa62d9..c03282c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3810,6 +3810,11 @@ bnx2_init_chip(struct bnx2 *bp)
 	/* Initialize the receive filter. */
 	bnx2_set_rx_mode(bp->dev);
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		val = REG_RD(bp, BNX2_MISC_NEW_CORE_CTL);
+		val |= BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE;
+		REG_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
+	}
 	rc = bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT2 | BNX2_DRV_MSG_CODE_RESET,
 			  0);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index bd6288d..49a5de2 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -1373,6 +1373,7 @@ struct l2_fhdr {
 #define BNX2_MISC_NEW_CORE_CTL				0x000008c8
 #define BNX2_MISC_NEW_CORE_CTL_LINK_HOLDOFF_SUCCESS	 (1L<<0)
 #define BNX2_MISC_NEW_CORE_CTL_LINK_HOLDOFF_REQ		 (1L<<1)
+#define BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE		 (1L<<16)
 #define BNX2_MISC_NEW_CORE_CTL_RESERVED_CMN		 (0x3fffL<<2)
 #define BNX2_MISC_NEW_CORE_CTL_RESERVED_TC		 (0xffffL<<16)
 


