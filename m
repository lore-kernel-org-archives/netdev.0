From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] micrel: Use time_before_eq()
Date: Thu, 22 May 2014 19:52:45 +0200
Message-ID: <1400781165-26498-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jg1.han@samsung.com, dingtianhong@huawei.com,
	ebiederm@xmission.com, Julia.Lawall@lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are =
modified
to use time_before_eq() instead of plain, error-prone math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/net/ethernet/micrel/ksz884x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethern=
et/micrel/ksz884x.c
index 14ac0e2..90fa5f3 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4930,7 +4930,7 @@ static void netdev_tx_timeout(struct net_device *=
dev)
 		 * Only reset the hardware if time between calls is long
 		 * enough.
 		 */
-		if (jiffies - last_reset <=3D dev->watchdog_timeo)
+		if (time_before_eq(jiffies, last_reset + dev->watchdog_timeo))
 			hw_priv =3D NULL;
 	}
=20
--=20
1.7.10.4
