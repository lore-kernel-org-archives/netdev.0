From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] i40e: remove debugfs dump stats
Date: Mon,  3 Nov 2014 06:56:34 -0800
Message-ID: <1415026599-16232-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44876 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707AbaKCO44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:56 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The debugfs dump stats wasn't being kept up-to-date, was redundant with
the ethtool output, and didn't offer any useful additional info.  Rather
than continue trying to keep them aligned, just remove the debugfs command.

Change-ID: Id130ed9aef01c6369ab662c7b4c5ec5b1dbc5b40
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <Jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 93 +-------------------------
 1 file changed, 2 insertions(+), 91 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 7067f4b..a03f459 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -895,90 +895,6 @@ static void i40e_dbg_dump_eth_stats(struct i40e_pf *pf,
 }
 
 /**
- * i40e_dbg_dump_stats - handles dump stats write into command datum
- * @pf: the i40e_pf created in command write
- * @stats: the stats structure to be dumped
- **/
-static void i40e_dbg_dump_stats(struct i40e_pf *pf,
-				struct i40e_hw_port_stats *stats)
-{
-	int i;
-
-	dev_info(&pf->pdev->dev, "  stats:\n");
-	dev_info(&pf->pdev->dev,
-		 "    crc_errors = \t\t%lld \tillegal_bytes = \t%lld \terror_bytes = \t\t%lld\n",
-		 stats->crc_errors, stats->illegal_bytes, stats->error_bytes);
-	dev_info(&pf->pdev->dev,
-		 "    mac_local_faults = \t%lld \tmac_remote_faults = \t%lld \trx_length_errors = \t%lld\n",
-		 stats->mac_local_faults, stats->mac_remote_faults,
-		 stats->rx_length_errors);
-	dev_info(&pf->pdev->dev,
-		 "    link_xon_rx = \t\t%lld \tlink_xoff_rx = \t\t%lld \tlink_xon_tx = \t\t%lld\n",
-		 stats->link_xon_rx, stats->link_xoff_rx, stats->link_xon_tx);
-	dev_info(&pf->pdev->dev,
-		 "    link_xoff_tx = \t\t%lld \trx_size_64 = \t\t%lld \trx_size_127 = \t\t%lld\n",
-		 stats->link_xoff_tx, stats->rx_size_64, stats->rx_size_127);
-	dev_info(&pf->pdev->dev,
-		 "    rx_size_255 = \t\t%lld \trx_size_511 = \t\t%lld \trx_size_1023 = \t\t%lld\n",
-		 stats->rx_size_255, stats->rx_size_511, stats->rx_size_1023);
-	dev_info(&pf->pdev->dev,
-		 "    rx_size_big = \t\t%lld \trx_undersize = \t\t%lld \trx_jabber = \t\t%lld\n",
-		 stats->rx_size_big, stats->rx_undersize, stats->rx_jabber);
-	dev_info(&pf->pdev->dev,
-		 "    rx_fragments = \t\t%lld \trx_oversize = \t\t%lld \ttx_size_64 = \t\t%lld\n",
-		 stats->rx_fragments, stats->rx_oversize, stats->tx_size_64);
-	dev_info(&pf->pdev->dev,
-		 "    tx_size_127 = \t\t%lld \ttx_size_255 = \t\t%lld \ttx_size_511 = \t\t%lld\n",
-		 stats->tx_size_127, stats->tx_size_255, stats->tx_size_511);
-	dev_info(&pf->pdev->dev,
-		 "    tx_size_1023 = \t\t%lld \ttx_size_big = \t\t%lld \tmac_short_packet_dropped = \t%lld\n",
-		 stats->tx_size_1023, stats->tx_size_big,
-		 stats->mac_short_packet_dropped);
-	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xon_rx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xon_rx[i],
-			 i+1, stats->priority_xon_rx[i+1],
-			 i+2, stats->priority_xon_rx[i+2],
-			 i+3, stats->priority_xon_rx[i+3]);
-	}
-	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xoff_rx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xoff_rx[i],
-			 i+1, stats->priority_xoff_rx[i+1],
-			 i+2, stats->priority_xoff_rx[i+2],
-			 i+3, stats->priority_xoff_rx[i+3]);
-	}
-	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xon_tx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xon_tx[i],
-			 i+1, stats->priority_xon_tx[i+1],
-			 i+2, stats->priority_xon_tx[i+2],
-			 i+3, stats->priority_xon_rx[i+3]);
-	}
-	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xoff_tx[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xoff_tx[i],
-			 i+1, stats->priority_xoff_tx[i+1],
-			 i+2, stats->priority_xoff_tx[i+2],
-			 i+3, stats->priority_xoff_tx[i+3]);
-	}
-	for (i = 0; i < 8; i += 4) {
-		dev_info(&pf->pdev->dev,
-			 "    priority_xon_2_xoff[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld \t[%d] = \t%lld\n",
-			 i, stats->priority_xon_2_xoff[i],
-			 i+1, stats->priority_xon_2_xoff[i+1],
-			 i+2, stats->priority_xon_2_xoff[i+2],
-			 i+3, stats->priority_xon_2_xoff[i+3]);
-	}
-
-	i40e_dbg_dump_eth_stats(pf, &stats->eth);
-}
-
-/**
  * i40e_dbg_dump_veb_seid - handles dump stats of a single given veb
  * @pf: the i40e_pf created in command write
  * @seid: the seid the user put in
@@ -1342,11 +1258,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 					 "dump desc rx <vsi_seid> <ring_id> [<desc_n>]\n");
 				dev_info(&pf->pdev->dev, "dump desc aq\n");
 			}
-		} else if (strncmp(&cmd_buf[5], "stats", 5) == 0) {
-			dev_info(&pf->pdev->dev, "pf stats:\n");
-			i40e_dbg_dump_stats(pf, &pf->stats);
-			dev_info(&pf->pdev->dev, "pf stats_offsets:\n");
-			i40e_dbg_dump_stats(pf, &pf->stats_offsets);
 		} else if (strncmp(&cmd_buf[5], "reset stats", 11) == 0) {
 			dev_info(&pf->pdev->dev,
 				 "core reset count: %d\n", pf->corer_count);
@@ -1464,8 +1375,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		} else {
 			dev_info(&pf->pdev->dev,
 				 "dump desc tx <vsi_seid> <ring_id> [<desc_n>], dump desc rx <vsi_seid> <ring_id> [<desc_n>],\n");
-			dev_info(&pf->pdev->dev, "dump switch, dump vsi [seid] or\n");
-			dev_info(&pf->pdev->dev, "dump stats\n");
+			dev_info(&pf->pdev->dev, "dump switch\n");
+			dev_info(&pf->pdev->dev, "dump vsi [seid]\n");
 			dev_info(&pf->pdev->dev, "dump reset stats\n");
 			dev_info(&pf->pdev->dev, "dump port\n");
 			dev_info(&pf->pdev->dev,
-- 
1.9.3
