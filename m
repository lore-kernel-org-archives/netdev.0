From: =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
Subject: [PATCH 2/4] net: ethernet: apple: initialize variables directly
Date: Fri, 17 May 2013 12:07:46 -0300
Message-ID: <1368803268-27698-2-git-send-email-emilio@elopez.com.ar>
References: <1368803268-27698-1-git-send-email-emilio@elopez.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, <linux-kernel@vger.kernel.org>,
	=?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368803268-27698-1-git-send-email-emilio@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clean up the code a bit to initialize the variables directly when
defining them.

Signed-off-by: Emilio L=C3=B3pez <emilio@elopez.com.ar>
---

Please note that this patch is untested.

 drivers/net/ethernet/apple/bmac.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/a=
pple/bmac.c
index f36bbd6..253030c 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1030,14 +1030,12 @@ static void bmac_set_multicast(struct net_devic=
e *dev)
 		rx_cfg |=3D RxPromiscEnable;
 		bmwrite(dev, RXCFG, rx_cfg);
 	} else {
-		u16 hash_table[4];
+		u16 hash_table[4] =3D {0};
=20
 		rx_cfg =3D bmread(dev, RXCFG);
 		rx_cfg &=3D ~RxPromiscEnable;
 		bmwrite(dev, RXCFG, rx_cfg);
=20
-		for(i =3D 0; i < 4; i++) hash_table[i] =3D 0;
-
 		netdev_for_each_mc_addr(ha, dev) {
 			crc =3D ether_crc_le(6, ha->addr);
 			crc >>=3D 26;
--=20
1.8.2.3
