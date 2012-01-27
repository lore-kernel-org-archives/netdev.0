From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/7] r8169: remove hardcoded PCIe registers accesses.
Date: Fri, 27 Jan 2012 21:54:57 +0100
Message-ID: <20120127205457.GA24507@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57419 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754375Ab2A0VFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:05:52 -0500
Content-Disposition: inline
In-Reply-To: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a0c800..ca86e67 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3824,23 +3824,21 @@ static void r8168dp_hw_jumbo_disable(struct rtl8169_private *tp)
 static void r8168e_hw_jumbo_enable(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
 
 	RTL_W8(MaxTxPacketSize, 0x3f);
 	RTL_W8(Config3, RTL_R8(Config3) | Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) | 0x01);
-	pci_write_config_byte(pdev, 0x79, 0x20);
+	rtl_tx_performance_tweak(tp->pci_dev, 0x2 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168e_hw_jumbo_disable(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
 
 	RTL_W8(MaxTxPacketSize, 0x0c);
 	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) & ~0x01);
-	pci_write_config_byte(pdev, 0x79, 0x50);
+	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168b_0_hw_jumbo_enable(struct rtl8169_private *tp)
-- 
1.7.6.5
