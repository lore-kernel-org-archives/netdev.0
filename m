From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [RESEND][PATCH next 2/2] bgmac: use phy_mii_ioctl in ioctl handler
Date: Fri, 20 Dec 2013 15:34:45 +0100
Message-ID: <1387550085-32432-1-git-send-email-zajec5@gmail.com>
References: <1386668966-24562-2-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:52207 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab3LTOex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:34:53 -0500
Received: by mail-ee0-f45.google.com with SMTP id d49so1076476eek.18
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:34:52 -0800 (PST)
In-Reply-To: <1386668966-24562-2-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hauke Mehrtens <hauke@hauke-m.de>

This works pretty much the same way, so avoid duplicating the code.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
This ports part of Hauke's patch from OpenWrt.

Hauks: I've just dropped
if (!bgmac->phydev)
	return -EINVAL;
as we are guaranteed to have PHY dev.
---
 drivers/net/ethernet/broadcom/bgmac.c |   26 +++++--------------------=
-
 1 file changed, 5 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 3cd5d68..39efb86 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1198,27 +1198,11 @@ static int bgmac_set_mac_address(struct net_dev=
ice *net_dev, void *addr)
 static int bgmac_ioctl(struct net_device *net_dev, struct ifreq *ifr, =
int cmd)
 {
 	struct bgmac *bgmac =3D netdev_priv(net_dev);
-	struct mii_ioctl_data *data =3D if_mii(ifr);
-
-	switch (cmd) {
-	case SIOCGMIIPHY:
-		data->phy_id =3D bgmac->phyaddr;
-		/* fallthru */
-	case SIOCGMIIREG:
-		if (!netif_running(net_dev))
-			return -EAGAIN;
-		data->val_out =3D bgmac_phy_read(bgmac, data->phy_id,
-					       data->reg_num & 0x1f);
-		return 0;
-	case SIOCSMIIREG:
-		if (!netif_running(net_dev))
-			return -EAGAIN;
-		bgmac_phy_write(bgmac, data->phy_id, data->reg_num & 0x1f,
-				data->val_in);
-		return 0;
-	default:
-		return -EOPNOTSUPP;
-	}
+
+	if (!netif_running(net_dev))
+		return -EINVAL;
+
+	return phy_mii_ioctl(bgmac->phy_dev, ifr, cmd);
 }
=20
 static const struct net_device_ops bgmac_netdev_ops =3D {
--=20
1.7.10.4
