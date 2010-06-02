From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] epic100: Test __BIG_ENDIAN instead of (non-existent) CONFIG_BIG_ENDIAN
Date: Wed, 02 Jun 2010 13:36:53 -0700
Message-ID: <ada4ohlrx22.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:57170 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758027Ab0FBUg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 16:36:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably no one has used this driver on big-endian systems, since it was
setting up descriptor swapping if CONFIG_BIG_ENDIAN is set, which it
never is, since that symbol is not mentioned anywhere else in the kernel
source.  Switch this test to a check for __BIG_ENDIAN so it has a chance
at working.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/epic100.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 6838dfc..4c27465 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -87,6 +87,7 @@ static int rx_copybreak;
 #include <linux/bitops.h>
 #include <asm/io.h>
 #include <asm/uaccess.h>
+#include <asm/byteorder.h>
 
 /* These identify the driver base version and may not be removed. */
 static char version[] __devinitdata =
@@ -230,7 +231,7 @@ static const u16 media2miictl[16] = {
  * The EPIC100 Rx and Tx buffer descriptors.  Note that these
  * really ARE host-endian; it's not a misannotation.  We tell
  * the card to byteswap them internally on big-endian hosts -
- * look for #ifdef CONFIG_BIG_ENDIAN in epic_open().
+ * look for #ifdef __BIG_ENDIAN in epic_open().
  */
 
 struct epic_tx_desc {
@@ -690,7 +691,7 @@ static int epic_open(struct net_device *dev)
 		outl((inl(ioaddr + NVCTL) & ~0x003C) | 0x4800, ioaddr + NVCTL);
 
 	/* Tell the chip to byteswap descriptors on big-endian hosts */
-#ifdef CONFIG_BIG_ENDIAN
+#ifdef __BIG_ENDIAN
 	outl(0x4432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
 	inl(ioaddr + GENCTL);
 	outl(0x0432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
@@ -806,7 +807,7 @@ static void epic_restart(struct net_device *dev)
 	for (i = 16; i > 0; i--)
 		outl(0x0008, ioaddr + TEST1);
 
-#ifdef CONFIG_BIG_ENDIAN
+#ifdef __BIG_ENDIAN
 	outl(0x0432 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);
 #else
 	outl(0x0412 | (RX_FIFO_THRESH<<8), ioaddr + GENCTL);

-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
