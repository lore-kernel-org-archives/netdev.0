From: Dan Carpenter <error27@gmail.com>
Subject: [patch] ixgbevf: potential NULL dereference on allocation failure
Date: Fri, 10 Sep 2010 13:52:34 +0200
Message-ID: <20100910115234.GB5959@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50565 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab0IJLwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 07:52:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If "rx_ring" is NULL then it will oops when we try:

	memcpy(rx_ring, adapter->rx_ring,
		adapter->num_rx_queues * sizeof(struct ixgbevf_ring));

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
To be honest, I'm not sure why the check for need_tx_update is there.
This change has only been compile tested.

diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
index 4680b06..7f194aa 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -385,7 +385,7 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 	if (new_rx_count != adapter->rx_ring_count) {
 		rx_ring = kcalloc(adapter->num_rx_queues,
 				  sizeof(struct ixgbevf_ring), GFP_KERNEL);
-		if ((!rx_ring) && (need_tx_update)) {
+		if (!rx_ring) {
 			err = -ENOMEM;
 			goto err_rx_setup;
 		}
