From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [PATCH NET-NEXT 09/10] igb: stub support for SIOCSHWTSTAMP
Date: Thu, 12 Feb 2009 16:03:42 +0100
Message-ID: <1234451023-6505-9-git-send-email-patrick.ohly@intel.com>
References: <1234450981.5914.11.camel@ecld0pohly>
 <1234451023-6505-1-git-send-email-patrick.ohly@intel.com>
 <1234451023-6505-2-git-send-email-patrick.ohly@intel.com>
 <1234451023-6505-3-git-send-email-patrick.ohly@intel.com>
 <1234451023-6505-4-git-send-email-patrick.ohly@intel.com>
 <1234451023-6505-5-git-send-email-patrick.ohly@intel.com>
 <1234451023-6505-6-git-send-email-patrick.ohly@intel.com>
 <1234451023-6505-7-git-send-email-patrick.ohly@intel.com>
 <1234451023-6505-8-git-send-email-patrick.ohly@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Stultz <johnstul@us.ibm.com>,
	John Ronciak <john.ronciak@intel.com>,
	Patrick Ohly <patrick.ohly@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6774 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760735AbZBLPEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 10:04:08 -0500
In-Reply-To: <1234451023-6505-8-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 drivers/net/igb/igb_main.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8b2ba42..90090bb 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -34,6 +34,7 @@
 #include <linux/ipv6.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
+#include <linux/net_tstamp.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
@@ -4182,6 +4183,34 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 }
 
 /**
+ * igb_hwtstamp_ioctl - control hardware time stamping
+ * @netdev:
+ * @ifreq:
+ * @cmd:
+ *
+ * Currently cannot enable any kind of hardware time stamping, but
+ * supports SIOCSHWTSTAMP in general.
+ **/
+static int igb_hwtstamp_ioctl(struct net_device *netdev,
+			      struct ifreq *ifr, int cmd)
+{
+	struct hwtstamp_config config;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	if (config.tx_type == HWTSTAMP_TX_OFF &&
+		config.rx_filter == HWTSTAMP_FILTER_NONE)
+		return 0;
+
+	return -ERANGE;
+}
+
+/**
  * igb_ioctl -
  * @netdev:
  * @ifreq:
@@ -4194,6 +4223,8 @@ static int igb_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
 		return igb_mii_ioctl(netdev, ifr, cmd);
+	case SIOCSHWTSTAMP:
+		return igb_hwtstamp_ioctl(netdev, ifr, cmd);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
1.6.1.2

