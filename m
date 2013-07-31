From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 1/6] qlcnic: Add ethtool statistics for board temperature.
Date: Tue, 30 Jul 2013 21:54:19 -0400
Message-ID: <6a88678cfe46e0e4f639e8f80834dd3e4b46fdd1.1375244889.git.himanshu.madhani@qlogic.com>
References: <cover.1375244889.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35172 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751612Ab3GaCWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:22:07 -0400
In-Reply-To: <cover.1375244889.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Added ethtool statistics to display adapter board
  temperature.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         | 1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 5 +++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 2 ++
 3 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index b00cf56..ac4160c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -490,6 +490,7 @@ struct qlcnic_adapter_stats {
 	u64  tx_dma_map_error;
 	u64  spurious_intr;
 	u64  mac_filter_limit_overrun;
+	u64  board_temperature;
 };
 
 /*
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 700a463..6edebe2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -53,6 +53,8 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 				QLC_OFF(stats.mac_filter_limit_overrun)},
 	{"spurious intr", QLC_SIZEOF(stats.spurious_intr),
 	 QLC_OFF(stats.spurious_intr)},
+	{"board_temperature", QLC_SIZEOF(stats.board_temperature),
+	 QLC_OFF(stats.board_temperature)},
 
 };
 
@@ -1147,6 +1149,9 @@ static void qlcnic_get_ethtool_stats(struct net_device *dev,
 
 	memset(data, 0, stats->n_stats * sizeof(u64));
 	length = QLCNIC_STATS_LEN;
+
+	qlcnic_check_temp(adapter);
+
 	for (index = 0; index < length; index++) {
 		p = (char *)adapter + qlcnic_gstrings_stats[index].stat_offset;
 		size = qlcnic_gstrings_stats[index].sizeof_stat;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4528f8e..7d5a932 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2457,6 +2457,8 @@ int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 		}
 	}
 	adapter->ahw->temp = temp_state;
+	adapter->stats.board_temperature = temp_val;
+
 	return rv;
 }
 
-- 
1.8.1.4
