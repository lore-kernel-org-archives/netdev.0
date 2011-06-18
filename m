From: greearb@candelatech.com
Subject: [PATCH v2 1/5] net:  Support ethtool ops for rx of errored frames.
Date: Sat, 18 Jun 2011 13:47:21 -0700
Message-ID: <1308430045-24816-2-git-send-email-greearb@candelatech.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33319 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab1FRUrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:47:48 -0400
In-Reply-To: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This can be useful when sniffing dodgy networks.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 675ddc0... fb0fac9... M	include/linux/ethtool.h
:100644 100644 0e01860... 443a63c... M	net/core/ethtool.c
 include/linux/ethtool.h |    7 +++++++
 net/core/ethtool.c      |    8 ++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 675ddc0..fb0fac9 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -880,6 +880,9 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  * @set_save_rxfcs:  Set flag to save (1), or discard (0), the Ethernet
  *	Frame Checksum for received packets.
  * @get_save_rxfcs:  Get current value for Save RX-FCS flag.
+ * @set_save_rxerr:  Set flag to save (1), or discard (0), received Ethernet
+ *	frames with errors (bad checksum, etc)
+ * @get_save_rxerr:  Get current value for Save RX-ERR flag.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -960,6 +963,8 @@ struct ethtool_ops {
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
 	int	(*set_save_rxfcs)(struct net_device *, u32);
 	u32	(*get_save_rxfcs)(struct net_device *);
+	int	(*set_save_rxerr)(struct net_device *, u32);
+	u32	(*get_save_rxerr)(struct net_device *);
 
 };
 #endif /* __KERNEL__ */
@@ -1036,6 +1041,8 @@ struct ethtool_ops {
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
 #define ETHTOOL_GET_SAVE_RXFCS	0x00000041 /* Get RX Save Frame Checksum */
 #define ETHTOOL_SET_SAVE_RXFCS	0x00000042 /* Set RX Save Frame Checksum */
+#define ETHTOOL_GET_SAVE_RXERR	0x00000043 /* Get RX Save Errored Frames */
+#define ETHTOOL_SET_SAVE_RXERR	0x00000044 /* Set RX Save Errored Frames */
 
 
 /* compatibility with older code */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 0e01860..443a63c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2160,6 +2160,14 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		rc =  ethtool_get_value(dev, useraddr, ethcmd,
 					dev->ethtool_ops->get_save_rxfcs);
 		break;
+	case ETHTOOL_SET_SAVE_RXERR:
+		rc = ethtool_set_value(dev, useraddr,
+				       dev->ethtool_ops->set_save_rxerr);
+		break;
+	case ETHTOOL_GET_SAVE_RXERR:
+		rc =  ethtool_get_value(dev, useraddr, ethcmd,
+					dev->ethtool_ops->get_save_rxerr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.3.4

