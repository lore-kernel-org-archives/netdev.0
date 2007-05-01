From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [patch 16/33] m68k: Amiga A2065 and Ariadne TX statistics
Date: Tue, 01 May 2007 22:32:50 +0200
Message-ID: <20070501203333.988031488@mail.of.borg>
References: <20070501203234.252205858@mail.of.borg>
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from europa.telenet-ops.be ([195.130.137.75]:44977 "EHLO
	europa.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423630AbXEAUe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 16:34:57 -0400
Content-Disposition: inline; filename=amiga-a2065-ariadne-stats.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing code to the Amiga A2065 and Ariadne drivers to update
net_device_stats.tx_bytes.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/a2065.c   |    4 +---
 drivers/net/ariadne.c |    1 +
 2 files changed, 2 insertions(+), 3 deletions(-)

--- linux-m68k-2.6.21.orig/drivers/net/a2065.c
+++ linux-m68k-2.6.21/drivers/net/a2065.c
@@ -562,7 +562,6 @@ static int lance_start_xmit (struct sk_b
 	volatile struct lance_init_block *ib = lp->init_block;
 	int entry, skblen, len;
 	int status = 0;
-	static int outs;
 	unsigned long flags;
 
 	skblen = skb->len;
@@ -607,8 +606,7 @@ static int lance_start_xmit (struct sk_b
 	/* Now, give the packet to the lance */
 	ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
 	lp->tx_new = (lp->tx_new+1) & lp->tx_ring_mod_mask;
-
-	outs++;
+	lp->stats.tx_bytes += skblen;
 
 	if (TX_BUFFS_AVAIL <= 0)
 		netif_stop_queue(dev);
--- linux-m68k-2.6.21.orig/drivers/net/ariadne.c
+++ linux-m68k-2.6.21/drivers/net/ariadne.c
@@ -677,6 +677,7 @@ static int ariadne_start_xmit(struct sk_
 	priv->cur_tx -= TX_RING_SIZE;
 	priv->dirty_tx -= TX_RING_SIZE;
     }
+    priv->stats.tx_bytes += len;
 
     /* Trigger an immediate send poll. */
     lance->RAP = CSR0;		/* PCnet-ISA Controller Status */

--
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

