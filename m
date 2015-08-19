From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH] net: xgene Remove xgene specific phy and MAC lookup functions
Date: Wed, 19 Aug 2015 13:56:42 -0500
Message-ID: <1440010602-5860-2-git-send-email-jeremy.linton@arm.com>
References: <1440010602-5860-1-git-send-email-jeremy.linton@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: stripathi@apm.com, kchudgar@apm.com,
	brian.brooks.arm@vger.kernel.org, netdev@vger.kernel.org,
	jeremy.linton@arm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:8412 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751308AbbHSS4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:56:55 -0400
In-Reply-To: <1440010602-5860-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the xgene_get_mac_address to device_get_mac_address(), and
xgene_get_phy_mode() to device_get_phy_mode().

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 38 ++------------------=
----
 1 file changed, 2 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net=
/ethernet/apm/xgene/xgene_enet_main.c
index 299eb43..4f68d19 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -905,40 +905,6 @@ static int xgene_get_port_id_dt(struct device *dev, st=
ruct xgene_enet_pdata *pda
 =09return ret;
 }
=20
-static int xgene_get_mac_address(struct device *dev,
-=09=09=09=09 unsigned char *addr)
-{
-=09int ret;
-
-=09ret =3D device_property_read_u8_array(dev, "local-mac-address", addr, 6=
);
-=09if (ret)
-=09=09ret =3D device_property_read_u8_array(dev, "mac-address",
-=09=09=09=09=09=09    addr, 6);
-=09if (ret)
-=09=09return -ENODEV;
-
-=09return ETH_ALEN;
-}
-
-static int xgene_get_phy_mode(struct device *dev)
-{
-=09int i, ret;
-=09char *modestr;
-
-=09ret =3D device_property_read_string(dev, "phy-connection-type",
-=09=09=09=09=09  (const char **)&modestr);
-=09if (ret)
-=09=09ret =3D device_property_read_string(dev, "phy-mode",
-=09=09=09=09=09=09  (const char **)&modestr);
-=09if (ret)
-=09=09return -ENODEV;
-
-=09for (i =3D 0; i < PHY_INTERFACE_MODE_MAX; i++) {
-=09=09if (!strcasecmp(modestr, phy_modes(i)))
-=09=09=09return i;
-=09}
-=09return -ENODEV;
-}
=20
 static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 {
@@ -998,12 +964,12 @@ static int xgene_enet_get_resources(struct xgene_enet=
_pdata *pdata)
 =09if (ret)
 =09=09return ret;
=20
-=09if (xgene_get_mac_address(dev, ndev->dev_addr) !=3D ETH_ALEN)
+=09if (!device_get_mac_address(dev, ndev->dev_addr, ETH_ALEN))
 =09=09eth_hw_addr_random(ndev);
=20
 =09memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
=20
-=09pdata->phy_mode =3D xgene_get_phy_mode(dev);
+=09pdata->phy_mode =3D device_get_phy_mode(dev);
 =09if (pdata->phy_mode < 0) {
 =09=09dev_err(dev, "Unable to get phy-connection-type\n");
 =09=09return pdata->phy_mode;
--=20
2.4.3
