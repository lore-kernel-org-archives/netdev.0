From: =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
Subject: [PATCH 3/4] net: ethernet: davicom: dm9000: initialize variables directly
Date: Fri, 17 May 2013 12:07:47 -0300
Message-ID: <1368803268-27698-3-git-send-email-emilio@elopez.com.ar>
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

 drivers/net/ethernet/davicom/dm9000.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethern=
et/davicom/dm9000.c
index 9105465..e4ed05e 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -827,7 +827,7 @@ dm9000_hash_table_unlocked(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	int i, oft;
 	u32 hash_val;
-	u16 hash_table[4];
+	u16 hash_table[4] =3D {0, 0, 0, 0x8000}; /* broadcast address */
 	u8 rcr =3D RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
=20
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
@@ -835,13 +835,6 @@ dm9000_hash_table_unlocked(struct net_device *dev)
 	for (i =3D 0, oft =3D DM9000_PAR; i < 6; i++, oft++)
 		iow(db, oft, dev->dev_addr[i]);
=20
-	/* Clear Hash Table */
-	for (i =3D 0; i < 4; i++)
-		hash_table[i] =3D 0x0;
-
-	/* broadcast address */
-	hash_table[3] =3D 0x8000;
-
 	if (dev->flags & IFF_PROMISC)
 		rcr |=3D RCR_PRMSC;
=20
--=20
1.8.2.3
