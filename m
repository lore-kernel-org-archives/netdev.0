From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] drivers: net: xgene: Add missing initialization in xgene_enet_ecc_init()
Date: Mon, 20 Oct 2014 10:08:16 +0200
Message-ID: <1413792496-8558-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c: In function =E2=80=98=
xgene_enet_ecc_init=E2=80=99:
drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c:126: warning: =E2=80=98=
data=E2=80=99 may be used uninitialized in this function

Depending on the arbitrary value on the stack, the loop may terminate
too early, and cause a bogus -ENODEV failure.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/driver=
s/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index e6d24c2101982444..19e13583b4259cd4 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -123,7 +123,7 @@ static u32 xgene_enet_rd_mac(struct xgene_enet_pdat=
a *p, u32 rd_addr)
 static int xgene_enet_ecc_init(struct xgene_enet_pdata *p)
 {
 	struct net_device *ndev =3D p->ndev;
-	u32 data;
+	u32 data =3D 0;
 	int i;
=20
 	xgene_enet_wr_diag_csr(p, ENET_CFG_MEM_RAM_SHUTDOWN_ADDR, 0);
--=20
1.9.1
