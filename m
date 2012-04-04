From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 07/26] ethtool: Add a common function for drivers with transmit time stamping.
Date: Wed,  4 Apr 2012 10:59:22 +0200
Message-ID: <eb13210fb73cd900f872dfa64f20af2a6c0918a1.1333529506.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56171 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100Ab2DDJAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:00:25 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so46815wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:00:25 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, most drivers do not support transmit SO_TIMESTAMPING. For those
that do support it, there is one appropriate response to the get_ts_info
query. This patch adds a common function providing this response.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    1 +
 net/core/ethtool.c      |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 1769714..560a247 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -811,6 +811,7 @@ struct net_device;
 
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
+int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *eti);
 
 /**
  * ethtool_rxfh_indir_default - get default value for RX flow hash indirection
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a723b13..beacdd9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -38,6 +38,17 @@ u32 ethtool_op_get_link(struct net_device *dev)
 }
 EXPORT_SYMBOL(ethtool_op_get_link);
 
+int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
+{
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE;
+	info->phc_index = -1;
+	return 0;
+}
+EXPORT_SYMBOL(ethtool_op_get_ts_info);
+
 /* Handlers for each ethtool command */
 
 #define ETHTOOL_DEV_FEATURE_WORDS	((NETDEV_FEATURE_COUNT + 31) / 32)
-- 
1.7.2.5
