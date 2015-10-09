From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] i40e/i40evf: clean up some code
Date: Thu,  8 Oct 2015 18:32:50 -0700
Message-ID: <1444354374-24351-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17941 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755546AbbJIBdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:33:00 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Add missings spaces after declarations, remove another __func__ use,
remove uncessary braces, remove unneeded breaks, and useless returns,
and generally fix up some code.

Change-ID: Ie715d6b64976c50e1c21531685fe0a2bd38c4244
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 124 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   1 -
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  38 ++++---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  13 ++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   8 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   4 -
 17 files changed, 124 insertions(+), 103 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 287cb8d..fa2e916 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -683,8 +683,7 @@ static u16 i40e_clean_asq(struct i40e_hw *hw)
 	details = I40E_ADMINQ_DETAILS(*asq, ntc);
 	while (rd32(hw, hw->aq.asq.head) != ntc) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "%s: ntc %d head %d.\n", __func__, ntc,
-			   rd32(hw, hw->aq.asq.head));
+			   "ntc %d head %d.\n", ntc, rd32(hw, hw->aq.asq.head));
 
 		if (details->callback) {
 			I40E_ADMINQ_CALLBACK cb_func =
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2839ea5..2d012d9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1035,7 +1035,7 @@ i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
 	status = i40e_aq_mac_address_read(hw, &flags, &addrs, NULL);
 
 	if (flags & I40E_AQC_LAN_ADDR_VALID)
-		memcpy(mac_addr, &addrs.pf_lan_mac, sizeof(addrs.pf_lan_mac));
+		ether_addr_copy(mac_addr, addrs.pf_lan_mac);
 
 	return status;
 }
@@ -1058,7 +1058,7 @@ i40e_status i40e_get_port_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
 		return status;
 
 	if (flags & I40E_AQC_PORT_ADDR_VALID)
-		memcpy(mac_addr, &addrs.port_mac, sizeof(addrs.port_mac));
+		ether_addr_copy(mac_addr, addrs.port_mac);
 	else
 		status = I40E_ERR_INVALID_MAC_ADDR;
 
@@ -1116,7 +1116,7 @@ i40e_status i40e_get_san_mac_addr(struct i40e_hw *hw, u8 *mac_addr)
 		return status;
 
 	if (flags & I40E_AQC_SAN_ADDR_VALID)
-		memcpy(mac_addr, &addrs.pf_san_mac, sizeof(addrs.pf_san_mac));
+		ether_addr_copy(mac_addr, addrs.pf_san_mac);
 	else
 		status = I40E_ERR_INVALID_MAC_ADDR;
 
@@ -2363,6 +2363,7 @@ i40e_status i40e_aq_get_veb_parameters(struct i40e_hw *hw,
 		*vebs_free = le16_to_cpu(cmd_resp->vebs_free);
 	if (floating) {
 		u16 flags = le16_to_cpu(cmd_resp->veb_flags);
+
 		if (flags & I40E_AQC_ADD_VEB_FLOATING)
 			*floating = true;
 		else
@@ -3777,7 +3778,7 @@ i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
 	}
 
 	if (mac_addr)
-		memcpy(cmd->mac, mac_addr, ETH_ALEN);
+		ether_addr_copy(cmd->mac, mac_addr);
 
 	cmd->etype = cpu_to_le16(ethtype);
 	cmd->flags = cpu_to_le16(flags);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
index dbadad7..7c42d13 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
@@ -236,6 +236,7 @@ static void i40e_dcbnl_del_app(struct i40e_pf *pf,
 			       struct i40e_dcb_app_priority_table *app)
 {
 	int v, err;
+
 	for (v = 0; v < pf->num_alloc_vsi; v++) {
 		if (pf->vsi[v] && pf->vsi[v]->netdev) {
 			err = i40e_dcbnl_vsi_del_app(pf->vsi[v], app);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 9f9d842..c1dd248 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -404,82 +404,82 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 	nstat = i40e_get_vsi_stats_struct(vsi);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
-		 (long unsigned int)nstat->rx_packets,
-		 (long unsigned int)nstat->rx_bytes,
-		 (long unsigned int)nstat->rx_errors,
-		 (long unsigned int)nstat->rx_dropped);
+		 (unsigned long int)nstat->rx_packets,
+		 (unsigned long int)nstat->rx_bytes,
+		 (unsigned long int)nstat->rx_errors,
+		 (unsigned long int)nstat->rx_dropped);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
-		 (long unsigned int)nstat->tx_packets,
-		 (long unsigned int)nstat->tx_bytes,
-		 (long unsigned int)nstat->tx_errors,
-		 (long unsigned int)nstat->tx_dropped);
+		 (unsigned long int)nstat->tx_packets,
+		 (unsigned long int)nstat->tx_bytes,
+		 (unsigned long int)nstat->tx_errors,
+		 (unsigned long int)nstat->tx_dropped);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: multicast = %lu, collisions = %lu\n",
-		 (long unsigned int)nstat->multicast,
-		 (long unsigned int)nstat->collisions);
+		 (unsigned long int)nstat->multicast,
+		 (unsigned long int)nstat->collisions);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
-		 (long unsigned int)nstat->rx_length_errors,
-		 (long unsigned int)nstat->rx_over_errors,
-		 (long unsigned int)nstat->rx_crc_errors);
+		 (unsigned long int)nstat->rx_length_errors,
+		 (unsigned long int)nstat->rx_over_errors,
+		 (unsigned long int)nstat->rx_crc_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
-		 (long unsigned int)nstat->rx_frame_errors,
-		 (long unsigned int)nstat->rx_fifo_errors,
-		 (long unsigned int)nstat->rx_missed_errors);
+		 (unsigned long int)nstat->rx_frame_errors,
+		 (unsigned long int)nstat->rx_fifo_errors,
+		 (unsigned long int)nstat->rx_missed_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
-		 (long unsigned int)nstat->tx_aborted_errors,
-		 (long unsigned int)nstat->tx_carrier_errors,
-		 (long unsigned int)nstat->tx_fifo_errors);
+		 (unsigned long int)nstat->tx_aborted_errors,
+		 (unsigned long int)nstat->tx_carrier_errors,
+		 (unsigned long int)nstat->tx_fifo_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
-		 (long unsigned int)nstat->tx_heartbeat_errors,
-		 (long unsigned int)nstat->tx_window_errors);
+		 (unsigned long int)nstat->tx_heartbeat_errors,
+		 (unsigned long int)nstat->tx_window_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats: rx_compressed = %lu, tx_compressed = %lu\n",
-		 (long unsigned int)nstat->rx_compressed,
-		 (long unsigned int)nstat->tx_compressed);
+		 (unsigned long int)nstat->rx_compressed,
+		 (unsigned long int)nstat->tx_compressed);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: rx_packets = %lu, rx_bytes = %lu, rx_errors = %lu, rx_dropped = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_packets,
-		 (long unsigned int)vsi->net_stats_offsets.rx_bytes,
-		 (long unsigned int)vsi->net_stats_offsets.rx_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_dropped);
+		 (unsigned long int)vsi->net_stats_offsets.rx_packets,
+		 (unsigned long int)vsi->net_stats_offsets.rx_bytes,
+		 (unsigned long int)vsi->net_stats_offsets.rx_errors,
+		 (unsigned long int)vsi->net_stats_offsets.rx_dropped);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: tx_packets = %lu, tx_bytes = %lu, tx_errors = %lu, tx_dropped = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.tx_packets,
-		 (long unsigned int)vsi->net_stats_offsets.tx_bytes,
-		 (long unsigned int)vsi->net_stats_offsets.tx_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_dropped);
+		 (unsigned long int)vsi->net_stats_offsets.tx_packets,
+		 (unsigned long int)vsi->net_stats_offsets.tx_bytes,
+		 (unsigned long int)vsi->net_stats_offsets.tx_errors,
+		 (unsigned long int)vsi->net_stats_offsets.tx_dropped);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: multicast = %lu, collisions = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.multicast,
-		 (long unsigned int)vsi->net_stats_offsets.collisions);
+		 (unsigned long int)vsi->net_stats_offsets.multicast,
+		 (unsigned long int)vsi->net_stats_offsets.collisions);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: rx_length_errors = %lu, rx_over_errors = %lu, rx_crc_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_length_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_over_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_crc_errors);
+		 (unsigned long int)vsi->net_stats_offsets.rx_length_errors,
+		 (unsigned long int)vsi->net_stats_offsets.rx_over_errors,
+		 (unsigned long int)vsi->net_stats_offsets.rx_crc_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: rx_frame_errors = %lu, rx_fifo_errors = %lu, rx_missed_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_frame_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_fifo_errors,
-		 (long unsigned int)vsi->net_stats_offsets.rx_missed_errors);
+		 (unsigned long int)vsi->net_stats_offsets.rx_frame_errors,
+		 (unsigned long int)vsi->net_stats_offsets.rx_fifo_errors,
+		 (unsigned long int)vsi->net_stats_offsets.rx_missed_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: tx_aborted_errors = %lu, tx_carrier_errors = %lu, tx_fifo_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.tx_aborted_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_carrier_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_fifo_errors);
+		 (unsigned long int)vsi->net_stats_offsets.tx_aborted_errors,
+		 (unsigned long int)vsi->net_stats_offsets.tx_carrier_errors,
+		 (unsigned long int)vsi->net_stats_offsets.tx_fifo_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: tx_heartbeat_errors = %lu, tx_window_errors = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.tx_heartbeat_errors,
-		 (long unsigned int)vsi->net_stats_offsets.tx_window_errors);
+		 (unsigned long int)vsi->net_stats_offsets.tx_heartbeat_errors,
+		 (unsigned long int)vsi->net_stats_offsets.tx_window_errors);
 	dev_info(&pf->pdev->dev,
 		 "    net_stats_offsets: rx_compressed = %lu, tx_compressed = %lu\n",
-		 (long unsigned int)vsi->net_stats_offsets.rx_compressed,
-		 (long unsigned int)vsi->net_stats_offsets.tx_compressed);
+		 (unsigned long int)vsi->net_stats_offsets.rx_compressed,
+		 (unsigned long int)vsi->net_stats_offsets.tx_compressed);
 	dev_info(&pf->pdev->dev,
 		 "    tx_restart = %d, tx_busy = %d, rx_buf_failed = %d, rx_page_failed = %d\n",
 		 vsi->tx_restart, vsi->tx_busy,
@@ -487,6 +487,7 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 	rcu_read_lock();
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
 		struct i40e_ring *rx_ring = ACCESS_ONCE(vsi->rx_rings[i]);
+
 		if (!rx_ring)
 			continue;
 
@@ -527,7 +528,7 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 		dev_info(&pf->pdev->dev,
 			 "    rx_rings[%i]: size = %i, dma = 0x%08lx\n",
 			 i, rx_ring->size,
-			 (long unsigned int)rx_ring->dma);
+			 (unsigned long int)rx_ring->dma);
 		dev_info(&pf->pdev->dev,
 			 "    rx_rings[%i]: vsi = %p, q_vector = %p\n",
 			 i, rx_ring->vsi,
@@ -535,6 +536,7 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 	}
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
 		struct i40e_ring *tx_ring = ACCESS_ONCE(vsi->tx_rings[i]);
+
 		if (!tx_ring)
 			continue;
 
@@ -573,7 +575,7 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 		dev_info(&pf->pdev->dev,
 			 "    tx_rings[%i]: size = %i, dma = 0x%08lx\n",
 			 i, tx_ring->size,
-			 (long unsigned int)tx_ring->dma);
+			 (unsigned long int)tx_ring->dma);
 		dev_info(&pf->pdev->dev,
 			 "    tx_rings[%i]: vsi = %p, q_vector = %p\n",
 			 i, tx_ring->vsi,
@@ -743,6 +745,7 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 	ring = &(hw->aq.asq);
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
+
 		dev_info(&pf->pdev->dev,
 			 "   at[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
 			 i, d->flags, d->opcode, d->datalen, d->retval,
@@ -755,6 +758,7 @@ static void i40e_dbg_dump_aq_desc(struct i40e_pf *pf)
 	ring = &(hw->aq.arq);
 	for (i = 0; i < ring->count; i++) {
 		struct i40e_aq_desc *d = I40E_ADMINQ_DESC(*ring, i);
+
 		dev_info(&pf->pdev->dev,
 			 "   ar[%02d] flags=0x%04x op=0x%04x dlen=0x%04x ret=0x%04x cookie_h=0x%08x cookie_l=0x%08x\n",
 			 i, d->flags, d->opcode, d->datalen, d->retval,
@@ -1038,7 +1042,13 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			dev_info(&pf->pdev->dev, "'%s' failed\n", cmd_buf);
 
 	} else if (strncmp(cmd_buf, "del vsi", 7) == 0) {
-		sscanf(&cmd_buf[7], "%i", &vsi_seid);
+		cnt = sscanf(&cmd_buf[7], "%i", &vsi_seid);
+		if (cnt != 1) {
+			dev_info(&pf->pdev->dev,
+				 "del vsi: bad command string, cnt=%d\n",
+				 cnt);
+			goto command_write_done;
+		}
 		vsi = i40e_dbg_find_vsi(pf, vsi_seid);
 		if (!vsi) {
 			dev_info(&pf->pdev->dev, "del VSI %d: seid not found\n",
@@ -1488,6 +1498,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 	} else if (strncmp(cmd_buf, "read", 4) == 0) {
 		u32 address;
 		u32 value;
+
 		cnt = sscanf(&cmd_buf[4], "%i", &address);
 		if (cnt != 1) {
 			dev_info(&pf->pdev->dev, "read <reg>\n");
@@ -1507,6 +1518,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 
 	} else if (strncmp(cmd_buf, "write", 5) == 0) {
 		u32 address, value;
+
 		cnt = sscanf(&cmd_buf[5], "%i %i", &address, &value);
 		if (cnt != 2) {
 			dev_info(&pf->pdev->dev, "write <reg> <value>\n");
@@ -1528,6 +1540,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			cnt = sscanf(&cmd_buf[15], "%i", &vsi_seid);
 			if (cnt == 0) {
 				int i;
+
 				for (i = 0; i < pf->num_alloc_vsi; i++)
 					i40e_vsi_reset_stats(pf->vsi[i]);
 				dev_info(&pf->pdev->dev, "vsi clear stats called for all vsi's\n");
@@ -1726,8 +1739,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				   packet_len, I40E_FDIR_MAX_RAW_PACKET_SIZE);
 
 		for (i = 0; i < packet_len; i++) {
-			sscanf(&asc_packet[j], "%2hhx ",
-			       &raw_packet[i]);
+			cnt = sscanf(&asc_packet[j], "%2hhx ", &raw_packet[i]);
+			if (!cnt)
+				break;
 			j += 3;
 		}
 		dev_info(&pf->pdev->dev, "FD raw packet dump\n");
@@ -1755,6 +1769,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 	} else if (strncmp(cmd_buf, "lldp", 4) == 0) {
 		if (strncmp(&cmd_buf[5], "stop", 4) == 0) {
 			int ret;
+
 			ret = i40e_aq_stop_lldp(&pf->hw, false, NULL);
 			if (ret) {
 				dev_info(&pf->pdev->dev,
@@ -1779,6 +1794,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 #endif /* CONFIG_I40E_DCB */
 		} else if (strncmp(&cmd_buf[5], "start", 5) == 0) {
 			int ret;
+
 			ret = i40e_aq_add_rem_control_packet_filter(&pf->hw,
 						pf->hw.mac.addr,
 						I40E_ETH_P_LLDP, 0,
@@ -1807,6 +1823,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			u16 llen, rlen;
 			int ret;
 			u8 *buff;
+
 			buff = kzalloc(I40E_LLDPDU_SIZE, GFP_KERNEL);
 			if (!buff)
 				goto command_write_done;
@@ -1833,6 +1850,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			u16 llen, rlen;
 			int ret;
 			u8 *buff;
+
 			buff = kzalloc(I40E_LLDPDU_SIZE, GFP_KERNEL);
 			if (!buff)
 				goto command_write_done;
@@ -1858,6 +1876,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			buff = NULL;
 		} else if (strncmp(&cmd_buf[5], "event on", 8) == 0) {
 			int ret;
+
 			ret = i40e_aq_cfg_lldp_mib_change_event(&pf->hw,
 								true, NULL);
 			if (ret) {
@@ -1868,6 +1887,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			}
 		} else if (strncmp(&cmd_buf[5], "event off", 9) == 0) {
 			int ret;
+
 			ret = i40e_aq_cfg_lldp_mib_change_event(&pf->hw,
 								false, NULL);
 			if (ret) {
@@ -2105,6 +2125,7 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 		}
 	} else if (strncmp(i40e_dbg_netdev_ops_buf, "change_mtu", 10) == 0) {
 		int mtu;
+
 		cnt = sscanf(&i40e_dbg_netdev_ops_buf[11], "%i %i",
 			     &vsi_seid, &mtu);
 		if (cnt != 2) {
@@ -2220,7 +2241,6 @@ void i40e_dbg_pf_init(struct i40e_pf *pf)
 create_failed:
 	dev_info(dev, "debugfs dir/file for %s failed\n", name);
 	debugfs_remove_recursive(pf->i40e_dbg_pf);
-	return;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5a726f2..148f614 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1360,6 +1360,7 @@ static void i40e_get_ethtool_stats(struct net_device *netdev,
 	if ((pf->lan_veb != I40E_NO_VEB) &&
 	    (pf->flags & I40E_FLAG_VEB_STATS_ENABLED)) {
 		struct i40e_veb *veb = pf->veb[pf->lan_veb];
+
 		for (j = 0; j < I40E_VEB_STATS_LEN; j++) {
 			p = (char *)veb;
 			p += i40e_gstrings_veb_stats[j].stat_offset;
@@ -1607,7 +1608,7 @@ static inline bool i40e_active_vfs(struct i40e_pf *pf)
 	int i;
 
 	for (i = 0; i < pf->num_alloc_vfs; i++)
-		if (vfs[i].vf_states & I40E_VF_STAT_ACTIVE)
+		if (test_bit(I40E_VF_STAT_ACTIVE, &vfs[i].vf_states))
 			return true;
 	return false;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 2398d9b..eaedc1f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -324,7 +324,6 @@ void i40e_init_pf_fcoe(struct i40e_pf *pf)
 	wr32(hw, I40E_GLFCOE_RCTL, val);
 
 	dev_info(&pf->pdev->dev, "FCoE is supported.\n");
-	return;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index fa371a2..79ae7be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -431,9 +431,8 @@ exit_sd_error:
 			pd_idx1 = max(pd_idx,
 				      ((j - 1) * I40E_HMC_MAX_BP_COUNT));
 			pd_lmt1 = min(pd_lmt, (j * I40E_HMC_MAX_BP_COUNT));
-			for (i = pd_idx1; i < pd_lmt1; i++) {
+			for (i = pd_idx1; i < pd_lmt1; i++)
 				i40e_remove_pd_bp(hw, info->hmc_info, i);
-			}
 			i40e_remove_pd_page(hw, info->hmc_info, (j - 1));
 			break;
 		case I40E_SD_TYPE_DIRECT:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 23a7b40..12b90fa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -216,10 +216,10 @@ static int i40e_get_lump(struct i40e_pf *pf, struct i40e_lump_tracking *pile,
 			ret = i;
 			pile->search_hint = i + j;
 			break;
-		} else {
-			/* not enough, so skip over it and continue looking */
-			i += j;
 		}
+
+		/* not enough, so skip over it and continue looking */
+		i += j;
 	}
 
 	return ret;
@@ -503,11 +503,11 @@ void i40e_vsi_reset_stats(struct i40e_vsi *vsi)
 	memset(&vsi->eth_stats_offsets, 0, sizeof(vsi->eth_stats_offsets));
 	if (vsi->rx_rings && vsi->rx_rings[0]) {
 		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			memset(&vsi->rx_rings[i]->stats, 0 ,
+			memset(&vsi->rx_rings[i]->stats, 0,
 			       sizeof(vsi->rx_rings[i]->stats));
-			memset(&vsi->rx_rings[i]->rx_stats, 0 ,
+			memset(&vsi->rx_rings[i]->rx_stats, 0,
 			       sizeof(vsi->rx_rings[i]->rx_stats));
-			memset(&vsi->tx_rings[i]->stats, 0 ,
+			memset(&vsi->tx_rings[i]->stats, 0,
 			       sizeof(vsi->tx_rings[i]->stats));
 			memset(&vsi->tx_rings[i]->tx_stats, 0,
 			       sizeof(vsi->tx_rings[i]->tx_stats));
@@ -843,6 +843,7 @@ static void i40e_update_prio_xoff_rx(struct i40e_pf *pf)
 
 	for (i = 0; i < I40E_MAX_USER_PRIORITY; i++) {
 		u64 prio_xoff = nsd->priority_xoff_rx[i];
+
 		i40e_stat_update32(hw, I40E_GLPRT_PXOFFRXC(hw->port, i),
 				   pf->stat_offsets_loaded,
 				   &osd->priority_xoff_rx[i],
@@ -1439,6 +1440,7 @@ void i40e_del_filter(struct i40e_vsi *vsi,
 	} else {
 		/* make sure we don't remove a filter in use by VF or netdev */
 		int min_f = 0;
+
 		min_f += (f->is_vf ? 1 : 0);
 		min_f += (f->is_netdev ? 1 : 0);
 
@@ -1497,6 +1499,7 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 
 	if (vsi->type == I40E_VSI_MAIN) {
 		i40e_status ret;
+
 		ret = i40e_aq_mac_address_write(&vsi->back->hw,
 						I40E_AQC_WRITE_TYPE_LAA_WOL,
 						addr->sa_data, NULL);
@@ -1932,6 +1935,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 	/* check for changes in promiscuous modes */
 	if (changed_flags & IFF_ALLMULTI) {
 		bool cur_multipromisc;
+
 		cur_multipromisc = !!(vsi->current_netdev_flags & IFF_ALLMULTI);
 		ret = i40e_aq_set_vsi_multicast_promiscuous(&vsi->back->hw,
 							    vsi->seid,
@@ -1946,6 +1950,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi, bool grab_rtnl)
 	}
 	if ((changed_flags & IFF_PROMISC) || promisc_forced_on) {
 		bool cur_promisc;
+
 		cur_promisc = (!!(vsi->current_netdev_flags & IFF_PROMISC) ||
 			       test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 					&vsi->state));
@@ -3259,6 +3264,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 
 		/* temporarily disable queue cause for NAPI processing */
 		u32 qval = rd32(hw, I40E_QINT_RQCTL(0));
+
 		qval &= ~I40E_QINT_RQCTL_CAUSE_ENA_MASK;
 		wr32(hw, I40E_QINT_RQCTL(0), qval);
 
@@ -3428,9 +3434,9 @@ static bool i40e_clean_fdir_tx_irq(struct i40e_ring *tx_ring, int budget)
 	i += tx_ring->count;
 	tx_ring->next_to_clean = i;
 
-	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
+	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED)
 		i40e_irq_dynamic_enable(vsi, tx_ring->q_vector->v_idx);
-	}
+
 	return budget > 0;
 }
 
@@ -4034,11 +4040,10 @@ static void i40e_quiesce_vsi(struct i40e_vsi *vsi)
 	}
 
 	set_bit(__I40E_NEEDS_RESTART, &vsi->state);
-	if (vsi->netdev && netif_running(vsi->netdev)) {
+	if (vsi->netdev && netif_running(vsi->netdev))
 		vsi->netdev->netdev_ops->ndo_stop(vsi->netdev);
-	} else {
+	else
 		i40e_vsi_close(vsi);
-	}
 }
 
 /**
@@ -5313,15 +5318,13 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 			 "VSI reinit requested\n");
 		for (v = 0; v < pf->num_alloc_vsi; v++) {
 			struct i40e_vsi *vsi = pf->vsi[v];
+
 			if (vsi != NULL &&
 			    test_bit(__I40E_REINIT_REQUESTED, &vsi->state)) {
 				i40e_vsi_reinit_locked(pf->vsi[v]);
 				clear_bit(__I40E_REINIT_REQUESTED, &vsi->state);
 			}
 		}
-
-		/* no further action needed, so return now */
-		return;
 	} else if (reset_flags & BIT_ULL(__I40E_DOWN_REQUESTED)) {
 		int v;
 
@@ -5329,6 +5332,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		dev_info(&pf->pdev->dev, "VSI down requested\n");
 		for (v = 0; v < pf->num_alloc_vsi; v++) {
 			struct i40e_vsi *vsi = pf->vsi[v];
+
 			if (vsi != NULL &&
 			    test_bit(__I40E_DOWN_REQUESTED, &vsi->state)) {
 				set_bit(__I40E_DOWN, &vsi->state);
@@ -5336,13 +5340,9 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 				clear_bit(__I40E_DOWN_REQUESTED, &vsi->state);
 			}
 		}
-
-		/* no further action needed, so return now */
-		return;
 	} else {
 		dev_info(&pf->pdev->dev,
 			 "bad reset request 0x%08x\n", reset_flags);
-		return;
 	}
 }
 
@@ -6286,6 +6286,7 @@ static int i40e_reconstitute_veb(struct i40e_veb *veb)
 
 		if (pf->vsi[v]->veb_idx == veb->idx) {
 			struct i40e_vsi *vsi = pf->vsi[v];
+
 			vsi->uplink_seid = veb->seid;
 			ret = i40e_add_vsi(vsi);
 			if (ret) {
@@ -9700,6 +9701,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 	} else {
 		/* force a reset of TC and queue layout configurations */
 		u8 enabled_tc = pf->vsi[pf->lan_vsi]->tc_config.enabled_tc;
+
 		pf->vsi[pf->lan_vsi]->tc_config.enabled_tc = 0;
 		pf->vsi[pf->lan_vsi]->seid = pf->main_vsi_seid;
 		i40e_vsi_config_tc(pf->vsi[pf->lan_vsi], enabled_tc);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 8c40d6e..552c84e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -618,9 +618,8 @@ static long i40e_ptp_create_clock(struct i40e_pf *pf)
 
 	/* Attempt to register the clock before enabling the hardware. */
 	pf->ptp_clock = ptp_clock_register(&pf->ptp_caps, &pf->pdev->dev);
-	if (IS_ERR(pf->ptp_clock)) {
+	if (IS_ERR(pf->ptp_clock))
 		return PTR_ERR(pf->ptp_clock);
-	}
 
 	/* clear the hwtstamp settings here during clock create, instead of
 	 * during regular init, so that we can maintain settings across a
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 8ab7ab1..01e5ece 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1522,6 +1522,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		cleaned_count++;
 		if (rx_hbo || rx_sph) {
 			int len;
+
 			if (rx_hbo)
 				len = I40E_RX_HDR_SIZE;
 			else
@@ -1707,9 +1708,6 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(rx_error & BIT(I40E_RX_DESC_ERROR_RXE_SHIFT))) {
 			dev_kfree_skb_any(skb);
-			/* TODO: shouldn't we increment a counter indicating the
-			 * drop?
-			 */
 			continue;
 		}
 
@@ -2081,6 +2079,7 @@ static inline int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 	/* else if it is a SW VLAN, check the next protocol and store the tag */
 	} else if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_hdr *vhdr, _vhdr;
+
 		vhdr = skb_header_pointer(skb, ETH_HLEN, sizeof(_vhdr), &_vhdr);
 		if (!vhdr)
 			return -EINVAL;
@@ -2740,6 +2739,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	u8 hdr_len = 0;
 	int tsyn;
 	int tso;
+
 	if (0 == i40e_xmit_descriptor_count(skb, tx_ring))
 		return NETDEV_TX_BUSY;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index ac3fb3a..75cecfa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -165,6 +165,7 @@ struct i40e_tx_buffer {
 	};
 	unsigned int bytecount;
 	unsigned short gso_segs;
+
 	DEFINE_DMA_UNMAP_ADDR(dma);
 	DEFINE_DMA_UNMAP_LEN(len);
 	u32 tx_flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index fac8a02..678623f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -536,6 +536,7 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 	}
 	if (type == I40E_VSI_SRIOV) {
 		u8 brdcast[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+
 		vf->lan_vsi_idx = vsi->idx;
 		vf->lan_vsi_id = vsi->id;
 		/* If the port VLAN has been configured and then the
@@ -605,6 +606,7 @@ static void i40e_enable_vf_mappings(struct i40e_vf *vf)
 	/* map PF queues to VF queues */
 	for (j = 0; j < pf->vsi[vf->lan_vsi_idx]->alloc_queue_pairs; j++) {
 		u16 qid = i40e_vc_get_pf_queue_id(vf, vf->lan_vsi_id, j);
+
 		reg = (qid & I40E_VPLAN_QTABLE_QINDEX_MASK);
 		wr32(hw, I40E_VPLAN_QTABLE(total_queue_pairs, vf->vf_id), reg);
 		total_queue_pairs++;
@@ -991,7 +993,7 @@ static int i40e_pci_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	int pre_existing_vfs = pci_num_vf(pdev);
 	int err = 0;
 
-	if (pf->state & __I40E_TESTING) {
+	if (test_bit(__I40E_TESTING, &pf->state)) {
 		dev_warn(&pdev->dev,
 			 "Cannot enable SR-IOV virtual functions while the device is undergoing diagnostic testing\n");
 		err = -EPERM;
@@ -1210,8 +1212,8 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 		vfres->vsi_res[i].vsi_type = I40E_VSI_SRIOV;
 		vfres->vsi_res[i].num_queue_pairs =
 		    pf->vsi[vf->lan_vsi_idx]->alloc_queue_pairs;
-		memcpy(vfres->vsi_res[i].default_mac_addr,
-		       vf->default_lan_addr.addr, ETH_ALEN);
+		ether_addr_copy(vfres->vsi_res[i].default_mac_addr,
+				vf->default_lan_addr.addr);
 		i++;
 	}
 	set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
@@ -1715,6 +1717,7 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	for (i = 0; i < vfl->num_elements; i++) {
 		/* add new VLAN filter */
 		int ret = i40e_vsi_add_vlan(vsi, vfl->vlan_id[i]);
+
 		if (ret)
 			dev_err(&pf->pdev->dev,
 				"Unable to add VF vlan filter %d, error %d\n",
@@ -1766,6 +1769,7 @@ static int i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	for (i = 0; i < vfl->num_elements; i++) {
 		int ret = i40e_vsi_kill_vlan(vsi, vfl->vlan_id[i]);
+
 		if (ret)
 			dev_err(&pf->pdev->dev,
 				"Unable to delete VF vlan filter %d, error %d\n",
@@ -1877,7 +1881,6 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 	case I40E_VIRTCHNL_OP_UNKNOWN:
 	default:
 		return -EPERM;
-		break;
 	}
 	/* few more checks */
 	if ((valid_len != msglen) || (err_msg_format)) {
@@ -2316,7 +2319,7 @@ int i40e_ndo_get_vf_config(struct net_device *netdev,
 
 	ivi->vf = vf_id;
 
-	memcpy(&ivi->mac, vf->default_lan_addr.addr, ETH_ALEN);
+	ether_addr_copy(ivi->mac, vf->default_lan_addr.addr);
 
 	ivi->max_tx_rate = vf->tx_rate;
 	ivi->min_tx_rate = 0;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index c5cf886..3eba369 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -622,8 +622,7 @@ static u16 i40e_clean_asq(struct i40e_hw *hw)
 	details = I40E_ADMINQ_DETAILS(*asq, ntc);
 	while (rd32(hw, hw->aq.asq.head) != ntc) {
 		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
-			   "%s: ntc %d head %d.\n", __func__, ntc,
-			   rd32(hw, hw->aq.asq.head));
+			   "ntc %d head %d.\n", ntc, rd32(hw, hw->aq.asq.head));
 
 		if (details->callback) {
 			I40E_ADMINQ_CALLBACK cb_func =
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 96e48ee..b98b642 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -992,10 +992,10 @@ void i40e_vf_parse_hw_config(struct i40e_hw *hw,
 			     I40E_VIRTCHNL_VF_OFFLOAD_FCOE) ? 1 : 0;
 	for (i = 0; i < msg->num_vsis; i++) {
 		if (vsi_res->vsi_type == I40E_VSI_SRIOV) {
-			memcpy(hw->mac.perm_addr, vsi_res->default_mac_addr,
-			       ETH_ALEN);
-			memcpy(hw->mac.addr, vsi_res->default_mac_addr,
-			       ETH_ALEN);
+			ether_addr_copy(hw->mac.perm_addr,
+					vsi_res->default_mac_addr);
+			ether_addr_copy(hw->mac.addr,
+					vsi_res->default_mac_addr);
 		}
 		vsi_res++;
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 3b102f2..0e71eb4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -987,6 +987,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		cleaned_count++;
 		if (rx_hbo || rx_sph) {
 			int len;
+
 			if (rx_hbo)
 				len = I40E_RX_HDR_SIZE;
 			else
@@ -1160,9 +1161,6 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(rx_error & BIT(I40E_RX_DESC_ERROR_RXE_SHIFT))) {
 			dev_kfree_skb_any(skb);
-			/* TODO: shouldn't we increment a counter indicating the
-			 * drop?
-			 */
 			continue;
 		}
 
@@ -1358,6 +1356,7 @@ static inline int i40evf_tx_prepare_vlan_flags(struct sk_buff *skb,
 	/* else if it is a SW VLAN, check the next protocol and store the tag */
 	} else if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_hdr *vhdr, _vhdr;
+
 		vhdr = skb_header_pointer(skb, ETH_HLEN, sizeof(_vhdr), &_vhdr);
 		if (!vhdr)
 			return -EINVAL;
@@ -1900,6 +1899,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	u32 td_cmd = 0;
 	u8 hdr_len = 0;
 	int tso;
+
 	if (0 == i40evf_xmit_descriptor_count(skb, tx_ring))
 		return NETDEV_TX_BUSY;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 93b90f7..0c13ece 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -164,6 +164,7 @@ struct i40e_tx_buffer {
 	};
 	unsigned int bytecount;
 	unsigned short gso_segs;
+
 	DEFINE_DMA_UNMAP_ADDR(dma);
 	DEFINE_DMA_UNMAP_LEN(len);
 	u32 tx_flags;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 3817cbb..27dc3fe 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -48,10 +48,6 @@
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
 #define PFX "i40evf: "
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	((void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__func__ , ## args)))
 
 /* dummy struct to make common code less painful */
 struct i40e_vsi {
-- 
2.4.3
