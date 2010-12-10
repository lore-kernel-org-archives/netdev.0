From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 08/10] sfc: Log start and end of ethtool
 self-test at INFO level
Date: Fri, 10 Dec 2010 17:39:08 +0000
Message-ID: <1292002748.11673.22.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27008 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989Ab0LJRjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:39:11 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add message at start of self-test and increase log level of message at
end of self-test, so that any other messages produced during the
test are clearly associated with it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index aae756b..d51a6b1 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -582,6 +582,9 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 		goto fail1;
 	}
 
+	netif_info(efx, drv, efx->net_dev, "starting %sline testing\n",
+		   (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
+
 	/* We need rx buffers and interrupts. */
 	already_up = (efx->net_dev->flags & IFF_UP);
 	if (!already_up) {
@@ -600,9 +603,9 @@ static void efx_ethtool_self_test(struct net_device *net_dev,
 	if (!already_up)
 		dev_close(efx->net_dev);
 
-	netif_dbg(efx, drv, efx->net_dev, "%s %sline self-tests\n",
-		  rc == 0 ? "passed" : "failed",
-		  (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
+	netif_info(efx, drv, efx->net_dev, "%s %sline self-tests\n",
+		   rc == 0 ? "passed" : "failed",
+		   (test->flags & ETH_TEST_FL_OFFLINE) ? "off" : "on");
 
  fail2:
  fail1:
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

