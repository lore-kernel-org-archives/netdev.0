From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v3] isdn: Drop big endian cpp checks from telespci and hfc_pci drivers
Date: Sun,  5 Jan 2014 20:31:39 -0800
Message-ID: <1388982699-11514-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With arm:allmodconfig, building the Teles PCI driver fails with

telespci.c:294:2: error: #error "not running on big endian machines now"

Similar, building the driver for HFC PCI-Bus cards fails with

hfc_pci.c:1647:2: error: #error "not running on big endian machines now"

Remove the big endian cpp check from both drivers to fix the build errors.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v3: Instead of marking build as broken, remove cpp endianness checks.
    Updated headline to match the changes.

v2: Turns out CPU_LITTLE_ENDIAN is not defined for little-endian-only
    architectures. Instead of messing with the overall Kconfig architecture,
    mark build as broken for big endian ARM machines.
    Also updated headline accordingly.

 drivers/isdn/hisax/hfc_pci.c  |    4 ----
 drivers/isdn/hisax/telespci.c |    4 ----
 2 files changed, 8 deletions(-)

diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 497bd02..4a48255 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -1643,10 +1643,6 @@ setup_hfcpci(struct IsdnCard *card)
 	int i;
 	struct pci_dev *tmp_hfcpci = NULL;
 
-#ifdef __BIG_ENDIAN
-#error "not running on big endian machines now"
-#endif
-
 	strcpy(tmp, hfcpci_revision);
 	printk(KERN_INFO "HiSax: HFC-PCI driver Rev. %s\n", HiSax_getrev(tmp));
 
diff --git a/drivers/isdn/hisax/telespci.c b/drivers/isdn/hisax/telespci.c
index f6ab63a..33eeb46 100644
--- a/drivers/isdn/hisax/telespci.c
+++ b/drivers/isdn/hisax/telespci.c
@@ -290,10 +290,6 @@ int setup_telespci(struct IsdnCard *card)
 	struct IsdnCardState *cs = card->cs;
 	char tmp[64];
 
-#ifdef __BIG_ENDIAN
-#error "not running on big endian machines now"
-#endif
-
 	strcpy(tmp, telespci_revision);
 	printk(KERN_INFO "HiSax: Teles/PCI driver Rev. %s\n", HiSax_getrev(tmp));
 	if (cs->typ != ISDN_CTYPE_TELESPCI)
-- 
1.7.9.7
