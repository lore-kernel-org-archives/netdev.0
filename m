From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/5] ixgbe: Return error when getting PHY address if PHY access is not supported
Date: Mon,  9 Oct 2017 08:12:47 -0700
Message-ID: <20171009151251.53939-2-jeffrey.t.kirsher@intel.com>
References: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Cc: Mark D Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:48022 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752528AbdJIPNO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 11:13:14 -0400
In-Reply-To: <20171009151251.53939-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark D Rustad <mark.d.rustad@intel.com>

In cases where PHY register access is not supported, don't mislead
a caller into thinking that it is supported by returning a PHY
address. Instead, return -EOPNOTSUPP when PHY access is not
supported.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d962368d08d0..822cdb4f2c25 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8529,6 +8529,10 @@ static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
 		return ixgbe_ptp_set_ts_config(adapter, req);
 	case SIOCGHWTSTAMP:
 		return ixgbe_ptp_get_ts_config(adapter, req);
+	case SIOCGMIIPHY:
+		if (!adapter->hw.phy.ops.read_reg)
+			return -EOPNOTSUPP;
+		/* fall through */
 	default:
 		return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
 	}
-- 
2.14.2
