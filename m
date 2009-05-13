From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 8/8] ixgbe: Add FCoE related statistics to 82599
Date: Wed, 13 May 2009 16:12:16 -0700
Message-ID: <20090513231216.11416.9332.stgit@localhost.localdomain>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:47356
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761463AbZEMXMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 19:12:37 -0400
In-Reply-To: <20090513230924.11416.68752.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds FCoE related statistics to 82599, including number Rx-ed and Tx-ed
FCoE packets, number of Rx-ed and Tx-ed FCoE packets in dwords, number of bad
Fiber Channel CRCs detected in FCoE packets, and number of FCoE packets dropped
on the Rx side.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    8 ++++++++
 drivers/net/ixgbe/ixgbe_main.c    |    8 ++++++++
 drivers/net/ixgbe/ixgbe_type.h    |    6 ++++++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index c0167d6..39fb98f 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -91,6 +91,14 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
 	{"rx_no_dma_resources", IXGBE_STAT(hw_rx_no_dma_resources)},
+#ifdef IXGBE_FCOE
+	{"fcoe_bad_fccrc", IXGBE_STAT(stats.fccrc)},
+	{"rx_fcoe_dropped", IXGBE_STAT(stats.fcoerpdc)},
+	{"rx_fcoe_packets", IXGBE_STAT(stats.fcoeprc)},
+	{"rx_fcoe_dwords", IXGBE_STAT(stats.fcoedwrc)},
+	{"tx_fcoe_packets", IXGBE_STAT(stats.fcoeptc)},
+	{"tx_fcoe_dwords", IXGBE_STAT(stats.fcoedwtc)},
+#endif /* IXGBE_FCOE */
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e7c44a3..d69a052 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4002,6 +4002,14 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		IXGBE_READ_REG(hw, IXGBE_TORH); /* to clear */
 		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXCNT);
 		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXCNT);
+#ifdef IXGBE_FCOE
+		adapter->stats.fccrc += IXGBE_READ_REG(hw, IXGBE_FCCRC);
+		adapter->stats.fcoerpdc += IXGBE_READ_REG(hw, IXGBE_FCOERPDC);
+		adapter->stats.fcoeprc += IXGBE_READ_REG(hw, IXGBE_FCOEPRC);
+		adapter->stats.fcoeptc += IXGBE_READ_REG(hw, IXGBE_FCOEPTC);
+		adapter->stats.fcoedwrc += IXGBE_READ_REG(hw, IXGBE_FCOEDWRC);
+		adapter->stats.fcoedwtc += IXGBE_READ_REG(hw, IXGBE_FCOEDWTC);
+#endif /* IXGBE_FCOE */
 	} else {
 		adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
 		adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index b3de723..38f835d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2157,6 +2157,12 @@ struct ixgbe_hw_stats {
 	u64 fdirfstat_fremove;
 	u64 fdirmatch;
 	u64 fdirmiss;
+	u64 fccrc;
+	u64 fcoerpdc;
+	u64 fcoeprc;
+	u64 fcoeptc;
+	u64 fcoedwrc;
+	u64 fcoedwtc;
 };
 
 /* forward declaration */

