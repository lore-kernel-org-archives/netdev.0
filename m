From: Geoff Levand <geoff@infradead.org>
Subject: [PATCH] net/ps3_gelic: Fix build error with DEBUG
Date: Wed, 10 Jun 2015 10:19:48 -0700
Message-ID: <1433956788.4524.15.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	cbe-oss-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34311 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964913AbbFJRTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 13:19:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the DEBUG preprocessor macro is defined the ps3_gelic_net driver build
fails due to an undeclared routine gelic_descr_get_status().  This problem
was introduced during the code cleanup of commit
6b0c21cede22be1f68f0a632c0ca38008ce1abe7 (net: Fix p3_gelic_net sparse warnings),
which re-arranged the ordering of some of the gelic routines.

This change just moves the gelic_descr_get_status() routine up in the
ps3_gelic_net.c source file. There is no functional change.

Fixes build errors like these:

  drivers/net/ethernet/toshiba/ps3_gelic_net.c: error: implicit declaration of function gelic_descr_get_status

Signed-off-by: Geoff Levand <geoff@infradead.org>
---
Dave, please apply.

-Geoff

The following changes since commit d4a4f75cd8f29cd9464a5a32e9224a91571d6649:

  Linux 4.1-rc7 (2015-06-07 20:23:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/geoff/ps3-linux.git for-merge-1

 drivers/net/ethernet/toshiba/ps3_gelic_net.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index ac62a5e..79f0ec4 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -102,6 +102,18 @@ static void gelic_card_get_ether_port_status(struct gelic_card *card,
 	}
 }
 
+/**
+ * gelic_descr_get_status -- returns the status of a descriptor
+ * @descr: descriptor to look at
+ *
+ * returns the status as in the dmac_cmd_status field of the descriptor
+ */
+static enum gelic_descr_dma_status
+gelic_descr_get_status(struct gelic_descr *descr)
+{
+	return be32_to_cpu(descr->dmac_cmd_status) & GELIC_DESCR_DMA_STAT_MASK;
+}
+
 static int gelic_card_set_link_mode(struct gelic_card *card, int mode)
 {
 	int status;
@@ -278,18 +290,6 @@ void gelic_card_down(struct gelic_card *card)
 }
 
 /**
- * gelic_descr_get_status -- returns the status of a descriptor
- * @descr: descriptor to look at
- *
- * returns the status as in the dmac_cmd_status field of the descriptor
- */
-static enum gelic_descr_dma_status
-gelic_descr_get_status(struct gelic_descr *descr)
-{
-	return be32_to_cpu(descr->dmac_cmd_status) & GELIC_DESCR_DMA_STAT_MASK;
-}
-
-/**
  * gelic_card_free_chain - free descriptor chain
  * @card: card structure
  * @descr_in: address of desc
-- 
2.1.0
