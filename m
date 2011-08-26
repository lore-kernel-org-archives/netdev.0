From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/3 net-next] net: Define NETDEV_FCOE_WWNN,
 NETDEV_FCOE_WWPN only when CONFIG_LIBFCOE is enabled
Date: Fri, 26 Aug 2011 12:45:41 -0700
Message-ID: <1314387941-2126-3-git-send-email-mchan@broadcom.com>
References: <1314387941-2126-1-git-send-email-mchan@broadcom.com>
 <1314387941-2126-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Yi Zou" <yi.zou@intel.com>,
	"Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4900 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755035Ab1HZUgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 16:36:45 -0400
In-Reply-To: <1314387941-2126-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

bnx2fc driver calls netdev->netdev_ops->ndo_fcoe_get_wwn() and it may not
be defined with the current Kconfig dependencies.  ndo_fcoe_get_wwn is
dependent on CONFIG_FCOE, but bnx2fc does not select CONFIG_FCOE, as it does
not depend on fcoe driver. Since both fcoe and bnx2fc drivers select
CONFIG_LIBFCOE, define NETDEV_FCOE_WWNN and NETDEV_FCOE_WWPN when
CONFIG_LIBFCOE is defined.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Cc: Yi Zou <yi.zou@intel.com>
Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 include/linux/netdevice.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 125f9fb..0a7f619 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -922,11 +922,15 @@ struct net_device_ops {
 						       u16 xid,
 						       struct scatterlist *sgl,
 						       unsigned int sgc);
+#endif
+
+#if defined(CONFIG_LIBFCOE) || defined(CONFIG_LIBFCOE_MODULE)
 #define NETDEV_FCOE_WWNN 0
 #define NETDEV_FCOE_WWPN 1
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
 						    u64 *wwn, int type);
 #endif
+
 #ifdef CONFIG_RFS_ACCEL
 	int			(*ndo_rx_flow_steer)(struct net_device *dev,
 						     const struct sk_buff *skb,
-- 
1.7.1
