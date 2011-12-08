From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH v3 3/8] net/fec: prevent dobule restart of interface on FDX/HDX change
Date: Thu,  8 Dec 2011 08:59:27 +0100
Message-ID: <0b92136d69e509a6ce49b526e1834f0ec90b04a4.1323326019.git.LW@KARO-electronics.de>
References: <cover.1323326019.git.LW@KARO-electronics.de>
 <bd4415514fa0b40ece04d56b3ac4f549e79d87d7.1323326019.git.LW@KARO-electronics.de>
 <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323326019.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Shawn Guo <shawn.guo@linaro.org>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323326019.git.LW@KARO-electronics.de>
In-Reply-To: <cover.1323326019.git.LW@KARO-electronics.de>
References: <cover.1323326019.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon detection of a FDX/HDX change the interface is restarted twice.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Acked-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/etherne=
t/freescale/fec.c
index 65ee506..7ef408f 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -865,6 +865,8 @@ static void fec_enet_adjust_link(struct net_device =
*ndev)
 	if (phy_dev->link) {
 		if (fep->full_duplex !=3D phy_dev->duplex) {
 			fec_restart(ndev, phy_dev->duplex);
+			/* prevent unnecessary second fec_restart() below */
+			fep->link =3D phy_dev->link;
 			status_change =3D 1;
 		}
 	}
--=20
1.5.6.5
