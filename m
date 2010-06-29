From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] sfc: set/clear NETIF_F_RXHASH bit directly
Date: Tue, 29 Jun 2010 16:35:20 +0200
Message-ID: <20100629163520.642590bf@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162Ab0F2Off (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 10:35:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/sfc/ethtool.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7693cfb..fd55123 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -554,7 +554,12 @@ static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
 	if (data & ~supported)
 		return -EOPNOTSUPP;
 
-	return ethtool_op_set_flags(net_dev, data);
+	if (data & ETH_FLAG_RXHASH)
+		net_dev->features |= NETIF_F_RXHASH;
+	else
+		net_dev->features &= ~NETIF_F_RXHASH;
+
+	return 0;
 }
 
 static void efx_ethtool_self_test(struct net_device *net_dev,
-- 
1.5.5.6

