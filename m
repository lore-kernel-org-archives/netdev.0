From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/3] netdev: Make ethtool_ops::set_flags()
 return -EINVAL for unsupported flags
Date: Wed, 30 Jun 2010 13:46:56 +0100
Message-ID: <1277902016.2082.12.camel@achroite.uk.solarflarecom.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58721 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab0F3Mq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 08:46:58 -0400
In-Reply-To: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The documented error code for attempts to set unsupported flags (or
to clear flags that cannot be disabled) is EINVAL, not EOPNOTSUPP.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/bnx2x_main.c                |    2 +-
 drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c     |    2 +-
 drivers/net/s2io.c                      |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0809f6c..29e293f 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10983,7 +10983,7 @@ static int bnx2x_set_flags(struct net_device *dev, u32 data)
 	int rc = 0;
 
 	if (data & ~(ETH_FLAG_LRO | ETH_FLAG_RXHASH))
-		return -EOPNOTSUPP;
+		return -EINVAL;
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 6d94ee5..b30de24 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -888,7 +888,7 @@ static int netxen_nic_set_flags(struct net_device *netdev, u32 data)
 	int hw_lro;
 
 	if (data & ~ETH_FLAG_LRO)
-		return -EOPNOTSUPP;
+		return -EINVAL;
 
 	if (!(adapter->capabilities & NX_FW_CAPABILITY_HW_LRO))
 		return -EINVAL;
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index b9d5acb..f8e39e4 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -984,7 +984,7 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
 	int hw_lro;
 
 	if (data & ~ETH_FLAG_LRO)
-		return -EOPNOTSUPP;
+		return -EINVAL;
 
 	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
 		return -EINVAL;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a032d72..22371f1 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6692,7 +6692,7 @@ static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
 	int changed = 0;
 
 	if (data & ~ETH_FLAG_LRO)
-		return -EOPNOTSUPP;
+		return -EINVAL;
 
 	if (data & ETH_FLAG_LRO) {
 		if (lro_enable) {
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

