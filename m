From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 2/3] [IrDA] smsc-ircc: More laptops detected
Date: Wed, 20 Sep 2006 08:09:04 +0300
Message-ID: <20060920050904.GD4140@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	"Linus Walleij (LD/EAB)" <linus.walleij@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:34204 "EHLO smtp6.pp.htv.fi")
	by vger.kernel.org with ESMTP id S1751107AbWISVyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:54:32 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch detects the smsc-ircc chipset on the nx1000 
(including nx7000 and nx7010) and the nx5000 HP/Compaq laptop series.

Patch from "Linus Walleij (LD/EAB)" <linus.walleij@ericsson.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 drivers/net/irda/smsc-ircc2.c |   38 ++++++++++++++++++++++++++++++++++++--
 1 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 2eff45b..22358ff 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -2354,6 +2354,26 @@ #ifdef CONFIG_PCI
 #define PCIID_VENDOR_INTEL 0x8086
 #define PCIID_VENDOR_ALI 0x10b9
 static struct smsc_ircc_subsystem_configuration subsystem_configurations[] __initdata = {
+	/*
+	 * Subsystems needing entries:
+	 * 0x10b9:0x1533 0x103c:0x0850 HP nx9010 family
+	 * 0x10b9:0x1533 0x0e11:0x005a Compaq nc4000 family
+	 * 0x8086:0x24cc 0x0e11:0x002a HP nx9000 family
+	 */
+	{
+		/* Guessed entry */
+		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.device = 0x24cc,
+		.subvendor = 0x103c,
+		.subdevice = 0x08bc,
+		.sir_io = 0x02f8,
+		.fir_io = 0x0130,
+		.fir_irq = 0x05,
+		.fir_dma = 0x03,
+		.cfg_base = 0x004e,
+		.preconfigure = preconfigure_through_82801,
+		.name = "HP nx5000 family",
+	},
 	{
 		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
 		.device = 0x24cc,
@@ -2366,7 +2386,7 @@ static struct smsc_ircc_subsystem_config
 		.fir_dma = 0x03,
 		.cfg_base = 0x004e,
 		.preconfigure = preconfigure_through_82801,
-		.name = "HP nc8000",
+		.name = "HP nc8000 family",
 	},
 	{
 		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
@@ -2379,7 +2399,21 @@ static struct smsc_ircc_subsystem_config
 		.fir_dma = 0x03,
 		.cfg_base = 0x004e,
 		.preconfigure = preconfigure_through_82801,
-		.name = "HP nc6000",
+		.name = "HP nc6000 family",
+	},
+	{
+		.vendor = PCIID_VENDOR_INTEL, /* Intel 82801DBM LPC bridge */
+		.device = 0x24cc,
+		.subvendor = 0x0e11,
+		.subdevice = 0x0860,
+		/* I assume these are the same for x1000 as for the others */
+		.sir_io = 0x02e8,
+		.fir_io = 0x02f8,
+		.fir_irq = 0x07,
+		.fir_dma = 0x03,
+		.cfg_base = 0x002e,
+		.preconfigure = preconfigure_through_82801,
+		.name = "Compaq x1000 family",
 	},
 	{
 		/* Intel 82801DB/DBL (ICH4/ICH4-L) LPC Interface Bridge */
-- 
1.4.1.1

