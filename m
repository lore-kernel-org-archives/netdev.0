From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: fix tx queue index
Date: Tue, 14 Apr 2009 20:51:58 -0700
Message-ID: <20090415035155.10107.6878.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Wu Fengguang <fengguang.wu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:58938
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbZDODwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 23:52:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wu Fengguang <fengguang.wu@intel.com>

Don't do the num_tx_queues based masking on calculating tx queue
index.

 1) num_tx_queues is not always power-of-2, because it also depends on
    the online cpu numbers. So the masking could be a performance bug
    on a 6 cpu system.
 2) queue_mapping will be limited by real_num_tx_queues=num_tx_queues
    in the generic netdev function set_cur_queue_map(). So the bound
    limiting here is not necessary.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9ef128a..862dd34 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4342,7 +4342,7 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	int count = 0;
 	unsigned int f;
 
-	r_idx = (adapter->num_tx_queues - 1) & skb->queue_mapping;
+	r_idx = skb->queue_mapping;
 	tx_ring = &adapter->tx_ring[r_idx];
 
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {

