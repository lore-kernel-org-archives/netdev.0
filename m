From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [BUGFIX PATCH] net: ethernet: cpsw: fix erroneous condition in error check
Date: Thu, 21 Mar 2013 13:20:11 +0100
Message-ID: <1363868411-25318-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The error check in cpsw_probe_dt() has an '&&' where an '||' is
meant to be. This causes a NULL pointer dereference when incomplet DT
data is passed to the driver ('phy_id' property for cpsw_emac1
missing).


Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/ti/cpsw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/c=
psw.c
index 5ceaa4c3..7aebc0c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1504,7 +1504,7 @@ static int cpsw_probe_dt(struct cpsw_platform_dat=
a *data,
 		struct platform_device *mdio;
=20
 		parp =3D of_get_property(slave_node, "phy_id", &lenp);
-		if ((parp =3D=3D NULL) && (lenp !=3D (sizeof(void *) * 2))) {
+		if ((parp =3D=3D NULL) || (lenp !=3D (sizeof(void *) * 2))) {
 			pr_err("Missing slave[%d] phy_id property\n", i);
 			ret =3D -EINVAL;
 			goto error_ret;
--=20
1.7.2.5
