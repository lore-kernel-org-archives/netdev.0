From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv3 6/9] net: fec: use swab32s() instead of cpu_to_be32()
Date: Tue, 28 Oct 2014 14:23:01 +0100
Message-ID: <1414502584-10583-7-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
 <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	<linux-arm-kernel@lists.infradead.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

when swap_buffer() is being called, we know for sure, that we need to
byte swap the data. Also this function is called for swapping data in
both directions. Thus cpu_to_be32() is semantically not correct for
all use cases. Use swab32s() to reflect this.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 5c1d517..5b76cdc 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -293,7 +293,7 @@ static void *swap_buffer(void *bufaddr, int len)
 	unsigned int *buf =3D bufaddr;
=20
 	for (i =3D 0; i < DIV_ROUND_UP(len, 4); i++, buf++)
-		*buf =3D cpu_to_be32(*buf);
+		swab32s(buf);
=20
 	return bufaddr;
 }
--=20
1.7.10.4
