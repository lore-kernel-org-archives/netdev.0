From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 1/2] bgmac: drop duplicated PHY defines
Date: Tue, 10 Dec 2013 10:49:25 +0100
Message-ID: <1386668966-24562-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:44238 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636Ab3LJJtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 04:49:36 -0500
Received: by mail-ea0-f173.google.com with SMTP id o10so2068649eaj.18
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 01:49:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |    6 ++----
 drivers/net/ethernet/broadcom/bgmac.h |   21 ---------------------
 2 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 0452937..ad4b2f1 100644
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
index 550f2a8..1c752ce 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -216,27 +216,6 @@
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
