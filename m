From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 03/28] igb: Support the
	get_ts_info ethtool method.
Date: Sun,  1 Apr 2012 17:19:48 +0200
Message-ID: <61a21cb302b5c1c9dec40e422f755c91336aeaaf.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   31 ++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e10821a..245fec0 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2182,6 +2182,36 @@ static void igb_ethtool_complete(struct net_device *netdev)
 	pm_runtime_put(&adapter->pdev->dev);
 }
 
+static int igb_ethtool_get_ts_info(struct net_device *dev,
+				   struct ethtool_ts_info *info)
+{
+	struct igb_adapter *adapter = netdev_priv(dev);
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (adapter->ptp_clock)
+		info->phc_index = ptp_clock_index(adapter->ptp_clock);
+	else
+		info->phc_index = -1;
+
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_ALL) |
+		(1 << HWTSTAMP_FILTER_SOME) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+
+	return 0;
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2210,6 +2240,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.set_coalesce           = igb_set_coalesce,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
+	.get_ts_info		= igb_ethtool_get_ts_info,
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.2.5


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
