From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 5/7] e1000e: increase minimum frame size allowed
Date: Fri, 08 Aug 2008 18:36:06 -0700
Message-ID: <20080809013606.23913.73166.stgit@localhost.localdomain>
References: <20080809013544.23913.47157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44110 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755937AbYHIBgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 21:36:09 -0400
In-Reply-To: <20080809013544.23913.47157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Setting an MTU value below 68 was disabling the network connection and
would not reconnect until the driver was reloaded.  Prevent changing the
MTU to anything below 68.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4573c7b..b8b26cf 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3724,7 +3724,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
+	if ((new_mtu < ETH_ZLEN + ETH_FCS_LEN + VLAN_HLEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
 		e_err("Invalid MTU setting\n");
 		return -EINVAL;

