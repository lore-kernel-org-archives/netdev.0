From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [RESEND][PATCH next 1/2] bgmac: drop duplicated PHY defines
Date: Fri, 20 Dec 2013 15:33:52 +0100
Message-ID: <1387550032-32360-1-git-send-email-zajec5@gmail.com>
References: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:60996 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab3LTOeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:34:03 -0500
Received: by mail-ea0-f182.google.com with SMTP id a15so1103580eae.41
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:34:02 -0800 (PST)
In-Reply-To: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
In future we should try to remove bgmac_phy_reset and use phy_init_hw.
However this requires rewriting our fixups first.

Dave: I suspect you may lost this patchset, thus resending. If they are
just waiting in your queue for the right moment, sorry, I didn't mean t=
o
rush you!
---
 drivers/net/ethernet/broadcom/bgmac.c |    6 ++----
 drivers/net/ethernet/broadcom/bgmac.h |   21 ---------------------
 2 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index b665a6a..3cd5d68 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -725,11 +725,9 @@ static void bgmac_phy_reset(struct bgmac *bgmac)
 	if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
 		return;
=20
-	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL,
-			BGMAC_PHY_CTL_RESET);
+	bgmac_phy_write(bgmac, bgmac->phyaddr, MII_BMCR, BMCR_RESET);
 	udelay(100);
-	if (bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL) &
-	    BGMAC_PHY_CTL_RESET)
+	if (bgmac_phy_read(bgmac, bgmac->phyaddr, MII_BMCR) & BMCR_RESET)
 		bgmac_err(bgmac, "PHY reset failed\n");
 	bgmac_phy_init(bgmac);
 }
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 2d44119..130b16b 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -220,27 +220,6 @@
 #define BGMAC_RX_STATUS				0xb38
 #define BGMAC_TX_STATUS				0xb3c
=20
-#define BGMAC_PHY_CTL				0x00
-#define  BGMAC_PHY_CTL_SPEED_MSB		0x0040
-#define  BGMAC_PHY_CTL_DUPLEX			0x0100		/* duplex mode */
-#define  BGMAC_PHY_CTL_RESTART			0x0200		/* restart autonegotiation */
-#define  BGMAC_PHY_CTL_ANENAB			0x1000		/* enable autonegotiation */
-#define  BGMAC_PHY_CTL_SPEED			0x2000
-#define  BGMAC_PHY_CTL_LOOP			0x4000		/* loopback */
-#define  BGMAC_PHY_CTL_RESET			0x8000		/* reset */
-/* Helpers */
-#define  BGMAC_PHY_CTL_SPEED_10			0
-#define  BGMAC_PHY_CTL_SPEED_100		BGMAC_PHY_CTL_SPEED
-#define  BGMAC_PHY_CTL_SPEED_1000		BGMAC_PHY_CTL_SPEED_MSB
-#define BGMAC_PHY_ADV				0x04
-#define  BGMAC_PHY_ADV_10HALF			0x0020		/* advertise 10MBits/s half du=
plex */
-#define  BGMAC_PHY_ADV_10FULL			0x0040		/* advertise 10MBits/s full du=
plex */
-#define  BGMAC_PHY_ADV_100HALF			0x0080		/* advertise 100MBits/s half =
duplex */
-#define  BGMAC_PHY_ADV_100FULL			0x0100		/* advertise 100MBits/s full =
duplex */
-#define BGMAC_PHY_ADV2				0x09
-#define  BGMAC_PHY_ADV2_1000HALF		0x0100		/* advertise 1000MBits/s hal=
f duplex */
-#define  BGMAC_PHY_ADV2_1000FULL		0x0200		/* advertise 1000MBits/s ful=
l duplex */
-
 /* BCMA GMAC core specific IO Control (BCMA_IOCTL) flags */
 #define BGMAC_BCMA_IOCTL_SW_CLKEN		0x00000004	/* PHY Clock Enable */
 #define BGMAC_BCMA_IOCTL_SW_RESET		0x00000008	/* PHY Reset */
--=20
1.7.10.4
