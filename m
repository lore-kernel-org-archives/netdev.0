From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bnx2: avoid compiler warnings
Date: Tue, 03 Nov 2009 10:17:42 +0100
Message-ID: <4AEFF536.1020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37645 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840AbZKCJRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:17:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/bnx2.c: In function =91bnx2_enable_forced_2g5=92:
drivers/net/bnx2.c:1447: warning: =91bmcr=92 may be used uninitialized =
in this function
drivers/net/bnx2.c: In function =91bnx2_disable_forced_2g5=92:
drivers/net/bnx2.c:1482: warning: =91bmcr=92 may be used uninitialized =
in this function

One fix would be to have an initial value, but a plain return might be =
better.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 08cddb6..539d23b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1466,6 +1466,8 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 	} else if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5708) {
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		bmcr |=3D BCM5708S_BMCR_FORCE_2500;
+	} else {
+		return;
 	}
=20
 	if (bp->autoneg & AUTONEG_SPEED) {
@@ -1500,6 +1502,8 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
 	} else if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5708) {
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		bmcr &=3D ~BCM5708S_BMCR_FORCE_2500;
+	} else {
+		return;
 	}
=20
 	if (bp->autoneg & AUTONEG_SPEED)
