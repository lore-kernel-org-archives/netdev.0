From: akpm@linux-foundation.org
Subject: [patch 2/4] tokenring/3c359.c: fixed array index problem
Date: Tue, 16 Oct 2007 14:24:08 -0700
Message-ID: <200710162124.l9GLO97v017968@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	meissner@suse.de, penberg@cs.helsinki.fi
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59143 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933688AbXJPVZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 17:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcus Meissner <meissner@suse.de>

The xl_laa array is just 6 bytes long, so we should substract 10 from the
index, like is also done some lines above already.

Signed-off-by: Marcus Meissner <meissner@suse.de>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tokenring/3c359.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/tokenring/3c359.c~tokenring-3c359c-fixed-array-index-problem drivers/net/tokenring/3c359.c
--- a/drivers/net/tokenring/3c359.c~tokenring-3c359c-fixed-array-index-problem
+++ a/drivers/net/tokenring/3c359.c
@@ -760,7 +760,7 @@ static int xl_open_hw(struct net_device 
 	if (xl_priv->xl_laa[0]) {  /* If using a LAA address */
 		for (i=10;i<16;i++) { 
 			writel( (MEM_BYTE_WRITE | 0xD0000 | xl_priv->srb) + i, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-			writeb(xl_priv->xl_laa[i],xl_mmio + MMIO_MACDATA) ; 
+			writeb(xl_priv->xl_laa[i-10], xl_mmio + MMIO_MACDATA);
 		}
 		memcpy(dev->dev_addr,xl_priv->xl_laa,dev->addr_len) ; 
 	} else { /* Regular hardware address */ 
_
