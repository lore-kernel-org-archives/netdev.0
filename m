From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/11] ixgbe: When in DCB mode with PFC enabled,
	show LFC is disabled
Date: Sun, 17 May 2009 15:35:36 -0700
Message-ID: <20090517223535.14124.44645.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Ethtool should report that link flow control is disabled when in priority
flow control mode.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 6c73243..35255b8 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -254,6 +254,13 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	else
 		pause->autoneg = 1;
 
+#ifdef CONFIG_DCB
+	if (hw->fc.current_mode == ixgbe_fc_pfc) {
+		pause->rx_pause = 0;
+		pause->tx_pause = 0;
+	}
+
+#endif
 	if (hw->fc.current_mode == ixgbe_fc_rx_pause) {
 		pause->rx_pause = 1;
 	} else if (hw->fc.current_mode == ixgbe_fc_tx_pause) {

