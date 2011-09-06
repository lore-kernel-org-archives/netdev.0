From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v5 2/5] r8169: define the early size for 8111evl
Date: Tue, 6 Sep 2011 16:55:15 +0800
Message-ID: <1315299318-1547-2-git-send-email-hayeswang@realtek.com>
References: <1315299318-1547-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:39277 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846Ab1IFIzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 04:55:35 -0400
In-Reply-To: <1315299318-1547-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RTL8111EVL, the register of MaxTxPacketSize doesn't acctually
limit the tx size. It influnces the feature of early tx.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index aaae43e..db5ab2c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -311,6 +311,7 @@ enum rtl_registers {
 	MaxTxPacketSize	= 0xec,	/* 8101/8168. Unit of 128 bytes. */
 
 #define TxPacketMax	(8064 >> 7)
+#define EarlySize	0x27
 
 	FuncEvent	= 0xf0,
 	FuncEventMask	= 0xf4,
@@ -4465,7 +4466,7 @@ static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
 		     ERIAR_EXGMAC);
 
-	RTL_W8(MaxTxPacketSize, 0x27);
+	RTL_W8(MaxTxPacketSize, EarlySize);
 
 	rtl_disable_clock_request(pdev);
 
-- 
1.7.6
