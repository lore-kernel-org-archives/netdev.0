From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/15] nfp: don't use netdev_warn() before netdev is registered
Date: Tue, 21 Mar 2017 17:59:17 -0700
Message-ID: <20170322005921.10965-12-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34538 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757414AbdCVBIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:08:05 -0400
Received: by mail-pf0-f173.google.com with SMTP id p189so63582843pfp.1
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:08:04 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning which was using netdev_warn() instead of dev_warn()
to early.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f134f1808b9a..19f9d95faea4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -336,9 +336,9 @@ nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 
 	if (dp->num_rx_rings > dp->num_r_vecs ||
 	    dp->num_tx_rings > dp->num_r_vecs)
-		nn_warn(nn, "More rings (%d,%d) than vectors (%d).\n",
-			dp->num_rx_rings, dp->num_tx_rings,
-			dp->num_r_vecs);
+		dev_warn(nn->dp.dev, "More rings (%d,%d) than vectors (%d).\n",
+			 dp->num_rx_rings, dp->num_tx_rings,
+			 dp->num_r_vecs);
 
 	dp->num_rx_rings = min(dp->num_r_vecs, dp->num_rx_rings);
 	dp->num_tx_rings = min(dp->num_r_vecs, dp->num_tx_rings);
-- 
2.11.0
