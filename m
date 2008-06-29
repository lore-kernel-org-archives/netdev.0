From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 8/13] r8169: Tx performance tweak
Date: Sun, 29 Jun 2008 16:45:26 +0200
Message-ID: <20080629144526.GI1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38262 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760191AbYF2Opu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:45:50 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c2861a4..46bdcb9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2156,19 +2156,19 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
-static void rtl8168_tx_performance_tweak(struct pci_dev *pdev, unsigned int reg
-)
+static void rtl8168_tx_performance_tweak(struct pci_dev *pdev,
+					 unsigned int reg, u8 force)
 {
 	u8 ctl;
 
 	pci_read_config_byte(pdev, reg, &ctl);
-	ctl = (ctl & ~0x70) | 0x50;
+	ctl = (ctl & ~0x70) | force;
 	pci_write_config_byte(pdev, reg, ctl);
 }
 
 static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl8168_tx_performance_tweak(pdev, 0x69);
+	rtl8168_tx_performance_tweak(pdev, 0x69, 0x58);
 }
 
 static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
@@ -2178,7 +2178,7 @@ static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void __rtl_hw_start_8168cpx(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl8168_tx_performance_tweak(pdev, 0x69);
+	rtl8168_tx_performance_tweak(pdev, 0x79, 0x50);
 }
 
 static void rtl_hw_start_8168c(void __iomem *ioaddr, struct pci_dev *pdev)
-- 
1.5.3.3

