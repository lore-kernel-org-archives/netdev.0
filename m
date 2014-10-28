From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv3 4/9] net: fec: declare bufdesc_ex flag as bool
Date: Tue, 28 Oct 2014 14:22:59 +0100
Message-ID: <1414502584-10583-5-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
 <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	<linux-arm-kernel@lists.infradead.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fep->bufdesc_ex is used as boolean flag; thus declare it as such.
Also remove an unnecessary initialization to 0.

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
index 50a851d..bb006e1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3169,8 +3169,6 @@ fec_probe(struct platform_device *pdev)
 	fep->pdev =3D pdev;
 	fep->dev_id =3D dev_id++;
=20
-	fep->bufdesc_ex =3D 0;
-
 	platform_set_drvdata(pdev, ndev);
=20
 	phy_node =3D of_parse_phandle(np, "phy-handle", 0);
@@ -3228,7 +3226,7 @@ fec_probe(struct platform_device *pdev)
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
