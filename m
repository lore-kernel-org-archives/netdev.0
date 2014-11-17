From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 6/8] net: fec: use swab32s() instead of cpu_to_be32()
Date: Mon, 17 Nov 2014 10:51:22 +0100
Message-ID: <1416217884-20911-7-git-send-email-LW@KARO-electronics.de>
References: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <fugang.duan@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53266 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbaKQJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 04:51:41 -0500
In-Reply-To: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when swap_buffer() is being called, we know for sure, that we need to
byte swap the data. Furthermore, this function is called for swapping
data in both directions. Thus cpu_to_be32() is semantically not
correct for all use cases. Use swab32s() to reflect this.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 3884dd9..f73fee7 100644
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
