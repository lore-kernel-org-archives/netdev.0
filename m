From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: cleanup ethtool autoneg input
Date: Tue, 27 Apr 2010 14:31:06 -0700
Message-ID: <20100427213002.25913.93796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:41387 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757159Ab0D0VbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:31:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The way we were setting autoneg via ethtool was inconstant with that
of our other drivers.  It will change the following:

If autoneg is off:
>ethtool -a eth0
Pause parameters for eth0:

Autonegotiate:  off
RX:             off
TX:             off

Before:
>ethtool -A eth0 autoneg on
>ethtool -a eth0
Pause parameters for eth0:

Autonegotiate:  off
RX:             off
TX:             off

Now:
>ethtool -A eth0 autoneg on
>ethtool -a eth0
Pause parameters for eth0:

Autonegotiate:  on
RX:             on
TX:             on

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 5f8c6ab..dfbfe35 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -365,7 +365,7 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	else
 		fc.disable_fc_autoneg = false;
 
-	if (pause->rx_pause && pause->tx_pause)
+	if ((pause->rx_pause && pause->tx_pause) || pause->autoneg)
 		fc.requested_mode = ixgbe_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
 		fc.requested_mode = ixgbe_fc_rx_pause;

