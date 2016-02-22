From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH net-next] bgmac: support Ethernet device on BCM47094 SoC
Date: Mon, 22 Feb 2016 22:51:13 +0100
Message-ID: <1456177873-29246-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33694 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705AbcBVVvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 16:51:22 -0500
Received: by mail-lf0-f45.google.com with SMTP id m1so104078882lfg.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 13:51:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It needs very similar workarounds to the one on BCM4707. It was tested
on D-Link DIR-885L home router.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
It's the same patch as last time, just with a proper prefix ("net-next"=
)
---
 drivers/net/ethernet/broadcom/bgmac.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 230f8e6..99b30a9 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -30,6 +30,7 @@ static inline bool bgmac_is_bcm4707_family(struct bgm=
ac *bgmac)
 {
 	switch (bgmac->core->bus->chipinfo.id) {
 	case BCMA_CHIP_ID_BCM4707:
+	case BCMA_CHIP_ID_BCM47094:
 	case BCMA_CHIP_ID_BCM53018:
 		return true;
 	default:
@@ -1052,8 +1053,9 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg =3D=3D BCMA_PKG_I=
D_BCM47188))
 		iost &=3D ~BGMAC_BCMA_IOST_ATTACHED;
=20
-	/* 3GMAC: for BCM4707, only do core reset at bgmac_probe() */
-	if (ci->id !=3D BCMA_CHIP_ID_BCM4707) {
+	/* 3GMAC: for BCM4707 & BCM47094, only do core reset at bgmac_probe()=
 */
+	if (ci->id !=3D BCMA_CHIP_ID_BCM4707 &&
+	    ci->id !=3D BCMA_CHIP_ID_BCM47094) {
 		flags =3D 0;
 		if (iost & BGMAC_BCMA_IOST_ATTACHED) {
 			flags =3D BGMAC_BCMA_IOCTL_SW_CLKEN;
--=20
1.8.4.5
