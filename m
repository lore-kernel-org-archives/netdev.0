From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 2/8]: Use lower DMA watermark for 5703.
Date: Tue, 13 Feb 2007 12:14:01 -0800
Message-ID: <1171397641.18944.26.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1745 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783AbXBMTak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:30:40 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Use lower DMA watermark for 5703.

Set DMA read watermark to 4 on 5703 in PCIX mode.  This is needed to
prevent some tx timeouts.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0b5b8e7..2df343f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11314,6 +11314,7 @@ static int __devinit tg3_test_dma(struct
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
 			u32 ccval = (tr32(TG3PCI_CLOCK_CTRL) & 0x1f);
+			u32 read_water = 0x7;
 
 			/* If the 5704 is behind the EPB bridge, we can
 			 * do the less restrictive ONE_DMA workaround for
@@ -11325,8 +11326,13 @@ static int __devinit tg3_test_dma(struct
 			else if (ccval == 0x6 || ccval == 0x7)
 				tp->dma_rwctrl |= DMA_RWCTRL_ONE_DMA;
 
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703)
+				read_water = 4;
 			/* Set bit 23 to enable PCIX hw bug fix */
-			tp->dma_rwctrl |= 0x009f0000;
+			tp->dma_rwctrl |=
+				(read_water << DMA_RWCTRL_READ_WATER_SHIFT) |
+				(0x3 << DMA_RWCTRL_WRITE_WATER_SHIFT) |
+				(1 << 23);
 		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5780) {
 			/* 5780 always in PCIX mode */
 			tp->dma_rwctrl |= 0x00144000;


