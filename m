From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 3/3] ixgbe: fix the display of DCB control stats in
	ethtool
Date: Fri, 19 Dec 2008 16:15:20 -0800
Message-ID: <20081220001520.5908.65998.stgit@lost.foo-projects.org>
References: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Eric W Multanen <eric.w.multanen@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:52076
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752259AbYLTAPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 19:15:43 -0500
In-Reply-To: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Priority flow contol statistics for Data Center Bridging (DCB) weren't
included in ethtool.  This patch adds them.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index ad9759d..849c1fe 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -881,8 +881,15 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			for (i = 0; i < MAX_TX_PACKET_BUFFERS; i++) {
 				sprintf(p, "tx_pb_%u_pxon", i);
+				p += ETH_GSTRING_LEN;
+				sprintf(p, "tx_pb_%u_pxoff", i);
+				p += ETH_GSTRING_LEN;
 			}
 			for (i = 0; i < MAX_RX_PACKET_BUFFERS; i++) {
+				sprintf(p, "rx_pb_%u_pxon", i);
+				p += ETH_GSTRING_LEN;
+				sprintf(p, "rx_pb_%u_pxoff", i);
+				p += ETH_GSTRING_LEN;
 			}
 		}
 		/* BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */

