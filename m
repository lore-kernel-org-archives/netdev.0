From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] e1000e: Call e1000e_config_collision_dist()
	after TCTL has been set
Date: Mon, 08 Jun 2009 17:28:36 -0700
Message-ID: <20090609002836.4909.16489.stgit@localhost.localdomain>
References: <20090609002817.4909.44004.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Simon Horman <horms@verge.net.au>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:37606 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751478AbZFIA2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 20:28:51 -0400
In-Reply-To: <20090609002817.4909.44004.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

e1000e_config_collision_dist() sets tctl, but subsequently tctl is
overwritten.  It seems to me that as things stand the call to
e1000e_config_collision_dist() has no effect and should either be
removed or moved down a little bit.  This kernel patch takes the latter
option.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 9043f1b..677f604 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2256,8 +2256,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		ew32(TARC(1), tarc);
 	}
 
-	e1000e_config_collision_dist(hw);
-
 	/* Setup Transmit Descriptor Settings for eop descriptor */
 	adapter->txd_cmd = E1000_TXD_CMD_EOP | E1000_TXD_CMD_IFCS;
 
@@ -2270,6 +2268,8 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	ew32(TCTL, tctl);
 
+	e1000e_config_collision_dist(hw);
+
 	adapter->tx_queue_len = adapter->netdev->tx_queue_len;
 }
 

