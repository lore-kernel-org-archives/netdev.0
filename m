From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] skge: Fix skge_set_ring_param() losing error return
Date: Fri, 26 Sep 2008 16:32:50 +0800
Message-ID: <48DC9E32.503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	NETDEV <netdev@vger.kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60269 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751790AbYIZIfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2008 04:35:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 26 Sep 2008 16:20:32 +0800
Subject: [PATCH] skge: Fix skge_set_ring_param() losing error return

The error return is useful to caller, driver shouldn't miss it.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/skge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 2e26dce..4c333a1 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -494,7 +494,7 @@ static int skge_set_ring_param(struct net_device *dev,
 			       struct ethtool_ringparam *p)
 {
 	struct skge_port *skge = netdev_priv(dev);
-	int err;
+	int err = 0;
 
 	if (p->rx_pending == 0 || p->rx_pending > MAX_RX_RING_SIZE ||
 	    p->tx_pending < TX_LOW_WATER || p->tx_pending > MAX_TX_RING_SIZE)
@@ -510,7 +510,7 @@ static int skge_set_ring_param(struct net_device *dev,
 			dev_close(dev);
 	}
 
-	return 0;
+	return err;
 }
 
 static u32 skge_get_msglevel(struct net_device *netdev)
-- 
1.5.5.1

