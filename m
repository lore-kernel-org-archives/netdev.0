From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: support new firmware statistic fw_err_pki
Date: Mon, 17 Jul 2017 13:33:14 -0700
Message-ID: <20170717203314.GA1327@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0066.outbound.protection.outlook.com ([104.47.37.66]:35040
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751317AbdGQUaR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 16:30:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Added support for new firmware statistic 'tx_err_pki'.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c     | 4 ++++
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h | 1 +
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 28ecda3..976a50f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -105,6 +105,7 @@ static const char oct_stats_strings[][ETH_GSTRING_LEN] = {
 	"tx_total_sent",
 	"tx_total_fwd",
 	"tx_err_pko",
+	"tx_err_pki",
 	"tx_err_link",
 	"tx_err_drop",
 
@@ -826,6 +827,8 @@ lio_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_total_fwd);
 	/*per_core_stats[j].link_stats[i].fromhost.fw_err_pko */
 	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_pko);
+	/*per_core_stats[j].link_stats[i].fromhost.fw_err_pki */
+	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_pki);
 	/*per_core_stats[j].link_stats[i].fromhost.fw_err_link */
 	data[i++] = CVM_CAST64(oct_dev->link_stats.fromhost.fw_err_link);
 	/*per_core_stats[cvmx_get_core_num()].link_stats[idx].fromhost.
@@ -1568,6 +1571,7 @@ octnet_nic_stats_callback(struct octeon_device *oct_dev,
 		tstats->fw_total_sent = rsp_tstats->fw_total_sent;
 		tstats->fw_total_fwd = rsp_tstats->fw_total_fwd;
 		tstats->fw_err_pko = rsp_tstats->fw_err_pko;
+		tstats->fw_err_pki = rsp_tstats->fw_err_pki;
 		tstats->fw_err_link = rsp_tstats->fw_err_link;
 		tstats->fw_err_drop = rsp_tstats->fw_err_drop;
 		tstats->fw_tso = rsp_tstats->fw_tso;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index a479383..7162fb8 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -818,6 +818,7 @@ struct nic_tx_stats {
 	u64 fw_tso;		/* number of tso requests */
 	u64 fw_tso_fwd;		/* number of packets segmented in tso */
 	u64 fw_tx_vxlan;
+	u64 fw_err_pki;
 };
 
 struct oct_link_stats {
