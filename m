From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] ixgbe: fix multiple unicast address support
Date: Tue, 10 Mar 2009 19:00:24 -0700
Message-ID: <20090311020024.22904.48769.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Chris Leech <christopher.leech@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:34674 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751667AbZCKCAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 22:00:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Leech <christopher.leech@intel.com>

Multiple unicast address support appears to have been broken with the
change to support net_device_ops.  This a regression from 2.6.28 to 2.6.29.

I'm not 100% on whether ndo_set_multicast_list can be NULL after this
or not.  If ndo_set_rx_mode is set everything _should_ be using it.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d0b9870..8e7a51b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4341,6 +4341,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
 	.ndo_get_stats		= ixgbe_get_stats,
+	.ndo_set_rx_mode        = ixgbe_set_rx_mode,
 	.ndo_set_multicast_list	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbe_set_mac,

