From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv3 7/9] net: fec: simplify loop counter handling in swap_buffer()
Date: Tue, 28 Oct 2014 14:23:02 +0100
Message-ID: <1414502584-10583-8-git-send-email-LW@KARO-electronics.de>
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

Eliminate the DIV_ROUND_UP() and change the loop counter increment to
4 instead. This results in saving 6 instructions in the functions
assembly code.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 5b76cdc..ddfc57d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -292,7 +292,7 @@ static void *swap_buffer(void *bufaddr, int len)
 	int i;
 	unsigned int *buf =3D bufaddr;
=20
-	for (i =3D 0; i < DIV_ROUND_UP(len, 4); i++, buf++)
+	for (i =3D 0; i < len; i +=3D 4, buf++)
 		swab32s(buf);
=20
 	return bufaddr;
--=20
1.7.10.4
