From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] ethtool: Don't flush n-tuple list from ethtool_reset()
Date: Wed, 17 Feb 2010 19:26:54 +0000
Message-ID: <1266434814.2090.6.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8971 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab0BQT1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 14:27:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The n-tuple list should be flushed if and only if the ETH_RESET_FILTER
flag is set and the driver is able to reset filtering/flow direction
hardware without also resetting a component whose flag is not set.
This test is best left to the driver.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/ethtool.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d08a0c7..31b1edd 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -654,9 +654,6 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
 	if (copy_from_user(&reset, useraddr, sizeof(reset)))
 		return -EFAULT;
 
-	/* Clear ethtool n-tuple list */
-	ethtool_ntuple_flush(dev);
-
 	ret = dev->ethtool_ops->reset(dev, &reset.data);
 	if (ret)
 		return ret;
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

