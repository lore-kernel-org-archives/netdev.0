From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/3] sfc: Fix return value from
 efx_ethtool_set_rx_ntuple()
Date: Tue, 17 May 2011 17:04:36 +0100
Message-ID: <1305648276.2848.15.camel@bwh-desktop>
References: <1305647988.2848.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26318 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345Ab1EQQEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 12:04:39 -0400
In-Reply-To: <1305647988.2848.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool_ops::set_rx_ntuple is supposed to return 0 on success, but it
currently returns the filter ID when it inserts or modifies a filter.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 8c5e005..348437a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -955,8 +955,9 @@ static int efx_ethtool_set_rx_ntuple(struct net_device *net_dev,
 
 	if (ntuple->fs.action == ETHTOOL_RXNTUPLE_ACTION_CLEAR)
 		return efx_filter_remove_filter(efx, &filter);
-	else
-		return efx_filter_insert_filter(efx, &filter, true);
+
+	rc = efx_filter_insert_filter(efx, &filter, true);
+	return rc < 0 ? rc : 0;
 }
 
 static int efx_ethtool_get_rxfh_indir(struct net_device *net_dev,
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

