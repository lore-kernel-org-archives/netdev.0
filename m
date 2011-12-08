From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH v3 6/8] net/fec: preserve MII/RMII setting in fec_stop()
Date: Thu,  8 Dec 2011 08:59:30 +0100
Message-ID: <d6f4de9e4cfb393754b42815a2ef1a59c96eab83.1323326019.git.LW@KARO-electronics.de>
References: <cover.1323326019.git.LW@KARO-electronics.de>
 <bd4415514fa0b40ece04d56b3ac4f549e79d87d7.1323326019.git.LW@KARO-electronics.de>
 <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323326019.git.LW@KARO-electronics.de>
 <0b92136d69e509a6ce49b526e1834f0ec90b04a4.1323326019.git.LW@KARO-electronics.de>
 <6d1e5cdcbfc48df864ec9e0939645c0e95389d2a.1323326019.git.LW@KARO-electronics.de>
 <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323326019.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Shawn Guo <shawn.guo@linaro.org>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323326019.git.LW@KARO-electronics.de>
In-Reply-To: <cover.1323326019.git.LW@KARO-electronics.de>
References: <cover.1323326019.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Additionally to setting the ETHER_EN bit in FEC_ECNTRL the MII/RMII
setting in FEC_R_CNTRL needs to be preserved to keep the MII interface
functional.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Tested-by: Shawn Guo <shawn.guo@linaro.org>
Acked-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/etherne=
t/freescale/fec.c
index 11534b9..ab0afb5 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -515,6 +515,7 @@ fec_stop(struct net_device *ndev)
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	const struct platform_device_id *id_entry =3D
 				platform_get_device_id(fep->pdev);
+	u32 rmii_mode =3D readl(fep->hwp + FEC_R_CNTRL) & (1 << 8);
=20
 	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
@@ -531,8 +532,10 @@ fec_stop(struct net_device *ndev)
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
=20
 	/* We have to keep ENET enabled to have MII interrupt stay working */
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
 		writel(2, fep->hwp + FEC_ECNTRL);
+		writel(rmii_mode, fep->hwp + FEC_R_CNTRL);
+	}
 }
=20
=20
--=20
1.5.6.5
