From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/6] r8169: Tx performance tweak helper
Date: Sun, 17 Aug 2008 18:26:02 +0200
Message-ID: <20080817162602.GC18690@electric-eye.fr.zoreil.com>
References: <20080817162330.GA18690@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41308 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752346AbYHQQ1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 12:27:11 -0400
Content-Disposition: inline
In-Reply-To: <20080817162330.GA18690@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dac2677..26fa6e0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2054,12 +2054,20 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	RTL_W16(IntrMask, tp->intr_event);
 }
 
+static void rtl_tx_performance_tweak(struct pci_dev *pdev, u8 force)
+{
+	u8 ctl;
+
+	pci_read_config_byte(pdev, 0x69, &ctl);
+	ctl = (ctl & ~0x70) | force;
+	pci_write_config_byte(pdev, 0x69, ctl);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
-	u8 ctl;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 
@@ -2073,10 +2081,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	/* Tx performance tweak. */
-	pci_read_config_byte(pdev, 0x69, &ctl);
-	ctl = (ctl & ~0x70) | 0x50;
-	pci_write_config_byte(pdev, 0x69, ctl);
+	rtl_tx_performance_tweak(pdev, 0x50);
 
 	RTL_W16(IntrMitigate, 0x5151);
 
-- 
1.5.3.3

