From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next v2 2/5] dp83640: Increase supported perout pins to 7
Date: Fri, 27 Jun 2014 12:05:30 +0200
Message-ID: <1403863533-27675-3-git-send-email-stefan.sorensen@spectralink.com>
References: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:52645 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753158AbaF0KGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:06:04 -0400
In-Reply-To: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch increases the number of supported periodic output pins from
1 to 7. The last pin is reserved for sync.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index fcd50b77..eabecff 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -40,6 +40,7 @@
 #define LAYER2		0x01
 #define MAX_RXTS	64
 #define N_EXT_TS	6
+#define N_PER_OUT	7
 #define PSF_PTPVER	2
 #define PSF_EVNT	0x4000
 #define PSF_RX		0x2000
@@ -47,7 +48,6 @@
 #define EXT_EVENT	1
 #define CAL_EVENT	7
 #define CAL_TRIGGER	7
-#define PER_TRIGGER	6
 #define DP83640_N_PINS	12
=20
 #define MII_DP83640_MICR 0x11
@@ -300,23 +300,23 @@ static u64 phy2txts(struct phy_txts *p)
 }
=20
 static int periodic_output(struct dp83640_clock *clock,
-			   struct ptp_clock_request *clkreq, bool on)
+			   struct ptp_clock_request *clkreq, bool on,
+			   int trigger)
 {
 	struct dp83640_private *dp83640 =3D clock->chosen;
 	struct phy_device *phydev =3D dp83640->phydev;
 	u32 sec, nsec, pwidth;
-	u16 gpio, ptp_trig, trigger, val;
+	u16 gpio, ptp_trig, val;
=20
 	if (on) {
-		gpio =3D 1 + ptp_find_pin(clock->ptp_clock, PTP_PF_PEROUT, 0);
+		gpio =3D 1 + ptp_find_pin(clock->ptp_clock, PTP_PF_PEROUT,
+					trigger);
 		if (gpio < 1)
 			return -EINVAL;
 	} else {
 		gpio =3D 0;
 	}
=20
-	trigger =3D PER_TRIGGER;
-
 	ptp_trig =3D TRIG_WR |
 		(trigger & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT |
 		(gpio & TRIG_GPIO_MASK) << TRIG_GPIO_SHIFT |
@@ -496,9 +496,9 @@ static int ptp_dp83640_enable(struct ptp_clock_info=
 *ptp,
 		return 0;
=20
 	case PTP_CLK_REQ_PEROUT:
-		if (rq->perout.index !=3D 0)
+		if (rq->perout.index >=3D N_PER_OUT)
 			return -EINVAL;
-		return periodic_output(clock, rq, on);
+		return periodic_output(clock, rq, on, rq->perout.index);
=20
 	default:
 		break;
@@ -949,7 +949,7 @@ static void dp83640_clock_init(struct dp83640_clock=
 *clock, struct mii_bus *bus)
 	clock->caps.max_adj	=3D 1953124;
 	clock->caps.n_alarm	=3D 0;
 	clock->caps.n_ext_ts	=3D N_EXT_TS;
-	clock->caps.n_per_out	=3D 1;
+	clock->caps.n_per_out	=3D N_PER_OUT;
 	clock->caps.n_pins	=3D DP83640_N_PINS;
 	clock->caps.pps		=3D 0;
 	clock->caps.adjfreq	=3D ptp_dp83640_adjfreq;
--=20
1.9.3
