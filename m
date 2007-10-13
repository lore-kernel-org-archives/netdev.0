From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [patch 6/8] m68k: fix net drivers after recent get_stats updates
Date: Sat, 13 Oct 2007 14:31:29 +0200
Message-ID: <20071013123413.910864776@mail.of.borg>
References: <20071013123123.085686856@mail.of.borg>
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ananke.telenet-ops.be ([195.130.137.78]:54092 "EHLO
	ananke.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826AbXJMMf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 08:35:28 -0400
Content-Disposition: inline; filename=m68k-net-fixes.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

m68k: fix net drivers after recent get_stats updates

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/macmace.c |    6 +++---
 drivers/net/mvme147.c |    1 -
 2 files changed, 3 insertions(+), 4 deletions(-)

--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -538,8 +538,9 @@ static void mace_set_multicast(struct ne
 	local_irq_restore(flags);
 }
 
-static void mace_handle_misc_intrs(struct mace_data *mp, int intr)
+static void mace_handle_misc_intrs(struct net_device *dev, int intr)
 {
+	struct mace_data *mp = netdev_priv(dev);
 	volatile struct mace *mb = mp->mace;
 	static int mace_babbles, mace_jabbers;
 
@@ -571,7 +572,7 @@ static irqreturn_t mace_interrupt(int ir
 	local_irq_save(flags);
 
 	intr = mb->ir; /* read interrupt register */
-	mace_handle_misc_intrs(mp, intr);
+	mace_handle_misc_intrs(dev, intr);
 
 	if (intr & XMTINT) {
 		fs = mb->xmtfs;
@@ -645,7 +646,6 @@ static void mace_tx_timeout(struct net_d
 
 static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 {
-	struct mace_data *mp = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned int frame_status = mf->rcvsts;
 
--- a/drivers/net/mvme147.c
+++ b/drivers/net/mvme147.c
@@ -85,7 +85,6 @@ struct net_device * __init mvme147lance_
 	dev->open = &m147lance_open;
 	dev->stop = &m147lance_close;
 	dev->hard_start_xmit = &lance_start_xmit;
-	dev->get_stats = &lance_get_stats;
 	dev->set_multicast_list = &lance_set_multicast;
 	dev->tx_timeout = &lance_tx_timeout;
 	dev->dma = 0;

-- 
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

