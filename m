From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH net-next] bgmac: replace some magic values with defines
Date: Wed, 11 Dec 2013 08:44:37 +0100
Message-ID: <1386747877-2327-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:49183 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3LKHoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 02:44:46 -0500
Received: by mail-ee0-f53.google.com with SMTP id b57so2649358eek.26
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 23:44:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
David: this patch adds few wide lines (over 80 chars). This was needed
to improve code readability, I believe this case matches CodingStyle
allowed exception. Thanks to that we keep one chip identification per
line. I believe it's important here as we use similar names (like
BCMA_CHIP_ID vs. BCMA_PKG_ID) and putting them in separated lines make
code a bit messy.

Can you accept that?
---
 drivers/net/ethernet/broadcom/bgmac.c |   21 +++++++++++++--------
 drivers/net/ethernet/broadcom/bgmac.h |    6 +++++-
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 5b5ac71..39efb86 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -875,9 +875,9 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	}
=20
 	iost =3D bcma_aread32(core, BCMA_IOST);
-	if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg =3D=3D 10) ||
+	if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg =3D=3D BCMA_PKG_ID=
_BCM47186) ||
 	    (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg =3D=3D 10) ||
-	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg =3D=3D 9))
+	    (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg =3D=3D BCMA_PKG_I=
D_BCM47188))
 		iost &=3D ~BGMAC_BCMA_IOST_ATTACHED;
=20
 	if (iost & BGMAC_BCMA_IOST_ATTACHED) {
@@ -889,12 +889,16 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	bcma_core_enable(core, flags);
=20
 	if (core->id.rev > 2) {
-		bgmac_set(bgmac, BCMA_CLKCTLST, 1 << 8);
-		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST, 1 << 24, 1 << 24,
+		bgmac_set(bgmac, BCMA_CLKCTLST,
+			  BGMAC_BCMA_CLKCTLST_MISC_PLL_REQ);
+		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST,
+				 BGMAC_BCMA_CLKCTLST_MISC_PLL_ST,
+				 BGMAC_BCMA_CLKCTLST_MISC_PLL_ST,
 				 1000);
 	}
=20
-	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 || ci->id =3D=3D BCMA_CHIP_ID_=
BCM4749 ||
+	if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 ||
+	    ci->id =3D=3D BCMA_CHIP_ID_BCM4749 ||
 	    ci->id =3D=3D BCMA_CHIP_ID_BCM53572) {
 		struct bcma_drv_cc *cc =3D &bgmac->core->bus->drv_cc;
 		u8 et_swtype =3D 0;
@@ -909,10 +913,11 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			et_swtype &=3D 0x0f;
 			et_swtype <<=3D 4;
 			sw_type =3D et_swtype;
-		} else if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg =3D=3D 9) {
+		} else if (ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg =3D=3D BCMA=
_PKG_ID_BCM5358) {
 			sw_type =3D BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII;
-		} else if ((ci->id !=3D BCMA_CHIP_ID_BCM53572 && ci->pkg =3D=3D 10) =
||
-			   (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg =3D=3D 9)) {
+		} else if ((ci->id =3D=3D BCMA_CHIP_ID_BCM5357 && ci->pkg =3D=3D BCM=
A_PKG_ID_BCM47186) ||
+			   (ci->id =3D=3D BCMA_CHIP_ID_BCM4749 && ci->pkg =3D=3D 10) ||
+			   (ci->id =3D=3D BCMA_CHIP_ID_BCM53572 && ci->pkg =3D=3D BCMA_PKG_=
ID_BCM47188)) {
 			sw_type =3D BGMAC_CHIPCTL_1_IF_TYPE_RGMII |
 				  BGMAC_CHIPCTL_1_SW_TYPE_RGMII;
 		}
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 1c752ce..130b16b 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -95,7 +95,11 @@
 #define  BGMAC_RXQ_CTL_MDP_SHIFT		24
 #define BGMAC_GPIO_SELECT			0x194
 #define BGMAC_GPIO_OUTPUT_EN			0x198
-/* For 0x1e0 see BCMA_CLKCTLST */
+
+/* For 0x1e0 see BCMA_CLKCTLST. Below are BGMAC specific bits */
+#define  BGMAC_BCMA_CLKCTLST_MISC_PLL_REQ	0x00000100
+#define  BGMAC_BCMA_CLKCTLST_MISC_PLL_ST	0x01000000
+
 #define BGMAC_HW_WAR				0x1e4
 #define BGMAC_PWR_CTL				0x1e8
 #define BGMAC_DMA_BASE0				0x200		/* Tx and Rx controller */
--=20
1.7.10.4
