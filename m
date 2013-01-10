From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] bnx2x: move debugging code before the return
Date: Thu, 10 Jan 2013 11:58:07 +0300
Message-ID: <20130110085807.GB23063@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32468 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406Ab3AJI6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 03:58:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I move the return down a line after the debugging printk.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 292634f..d7029c8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2768,10 +2768,10 @@ static int bnx2x_set_rss_flags(struct bnx2x *bp, struct ethtool_rxnfc *info)
 		} else if ((info->flow_type == UDP_V6_FLOW) &&
 			   (bp->rss_conf_obj.udp_rss_v6 != udp_rss_requested)) {
 			bp->rss_conf_obj.udp_rss_v6 = udp_rss_requested;
-			return bnx2x_config_rss_pf(bp, &bp->rss_conf_obj, 0);
 			DP(BNX2X_MSG_ETHTOOL,
 			   "rss re-configured, UDP 4-tupple %s\n",
 			   udp_rss_requested ? "enabled" : "disabled");
+			return bnx2x_config_rss_pf(bp, &bp->rss_conf_obj, 0);
 		} else {
 			return 0;
 		}
