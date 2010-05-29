From: Tzafrir Cohen <tzafrir.cohen@xorcom.com>
Subject: [PATCH] Exclude DAHDI devices from being probed by netjet
Date: Sun, 30 May 2010 02:29:46 +0300
Message-ID: <20100529232946.GA1748@xorcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from local.xorcom.com ([62.90.10.53]:52308 "EHLO local.xorcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756072Ab0E2XiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 19:38:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many early Zaptel / DAHDI devices were based on the same Netjet PCI
chipset. However they are not the ISDN BRI adapters the netjet driver
expects to driver.

The patch excludes devices based solely on sub-vendor ID. It seems that
all of those drivers probe for that, and I don't have a better way to
check what are the exact sub-product IDs.

Notes:
1. It seems that the same change need also be applied to some hisax
   (i4l) drivers.
2. I don't have more precise data than the PCI ID tables in the drivers.
   Does this run the risk of excluding some actual Netjet ISDN cards?
3. A more informative failure message may help (if one is actually needed).
4. The MAINTAINERS file lists the git tree
   git://git.kernel.org/pub/scm/linux/kernel/git/kkeil/isdn-2.6.git but
   it does not seem to exist.

Signed-off-by: Tzafrir Cohen <tzafrir.cohen@xorcom.com>
---
 drivers/isdn/hardware/mISDN/netjet.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index 0a3553d..42dded4 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1060,9 +1060,33 @@ nj_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int cfg;
 	struct tiger_hw *card;
 
-	if (pdev->subsystem_vendor == 0x8086 &&
-	    pdev->subsystem_device == 0x0003) {
-		pr_notice("Netjet: Digium X100P/X101P not handled\n");
+	switch (pdev->subsystem_vendor) {
+	/* Fall-through */
+	case 0x2151: /* Yeastart YSTDM8xx (ystdm8xx) */
+	case 0xe16b: /* Zapata Project PCI-Radio (pciradio) */
+	case 0x6159: /* Digium Wildcard T100/E100 (wct1xxp) */
+	case 0x71fe: /* Digium Wildcard TE110P (wcte1xp) */
+	case 0x795e: /* Digium Wildcard TE110P (wcte1xp) */
+	case 0x797e: /* Digium Wildcard TE110P (wcte1xp) */
+	case 0x79de: /* Digium Wildcard TE110P (wcte1xp) */
+	case 0x79df: /* Digium Wildcard TE110P (wcte1xp) */
+	case 0x8084: /* Digium Wildcard X101P clone (wcfxo) */
+	case 0x8085: /* Digium Wildcard X101P (wcfxo) */
+	case 0x8086: /* Digium Wildcard X101P clone (wcfxo) */
+	case 0x8087: /* Digium Wildcard X101P clone (wcfxo) */
+	case 0xa800: /* Digium Wildcard TDM400P Rev H (wctdm) */
+	case 0xa801: /* Digium Wildcard TDM400P Rev H (wctdm) */
+	case 0xa8fd: /* Digium Wildcard TDM400P Rev H (wctdm) */
+	case 0xa901: /* Digium Wildcard TDM400P Rev H (wctdm) */
+	case 0xa908: /* Digium Wildcard TDM400P Rev H (wctdm) */
+	case 0xa9fd: /* Digium Wildcard TDM400P Rev H (wctdm) */
+	case 0xb100: /* Digium Wildcard TDM400P Rev E/F (wctdm) */
+	case 0xb118: /* Digium Wildcard TDM400P Rev I (wctdm) */
+	case 0xb119: /* Digium Wildcard TDM400P Rev I (wctdm) */
+	case 0xb1d9: /* Digium Wildcard TDM400P Rev I (wctdm) */
+	case 0xa159: /* Digium Wildcard S400P Prototype (wctdm) */
+	case 0xe159: /* Digium Wildcard S400P Prototype (wctdm) */
+		pr_notice("Netjet: DAHDI device not supported.\n");
 		return -ENODEV;
 	}
 
-- 
1.7.1


-- 
               Tzafrir Cohen
icq#16849755              jabber:tzafrir.cohen@xorcom.com
+972-50-7952406           mailto:tzafrir.cohen@xorcom.com
http://www.xorcom.com  iax:guest@local.xorcom.com/tzafrir
