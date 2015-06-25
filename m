From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] drivers: net: xgene: Pre-initialize ret in xgene_enet_get_resources()
Date: Thu, 25 Jun 2015 15:13:29 +0200
Message-ID: <1435238009-29037-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Suman Tripathi <stripathi@apm.com>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_ACPI=3Dn:

    drivers/net/ethernet/apm/xgene/xgene_enet_main.c: In function =E2=80=
=98xgene_enet_get_resources=E2=80=99:
    drivers/net/ethernet/apm/xgene/xgene_enet_main.c:951: warning: =E2=80=
=98ret=E2=80=99 may be used uninitialized in this function

If the driver is bound to a legacy platform device, ret will contain
arbitrary data. If it is non-zero, it will be returned to the caller as
an error code.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers=
/net/ethernet/apm/xgene/xgene_enet_main.c
index 95153b234c7158c6..299eb4315fe647ba 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -948,7 +948,7 @@ static int xgene_enet_get_resources(struct xgene_en=
et_pdata *pdata)
 	struct resource *res;
 	void __iomem *base_addr;
 	u32 offset;
-	int ret;
+	int ret =3D 0;
=20
 	pdev =3D pdata->pdev;
 	dev =3D &pdev->dev;
--=20
1.9.1
