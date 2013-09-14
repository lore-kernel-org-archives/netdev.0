From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: fix internal switch initialization
Date: Sun, 15 Sep 2013 00:22:47 +0200
Message-ID: <1379197367-19116-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	stable@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some devices (BCM4749, BCM5357, BCM53572) have internal switch that
requires initialization. We already have code for this, but because
of the typo in code it was never working. This resulted in network not
working for some routers and possibility of soft-bricking them.

Use correct bit for switch initialization and fix typo in the define.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Cc: stable@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bgmac.c |    2 +-
 drivers/net/ethernet/broadcom/bgmac.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index eec0af4..1c6bc96 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -908,7 +908,7 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 		struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
 		u8 et_swtype =3D 0;
 		u8 sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHY |
-			     BGMAC_CHIPCTL_1_IF_TYPE_RMII;
+			     BGMAC_CHIPCTL_1_IF_TYPE_MII;
 		char buf[2];
=20
 		if (bcm47xx_nvram_getenv("et_swtype", buf, 1) > 0) {
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 98d4b5f..12a35cf 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -333,7 +333,7 @@
=20
 #define BGMAC_CHIPCTL_1_IF_TYPE_MASK		0x00000030
 #define BGMAC_CHIPCTL_1_IF_TYPE_RMII		0x00000000
-#define BGMAC_CHIPCTL_1_IF_TYPE_MI		0x00000010
+#define BGMAC_CHIPCTL_1_IF_TYPE_MII		0x00000010
 #define BGMAC_CHIPCTL_1_IF_TYPE_RGMII		0x00000020
 #define BGMAC_CHIPCTL_1_SW_TYPE_MASK		0x000000C0
 #define BGMAC_CHIPCTL_1_SW_TYPE_EPHY		0x00000000
--=20
1.7.10.4
