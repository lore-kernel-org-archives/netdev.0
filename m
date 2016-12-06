From: Alexandru Gagniuc <alex.g@adaptrum.com>
Subject: [PATCH] drivers: net: cpsw-phy-sel: Clear RGMII_IDMODE on "rgmii" links
Date: Mon,  5 Dec 2016 17:33:53 -0800
Message-ID: <1480988033-16535-1-git-send-email-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gokhan@adaptrum.com, Alexandru Gagniuc <alex.g@adaptrum.com>
To: mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support for setting the RGMII_IDMODE bit was added in commit:
"drivers: net: cpsw-phy-sel: add support to configure rgmii internal delay"
However, that commit did not add the symmetrical clearing of the bit
by way of setting it in "mask". Add it here.

Note that the documentation marks clearing this bit as "reserved",
however, according to TI, support for delaying the clock does exist in
the MAC, although it is not officially supported.
We tested this on a board with an RGMII to RGMII link that will not
work unless this bit is cleared.

Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
---
 drivers/net/ethernet/ti/cpsw-phy-sel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index ba1e45f..1801364 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -81,6 +81,7 @@ static void cpsw_gmii_sel_am3352(struct cpsw_phy_sel_priv *priv,
 	};
 
 	mask = GMII_SEL_MODE_MASK << (slave * 2) | BIT(slave + 6);
+	mask |= BIT(slave + 4);
 	mode <<= slave * 2;
 
 	if (priv->rmii_clock_external) {
-- 
2.7.4
