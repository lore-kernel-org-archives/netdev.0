From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Pouiller?= <jezz@sysmic.org>
Subject: [PATCH] net: phy: reset only targeted phy
Date: Thu,  3 Dec 2015 10:02:35 +0100
Message-ID: <1449133355-7668-1-git-send-email-jezz@sysmic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Pouiller?= <jezz@sysmic.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sysmic.org ([62.210.89.17]:53209 "EHLO lupi.sysmic.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932201AbbLCJJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 04:09:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible to address another chip on same MDIO bus. The case is
correctly handled for media advertising. It is taken into account
only if mii_data->phy_id =3D=3D phydev->addr. However, this condition
was missing for reset case.

Signed-off-by: J=C3=A9r=C3=B4me Pouiller <jezz@sysmic.org>
---
 drivers/net/phy/phy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 48ce6ef..47cd306 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -448,7 +448,8 @@ int phy_mii_ioctl(struct phy_device *phydev, struct=
 ifreq *ifr, int cmd)
 		mdiobus_write(phydev->bus, mii_data->phy_id,
 			      mii_data->reg_num, val);
=20
-		if (mii_data->reg_num =3D=3D MII_BMCR &&
+		if (mii_data->phy_id =3D=3D phydev->addr &&
+		    mii_data->reg_num =3D=3D MII_BMCR &&
 		    val & BMCR_RESET)
 			return phy_init_hw(phydev);
=20
--=20
2.6.2
