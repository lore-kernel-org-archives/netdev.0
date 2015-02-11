From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH FIX] bgmac: fix device initialization on Northstar SoCs (condition typo)
Date: Wed, 11 Feb 2015 18:06:34 +0100
Message-ID: <1423674394-8578-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:62502 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbbBKRGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 12:06:47 -0500
Received: by mail-wi0-f171.google.com with SMTP id hi2so13726763wib.4
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 09:06:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Northstar (Broadcom's ARM architecture) we need to manually enable
all cores. Code for that is already in place, but the condition for it
was wrong.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
Can we have it for 3.20, please?
---
 drivers/net/ethernet/broadcom/bgmac.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 3007d95..728373b 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1412,6 +1412,7 @@ static void bgmac_mii_unregister(struct bgmac *bg=
mac)
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipattach */
 static int bgmac_probe(struct bcma_device *core)
 {
+	struct bcma_chipinfo *ci =3D &core->bus->chipinfo;
 	struct net_device *net_dev;
 	struct bgmac *bgmac;
 	struct ssb_sprom *sprom =3D &core->bus->sprom;
@@ -1474,8 +1475,8 @@ static int bgmac_probe(struct bcma_device *core)
 	bgmac_chip_reset(bgmac);
=20
 	/* For Northstar, we have to take all GMAC core out of reset */
-	if (core->id.id =3D=3D BCMA_CHIP_ID_BCM4707 ||
-	    core->id.id =3D=3D BCMA_CHIP_ID_BCM53018) {
+	if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
+	    ci->id =3D=3D BCMA_CHIP_ID_BCM53018) {
 		struct bcma_device *ns_core;
 		int ns_gmac;
=20
--=20
1.8.4.5
