From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v3 1/6] net: phy: broadcom: add bcm54xx_auxctl_read
Date: Tue,  1 Nov 2016 13:51:29 -0400
Message-ID: <1478022694-25308-2-git-send-email-jon.mason@broadcom.com>
References: <1478022694-25308-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478022694-25308-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a helper function to read the AUXCTL register for the BCM54xx.  This
mirrors the bcm54xx_auxctl_write function already present in the code.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/phy/broadcom.c | 10 ++++++++++
 include/linux/brcmphy.h    |  1 +
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 583ef8a..3a64b3d 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -30,6 +30,16 @@ MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
 
+static int bcm54xx_auxctl_read(struct phy_device *phydev, u16 regnum)
+{
+	/* The register must be written to both the Shadow Register Select and
+	 * the Shadow Read Register Selector
+	 */
+	phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum |
+		  regnum << MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT);
+	return phy_read(phydev, MII_BCM54XX_AUX_CTL);
+}
+
 static int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
 {
 	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 60def78..0ed6691 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -110,6 +110,7 @@
 #define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
 #define MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC	0x7000
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
+#define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
 
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MASK	0x0007
 
-- 
2.7.4
