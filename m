From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 2/2] be2net: fix for default setting of pause
	auto-negotiation
Date: Mon, 13 Apr 2009 13:47:06 +0530
Message-ID: <20090413081705.GE6824@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Ajit Khaparde <ajitk@serverengines.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:21292 "EHLO
	ajitk-desktop" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753133AbZDMIRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 04:17:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This patch fixes the default value of pause auto-negotiation supported by
PCS.

Thanks
Ajit





Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
----
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 04f4b73..9592f22 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -319,7 +319,7 @@ be_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 
 	be_cmd_get_flow_control(&adapter->ctrl, &ecmd->tx_pause,
 		&ecmd->rx_pause);
-	ecmd->autoneg = AUTONEG_ENABLE;
+	ecmd->autoneg = 0;
 }
 
 static int
@@ -328,7 +328,7 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status;
 
-	if (ecmd->autoneg != AUTONEG_ENABLE)
+	if (ecmd->autoneg != 0)
 		return -EINVAL;
 
 	status = be_cmd_set_flow_control(&adapter->ctrl, ecmd->tx_pause,
