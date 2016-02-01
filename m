From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169:   Added delay after power on and reset.
Date: Mon,  1 Feb 2016 18:05:20 +0200
Message-ID: <1454342720-2020-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.78.245.184] ([82.78.245.184]:49066 "EHLO marian1000.go.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbcBAQF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 11:05:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On reset and power on need 2msecs delay to autoload complete data from
 eeprom to VPD.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8476659..5186ef9 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -97,6 +97,7 @@ static const int multicast_filter_limit = 32;
 
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
+#define RTL8169_EE_TIMEOUT	2  /* 2ms Autoload from eeprom */
 
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -5137,6 +5138,7 @@ static void rtl_hw_reset(struct rtl8169_private *tp)
 	RTL_W8(ChipCmd, CmdReset);
 
 	rtl_udelay_loop_wait_low(tp, &rtl_chipcmd_cond, 100, 100);
+	mdelay(RTL8169_EE_TIMEOUT);
 }
 
 static void rtl_request_uncached_firmware(struct rtl8169_private *tp)
@@ -8183,6 +8185,7 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
 				     PCIE_LINK_STATE_CLKPM);
 
+	mdelay(RTL8169_EE_TIMEOUT);
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
-- 
2.5.0
