From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 4/7] fs_enet: mac-fcc: Eliminate __fcc-* macros.
Date: Fri, 17 Aug 2007 12:54:02 -0500
Message-ID: <20070817175402.GD9218@ld0162-tx32.am.freescale.net>
References: <20070817175320.GA8259@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:61150 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758437AbXHQRyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 13:54:24 -0400
Content-Disposition: inline
In-Reply-To: <20070817175320.GA8259@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These macros accomplish nothing other than defeating type checking.

This patch also fixes one instance of the wrong register size being
used that was revealed by enabling type checking.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/fs_enet/mac-fcc.c |   25 ++++++++-----------------
 1 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index ad3c5fa..8b30361 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -48,28 +48,19 @@
 
 /* FCC access macros */
 
-#define __fcc_out32(addr, x)	out_be32((unsigned *)addr, x)
-#define __fcc_out16(addr, x)	out_be16((unsigned short *)addr, x)
-#define __fcc_out8(addr, x)	out_8((unsigned char *)addr, x)
-#define __fcc_in32(addr)	in_be32((unsigned *)addr)
-#define __fcc_in16(addr)	in_be16((unsigned short *)addr)
-#define __fcc_in8(addr)		in_8((unsigned char *)addr)
-
-/* parameter space */
-
 /* write, read, set bits, clear bits */
-#define W32(_p, _m, _v)	__fcc_out32(&(_p)->_m, (_v))
-#define R32(_p, _m)	__fcc_in32(&(_p)->_m)
+#define W32(_p, _m, _v)	out_be32(&(_p)->_m, (_v))
+#define R32(_p, _m)	in_be32(&(_p)->_m)
 #define S32(_p, _m, _v)	W32(_p, _m, R32(_p, _m) | (_v))
 #define C32(_p, _m, _v)	W32(_p, _m, R32(_p, _m) & ~(_v))
 
-#define W16(_p, _m, _v)	__fcc_out16(&(_p)->_m, (_v))
-#define R16(_p, _m)	__fcc_in16(&(_p)->_m)
+#define W16(_p, _m, _v)	out_be16(&(_p)->_m, (_v))
+#define R16(_p, _m)	in_be16(&(_p)->_m)
 #define S16(_p, _m, _v)	W16(_p, _m, R16(_p, _m) | (_v))
 #define C16(_p, _m, _v)	W16(_p, _m, R16(_p, _m) & ~(_v))
 
-#define W8(_p, _m, _v)	__fcc_out8(&(_p)->_m, (_v))
-#define R8(_p, _m)	__fcc_in8(&(_p)->_m)
+#define W8(_p, _m, _v)	out_8(&(_p)->_m, (_v))
+#define R8(_p, _m)	in_8(&(_p)->_m)
 #define S8(_p, _m, _v)	W8(_p, _m, R8(_p, _m) | (_v))
 #define C8(_p, _m, _v)	W8(_p, _m, R8(_p, _m) & ~(_v))
 
@@ -290,7 +281,7 @@ static void restart(struct net_device *dev)
 
 	/* clear everything (slow & steady does it) */
 	for (i = 0; i < sizeof(*ep); i++)
-		__fcc_out8((char *)ep + i, 0);
+		out_8((char *)ep + i, 0);
 
 	/* get physical address */
 	rx_bd_base_phys = fep->ring_mem_addr;
@@ -495,7 +486,7 @@ static void tx_kickstart(struct net_device *dev)
 	struct fs_enet_private *fep = netdev_priv(dev);
 	fcc_t *fccp = fep->fcc.fccp;
 
-	S32(fccp, fcc_ftodr, 0x80);
+	S16(fccp, fcc_ftodr, 0x8000);
 }
 
 static u32 get_int_events(struct net_device *dev)
-- 
1.5.0.3

