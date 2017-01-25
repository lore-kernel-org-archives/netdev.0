From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 3/3] net: phy: bcm-phy-lib: clean up remaining AUXCTL register defines
Date: Wed, 25 Jan 2017 21:00:27 +0100
Message-ID: <20170125200027.14387-4-zajec5@gmail.com>
References: <20170125200027.14387-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33826 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752091AbdAYUA5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 15:00:57 -0500
Received: by mail-lf0-f67.google.com with SMTP id q89so22070719lfi.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 12:00:52 -0800 (PST)
In-Reply-To: <20170125200027.14387-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

1) Use 0x%02x format for register number. This follows some other
   defines and makes it easier to distinct register from values.
2) Put register define above values and sort the values. It makes
   reading header code easier.
3) Use 0x%04x format for all values. It's about consistency with other
   values (and most of the header) not a personal preference.
4) Separate define for reading shift value with an extre empty line.
   It's user for all AUXCTL registers in a bcm54xx_auxctl_read.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
V2: Don't drop SHDWSEL_ as it seems to be used in datasheet. Thanks Florian.
---
 include/linux/brcmphy.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index f9cb73df127e..cf93f1399d3e 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -104,17 +104,17 @@
 /*
  * AUXILIARY CONTROL SHADOW ACCESS REGISTERS.  (PHY REG 0x18)
  */
-#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
+#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x00
 #define MII_BCM54XX_AUXCTL_ACTL_TX_6DB		0x0400
 #define MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA	0x0800
 
-#define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
-#define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
-#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
-#define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
-#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN	(1 << 8)
-#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN	(1 << 4)
+#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC			0x07
+#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN	0x0010
+#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN	0x0100
+#define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX		0x0200
+#define MII_BCM54XX_AUXCTL_MISC_WREN			0x8000
 
+#define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MASK	0x0007
 
 /*
-- 
2.11.0
