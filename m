From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 8/13] tg3: Limit 5784 / 5764 to MAC LED mode
Date: Fri, 09 Nov 2007 16:38:56 -0800
Message-ID: <1194655137.5745.270.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1630 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbXKJAjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most 5784 / 5764 LED modes do not work as expected because of a hardware
bug.  This patch forces the LED mode to be in MAC LED mode.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b5c4799..bb3b734 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10610,6 +10610,9 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    tp->pdev->subsystem_vendor == PCI_VENDOR_ID_DELL)
 			tp->led_ctrl = LED_CTRL_MODE_PHY_2;
 
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0)
+			tp->led_ctrl = LED_CTRL_MODE_MAC;
+
 		if (nic_cfg & NIC_SRAM_DATA_CFG_EEPROM_WP) {
 			tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
 			if ((tp->pdev->subsystem_vendor ==


