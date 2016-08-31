From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] xgbe: constify get_netdev_ops and get_ethtool_ops
Date: Wed, 31 Aug 2016 08:57:36 -0700
Message-ID: <20160831085736.29fc6512@xeon-e3>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>,
        Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34530 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964891AbcHaP51 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 11:57:27 -0400
Received: by mail-pf0-f169.google.com with SMTP id p64so20866705pfb.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 08:57:27 -0700 (PDT)
In-Reply-To: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Casting away const is bad practice. Since this is ARM specific driver
don't have hardware actually test this.

Having getter functions for ops is really unnecessary code bloat, but
not going to touch that.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     | 4 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c | 4 ++--
 drivers/net/ethernet/amd/xgbe/xgbe.h         | 5 +++--
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index a9b2709..7f9216d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1708,9 +1708,9 @@ static const struct net_device_ops xgbe_netdev_ops = {
 	.ndo_set_features	= xgbe_set_features,
 };
 
-struct net_device_ops *xgbe_get_netdev_ops(void)
+const struct net_device_ops *xgbe_get_netdev_ops(void)
 {
-	return (struct net_device_ops *)&xgbe_netdev_ops;
+	return &xgbe_netdev_ops;
 }
 
 static void xgbe_rx_refresh(struct xgbe_channel *channel)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 11d9f0c..4007b42 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -623,7 +623,7 @@ static const struct ethtool_ops xgbe_ethtool_ops = {
 	.get_ts_info = xgbe_get_ts_info,
 };
 
-struct ethtool_ops *xgbe_get_ethtool_ops(void)
+const struct ethtool_ops *xgbe_get_ethtool_ops(void)
 {
-	return (struct ethtool_ops *)&xgbe_ethtool_ops;
+	return &xgbe_ethtool_ops;
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 98d9d63..5dd17dc 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -956,8 +956,9 @@ struct xgbe_prv_data {
 void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *);
 void xgbe_init_function_ptrs_phy(struct xgbe_phy_if *);
 void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *);
-struct net_device_ops *xgbe_get_netdev_ops(void);
-struct ethtool_ops *xgbe_get_ethtool_ops(void);
+const struct net_device_ops *xgbe_get_netdev_ops(void);
+const struct ethtool_ops *xgbe_get_ethtool_ops(void);
+
 #ifdef CONFIG_AMD_XGBE_DCB
 const struct dcbnl_rtnl_ops *xgbe_get_dcbnl_ops(void);
 #endif
-- 
2.9.3
