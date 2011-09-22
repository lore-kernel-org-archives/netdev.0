From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 1/4] r8169: define the early size for 8111evl
Date: Thu, 22 Sep 2011 23:03:25 +0200
Message-ID: <20110922210325.GB16362@electric-eye.fr.zoreil.com>
References: <20110922210202.GA16362@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48062 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841Ab1IVVE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 17:04:29 -0400
Content-Disposition: inline
In-Reply-To: <20110922210202.GA16362@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RTL8111EVL, the register of MaxTxPacketSize doesn't acctually
limit the tx size. It influnces the feature of early tx.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6eb9f4e..44b40ea 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -311,6 +311,7 @@ enum rtl_registers {
 	MaxTxPacketSize	= 0xec,	/* 8101/8168. Unit of 128 bytes. */
 
 #define TxPacketMax	(8064 >> 7)
+#define EarlySize	0x27
 
 	FuncEvent	= 0xf0,
 	FuncEventMask	= 0xf4,
@@ -4479,7 +4480,7 @@ static void rtl_hw_start_8168e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
 		     ERIAR_EXGMAC);
 
-	RTL_W8(MaxTxPacketSize, 0x27);
+	RTL_W8(MaxTxPacketSize, EarlySize);
 
 	rtl_disable_clock_request(pdev);
 
-- 
1.7.6
