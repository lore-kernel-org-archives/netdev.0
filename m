From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 14/21] amd-xgbe: Allow for a greater number of
 Rx queues
Date: Thu, 3 Nov 2016 08:30:08 -0500
Message-ID: <20161103133008.3437.49103.stgit@tlendack-t1.amdoffice.net>
References: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0053.outbound.protection.outlook.com ([104.47.42.53]:48688
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754326AbcKCNpE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:45:04 -0400
In-Reply-To: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the call to netif_get_num_default_rss_queues() and replace it
with num_online_cpus() to allow for the possibility of using all of
the hardware DMA channels available.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 697483a..7655753 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -236,8 +236,7 @@ void xgbe_set_counts(struct xgbe_prv_data *pdata)
 
 	pdata->tx_q_count = pdata->tx_ring_count;
 
-	pdata->rx_ring_count = min_t(unsigned int,
-				     netif_get_num_default_rss_queues(),
+	pdata->rx_ring_count = min_t(unsigned int, num_online_cpus(),
 				     pdata->hw_feat.rx_ch_cnt);
 	pdata->rx_ring_count = min_t(unsigned int, pdata->rx_ring_count,
 				     pdata->rx_max_channel_count);
