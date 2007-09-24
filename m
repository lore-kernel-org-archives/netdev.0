From: Olaf Hering <olaf@aepfle.de>
Subject: [PATCH] fix mace_handle_misc_intrs compilation
Date: Mon, 24 Sep 2007 10:15:01 +0200
Message-ID: <20070924081501.GA1797@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:49560 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbXIXIOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 04:14:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix compilation after incomplete struct net_device changes.

Signed-off-by: Olaf Hering <olaf@aepfle.de>

---
 drivers/net/mace.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -633,7 +633,7 @@ static void mace_set_multicast(struct ne
     spin_unlock_irqrestore(&mp->lock, flags);
 }
 
-static void mace_handle_misc_intrs(struct mace_data *mp, int intr)
+static void mace_handle_misc_intrs(struct mace_data *mp, int intr, struct net_device *dev)
 {
     volatile struct mace __iomem *mb = mp->mace;
     static int mace_babbles, mace_jabbers;
@@ -669,7 +669,7 @@ static irqreturn_t mace_interrupt(int ir
     spin_lock_irqsave(&mp->lock, flags);
     intr = in_8(&mb->ir);		/* read interrupt register */
     in_8(&mb->xmtrc);			/* get retries */
-    mace_handle_misc_intrs(mp, intr);
+    mace_handle_misc_intrs(mp, intr, dev);
 
     i = mp->tx_empty;
     while (in_8(&mb->pr) & XMTSV) {
@@ -682,7 +682,7 @@ static irqreturn_t mace_interrupt(int ir
 	 */
 	intr = in_8(&mb->ir);
 	if (intr != 0)
-	    mace_handle_misc_intrs(mp, intr);
+	    mace_handle_misc_intrs(mp, intr, dev);
 	if (mp->tx_bad_runt) {
 	    fs = in_8(&mb->xmtfs);
 	    mp->tx_bad_runt = 0;
@@ -817,7 +817,7 @@ static void mace_tx_timeout(unsigned lon
 	goto out;
 
     /* update various counters */
-    mace_handle_misc_intrs(mp, in_8(&mb->ir));
+    mace_handle_misc_intrs(mp, in_8(&mb->ir), dev);
 
     cp = mp->tx_cmds + NCMDS_TX * mp->tx_empty;
 
