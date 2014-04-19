From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH] smc91x: fix compile error when SMC_DEBUG >= 2
Date: Fri, 18 Apr 2014 20:47:30 -0700
Message-ID: <1397879250-32041-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When SMC_DEBUG >=3D 2, we hit the following compilation error:

drivers/net/ethernet/smsc/smc91x.c:85:0:
drivers/net/ethernet/smsc/smc91x.c: In function =E2=80=98smc_findirq=E2=
=80=99:
drivers/net/ethernet/smsc/smc91x.c:1784:9: error: =E2=80=98dev=E2=80=99=
 undeclared (first use in this function)
  DBG(2, dev, "%s: %s\n", CARDNAME, __func__);
         ^
=46ix it by passing in the appropriate netdev pointer.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 drivers/net/ethernet/smsc/smc91x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/=
smsc/smc91x.c
index d1b4dca..597909f 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1781,7 +1781,7 @@ static int smc_findirq(struct smc_local *lp)
 	int timeout =3D 20;
 	unsigned long cookie;
=20
-	DBG(2, dev, "%s: %s\n", CARDNAME, __func__);
+	DBG(2, lp->dev, "%s: %s\n", CARDNAME, __func__);
=20
 	cookie =3D probe_irq_on();
=20
--=20
1.9.1
