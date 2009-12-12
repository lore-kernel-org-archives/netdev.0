From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: Fix tx_restart_queue/non_eop_desc
	statistics counters
Date: Fri, 11 Dec 2009 23:51:41 -0800
Message-ID: <20091212075140.10952.86813.stgit@localhost.localdomain>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:32989
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756413AbZLLHvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 02:51:53 -0500
In-Reply-To: <20091212075120.10952.98484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Fix tx_restart_queue & non_eop_desc stats counters, counters were not
getting incremented as expected with the traffic

Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d561fdf..65eec2d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4511,6 +4511,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 total_mpc = 0;
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
+	u64 non_eop_descs = 0, restart_queue = 0;
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		u64 rsc_count = 0;
@@ -4528,10 +4529,12 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
 	/* gather some stats to the adapter struct that are per queue */
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		adapter->restart_queue += adapter->tx_ring[i].restart_queue;
+		restart_queue += adapter->tx_ring[i]->restart_queue;
+	adapter->restart_queue = restart_queue;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		adapter->non_eop_descs += adapter->tx_ring[i].non_eop_descs;
+		non_eop_descs += adapter->rx_ring[i]->non_eop_descs;
+	adapter->non_eop_descs = non_eop_descs;
 
 	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
 	for (i = 0; i < 8; i++) {

