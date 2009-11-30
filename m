From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 5/6] be2net: Add be_rx_polls counter
Date: Mon, 30 Nov 2009 09:27:22 +0530
Message-ID: <20091130035712.GA15554@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29526 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752761AbZK3D5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 22:57:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add be_rx_polls to count number of times NAPI called rx poll function.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    2 +-
 drivers/net/benet/be_ethtool.c |    2 +-
 drivers/net/benet/be_main.c    |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index dc7c19e..d90cc01 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -170,7 +170,7 @@ struct be_drvr_stats {
 	u32 cache_barrier[16];
 
 	u32 be_ethrx_post_fail;/* number of ethrx buffer alloc failures */
-	u32 be_polls;		/* number of times NAPI called poll function */
+	u32 be_rx_polls;	/* number of times NAPI called poll function */
 	u32 be_rx_events;	/* number of ucast rx completion events  */
 	u32 be_rx_compl;	/* number of rx completion entries processed */
 	ulong be_rx_jiffies;
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 9eabed4..3c05f2b 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -55,7 +55,7 @@ static const struct be_ethtool_stat et_stats[] = {
 	{DRVSTAT_INFO(be_tx_stops)},
 	{DRVSTAT_INFO(be_fwd_reqs)},
 	{DRVSTAT_INFO(be_tx_wrbs)},
-	{DRVSTAT_INFO(be_polls)},
+	{DRVSTAT_INFO(be_rx_polls)},
 	{DRVSTAT_INFO(be_tx_events)},
 	{DRVSTAT_INFO(be_rx_events)},
 	{DRVSTAT_INFO(be_tx_compl)},
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 10262fa..f3e97ab 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1381,6 +1381,7 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 	struct be_eth_rx_compl *rxcp;
 	u32 work_done;
 
+	adapter->stats.drvr_stats.be_rx_polls++;
 	for (work_done = 0; work_done < budget; work_done++) {
 		rxcp = be_rx_compl_get(adapter);
 		if (!rxcp)
-- 
1.6.3.3

