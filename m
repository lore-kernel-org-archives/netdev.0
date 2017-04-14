From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH -next] net: phy: test the right variable in phy_write_mmd()
Date: Fri, 14 Apr 2017 22:10:41 +0300
Message-ID: <20170414191041.GA27478@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35754 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdDNTLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 15:11:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a copy and paste buglet.  We meant to test for ->write_mmd but
we test for ->read_mmd.

Fixes: 1ee6b9bc6206 ("net: phy: make phy_(read|write)_mmd() generic MMD accessors")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index 357a4d0d7641..6739b738bbaf 100644
--- a/drivers/net/phy/phy-core.c
+++ b/drivers/net/phy/phy-core.c
@@ -76,7 +76,7 @@ int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val)
 	if (regnum > (u16)~0 || devad > 32)
 		return -EINVAL;
 
-	if (phydev->drv->read_mmd) {
+	if (phydev->drv->write_mmd) {
 		ret = phydev->drv->write_mmd(phydev, devad, regnum, val);
 	} else if (phydev->is_c45) {
 		u32 addr = MII_ADDR_C45 | (devad << 16) | (regnum & 0xffff);
