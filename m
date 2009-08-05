From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] net: Changes to support the "-f" option of
	ethtool.
Date: Wed, 5 Aug 2009 18:02:13 +0530
Message-ID: <20090805123211.GB6592@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:8046 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S933564AbZHEMcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 08:32:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds kernel support for the new "-f" option in ethtool,
This will allow a firmware image to be flashed to a network device.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 include/linux/ethtool.h |    3 +++
 net/core/ethtool.c      |   13 +++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 90c4a36..9b92f44 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -489,6 +489,7 @@ struct ethtool_ops {
 	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
 	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
+	int     (*flash_device)(struct net_device *);
 };
 #endif /* __KERNEL__ */
 
@@ -545,6 +546,8 @@ struct ethtool_ops {
 #define	ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
 #define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
+#define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device
+					    * (ethtool_value). */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 44e5711..0524201 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -898,6 +898,16 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
 	return actor(dev, edata.data);
 }
 
+static int ethtool_flash_device(struct net_device *dev)
+{
+	int err;
+
+	if (!dev->ethtool_ops->flash_device)
+		return -EOPNOTSUPP;
+
+	return dev->ethtool_ops->flash_device(dev);
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1111,6 +1121,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SGRO:
 		rc = ethtool_set_gro(dev, useraddr);
 		break;
+	case ETHTOOL_FLASHDEV:
+		rc = ethtool_flash_device(dev);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.6.0.4

