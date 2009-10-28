From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 02/20] igb: remove rx checksum good counter
Date: Tue, 27 Oct 2009 18:49:49 -0700
Message-ID: <20091028014948.12470.85302.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:42391
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752502AbZJ1Bxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:53:32 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Counting packets with a good checksum can cause a significant amount of cache
line bouncing due to the shared counter being written to by all of the queues.
In order to avoid this I am removing the counter since we still have the
checksum failed counter which will tell us if there are any issues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h         |    1 -
 drivers/net/igb/igb_ethtool.c |    1 -
 drivers/net/igb/igb_main.c    |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 86492c8..d27dcd1 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -254,7 +254,6 @@ struct igb_adapter {
 	int num_rx_queues;
 
 	u64 hw_csum_err;
-	u64 hw_csum_good;
 	u32 alloc_rx_buff_failed;
 	u32 gorc;
 	u64 gorc_old;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index f71276f..2929546 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -95,7 +95,6 @@ static const struct igb_stats igb_gstrings_stats[] = {
 	{ "tx_flow_control_xon", IGB_STAT(stats.xontxc) },
 	{ "tx_flow_control_xoff", IGB_STAT(stats.xofftxc) },
 	{ "rx_long_byte_count", IGB_STAT(stats.gorc) },
-	{ "rx_csum_offload_good", IGB_STAT(hw_csum_good) },
 	{ "rx_csum_offload_errors", IGB_STAT(hw_csum_err) },
 	{ "tx_dma_out_of_sync", IGB_STAT(stats.doosync) },
 	{ "alloc_rx_buff_failed", IGB_STAT(alloc_rx_buff_failed) },
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c15eb4c..e1d1c0c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4827,7 +4827,6 @@ static inline void igb_rx_checksum_adv(struct igb_adapter *adapter,
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	dev_dbg(&adapter->pdev->dev, "cksum success: bits %08X\n", status_err);
-	adapter->hw_csum_good++;
 }
 
 static inline u16 igb_get_hlen(struct igb_adapter *adapter,

