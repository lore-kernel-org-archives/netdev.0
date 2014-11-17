From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 4/8] net: fec: change type of 'bufdesc_ex' to bool
Date: Mon, 17 Nov 2014 10:51:20 +0100
Message-ID: <1416217884-20911-5-git-send-email-LW@KARO-electronics.de>
References: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <fugang.duan@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53263 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbaKQJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 04:51:41 -0500
In-Reply-To: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fep->bufdesc_ex is treated as a boolean value, thus declare it as
such.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.h      |    2 +-
 drivers/net/ethernet/freescale/fec_main.c |    4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index 27e75cf..1418813 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -502,7 +502,7 @@ struct fec_enet_private {
 	int	speed;
 	struct	completion mdio_done;
 	int	irq[FEC_IRQ_NUM];
-	int	bufdesc_ex;
+	bool	bufdesc_ex;
 	int	pause_flag;
=20
 	struct	napi_struct napi;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 3dca494..f3a6379 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3184,8 +3184,6 @@ fec_probe(struct platform_device *pdev)
 	fep->pdev =3D pdev;
 	fep->dev_id =3D dev_id++;
=20
-	fep->bufdesc_ex =3D 0;
-
 	platform_set_drvdata(pdev, ndev);
=20
 	phy_node =3D of_parse_phandle(np, "phy-handle", 0);
@@ -3243,7 +3241,7 @@ fec_probe(struct platform_device *pdev)
 		pdev->id_entry->driver_data & FEC_QUIRK_HAS_BUFDESC_EX;
 	if (IS_ERR(fep->clk_ptp)) {
 		fep->clk_ptp =3D NULL;
-		fep->bufdesc_ex =3D 0;
+		fep->bufdesc_ex =3D false;
 	}
=20
 	ret =3D fec_enet_clk_enable(ndev, true);
--=20
1.7.10.4
