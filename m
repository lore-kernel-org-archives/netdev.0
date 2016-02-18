From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net 5/5] nfp: don't trust netif_running() in debug code
Date: Thu, 18 Feb 2016 20:38:13 +0000
Message-ID: <1455827893-26366-6-git-send-email-jakub.kicinski@netronome.com>
References: <1455827893-26366-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33095 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948081AbcBRUiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:38:23 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so42101173wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 12:38:23 -0800 (PST)
In-Reply-To: <1455827893-26366-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since change_mtu() can fail and leave us with netif_running()
returning true even though all rings were freed - we should
look at NFP_NET_CFG_CTRL_ENABLE flag to determine if device
is really opened.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 4c97c713121c..7af404d492cc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -52,7 +52,7 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 	if (!rx_ring->r_vec || !rx_ring->r_vec->nfp_net)
 		goto out;
 	nn = rx_ring->r_vec->nfp_net;
-	if (!netif_running(nn->netdev))
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE))
 		goto out;
 
 	rxd_cnt = rx_ring->cnt;
@@ -127,7 +127,7 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 	if (!tx_ring->r_vec || !tx_ring->r_vec->nfp_net)
 		goto out;
 	nn = tx_ring->r_vec->nfp_net;
-	if (!netif_running(nn->netdev))
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE))
 		goto out;
 
 	txd_cnt = tx_ring->cnt;
-- 
1.9.1
