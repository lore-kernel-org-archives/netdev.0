From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169:   Disable force bus mastering
Date: Mon,  1 Feb 2016 15:38:16 +0200
Message-ID: <1454333896-2609-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.78.245.184] ([82.78.245.184]:48733 "EHLO marian1000.go.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932183AbcBANix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 08:38:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not need to force on bus mastering , if alls is ok this is
enabled on BIOS.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index a8fb86d..8476659 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7915,7 +7915,6 @@ static void rtl_wol_shutdown_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_11:
 	case RTL_GIGA_MAC_VER_12:
 	case RTL_GIGA_MAC_VER_17:
-		pci_clear_master(tp->pci_dev);
 
 		RTL_W8(ChipCmd, CmdRxEnb);
 		/* PCI commit */
@@ -8256,7 +8255,6 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rtl_ack_events(tp, 0xffff);
 
-	pci_set_master(pdev);
 
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
-- 
2.5.0
