From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] can: mpc5xxx_can: fix section type conflict
Date: Thu,  4 Oct 2012 19:57:22 +0200
Message-ID: <1349373442-11128-4-git-send-email-mkl@pengutronix.de>
References: <1349373442-11128-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1349373442-11128-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit:
    6d99c4c can: mpc5xxx_can: make data used as *of_device_id.data cons=
t

both "struct mpc5xxx_can_data mpc5200_can_data" and "mpc5121_can_data" =
are
marked as "const" but also as "__devinitdata". This leads to the follow=
ing
compile error:

drivers/net/can/mscan/mpc5xxx_can.c:383: error: mpc5200_can_data causes=
 a section type conflict
drivers/net/can/mscan/mpc5xxx_can.c:383: error: mpc5200_can_data causes=
 a section type conflict
drivers/net/can/mscan/mpc5xxx_can.c:388: error: mpc5121_can_data causes=
 a section type conflict
drivers/net/can/mscan/mpc5xxx_can.c:388: error: mpc5121_can_data causes=
 a section type conflict

This patch changes the "__devinitdata" to "__devinitconst" and marks th=
e
"struct of_device_id mpc5xxx_can_table" as "const" and "__devinitconst"=
, too.

Acked-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/mscan/mpc5xxx_can.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/msca=
n/mpc5xxx_can.c
index c975999..799c354 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -247,7 +247,7 @@ static u32 __devinit mpc512x_can_get_clock(struct p=
latform_device *ofdev,
 }
 #endif /* CONFIG_PPC_MPC512x */
=20
-static struct of_device_id mpc5xxx_can_table[];
+static const struct of_device_id mpc5xxx_can_table[];
 static int __devinit mpc5xxx_can_probe(struct platform_device *ofdev)
 {
 	const struct of_device_id *match;
@@ -380,17 +380,17 @@ static int mpc5xxx_can_resume(struct platform_dev=
ice *ofdev)
 }
 #endif
=20
-static const struct mpc5xxx_can_data __devinitdata mpc5200_can_data =3D=
 {
+static const struct mpc5xxx_can_data __devinitconst mpc5200_can_data =3D=
 {
 	.type =3D MSCAN_TYPE_MPC5200,
 	.get_clock =3D mpc52xx_can_get_clock,
 };
=20
-static const struct mpc5xxx_can_data __devinitdata mpc5121_can_data =3D=
 {
+static const struct mpc5xxx_can_data __devinitconst mpc5121_can_data =3D=
 {
 	.type =3D MSCAN_TYPE_MPC5121,
 	.get_clock =3D mpc512x_can_get_clock,
 };
=20
-static struct of_device_id __devinitdata mpc5xxx_can_table[] =3D {
+static const struct of_device_id __devinitconst mpc5xxx_can_table[] =3D=
 {
 	{ .compatible =3D "fsl,mpc5200-mscan", .data =3D &mpc5200_can_data, }=
,
 	/* Note that only MPC5121 Rev. 2 (and later) is supported */
 	{ .compatible =3D "fsl,mpc5121-mscan", .data =3D &mpc5121_can_data, }=
,
--=20
1.7.10

