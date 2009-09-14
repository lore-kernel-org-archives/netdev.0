From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: Properly disable packet split per-ring
	when globally disabled
Date: Mon, 14 Sep 2009 10:47:27 -0700
Message-ID: <20090914174659.4560.28814.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:43909
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751242AbZINRro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 13:47:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The packet split feature was recently moved out of the adapter-wide flags
feature field and into a per-Rx ring feature field.  In the process, packet
split isn't properly disabled in the Rx ring if the adapter has it globally
disabled, followed by a device reset.

This won't impact the driver today, since it's always in packet split mode.
However, this will prevent any pitfalls if someone disables packet split on
the adapter in the future and doesn't disable it in each ring.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 45bf8b9..b47aaa8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2055,6 +2055,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)
 			rx_ring->flags |= IXGBE_RING_RX_PS_ENABLED;
+		else
+			rx_ring->flags &= ~IXGBE_RING_RX_PS_ENABLED;
 
 #ifdef IXGBE_FCOE
 		if (netdev->features & NETIF_F_FCOE_MTU) {

