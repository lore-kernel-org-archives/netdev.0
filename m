From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 05/12] net: Add ndo_set_vif_param operation to serve eIPoIB VIFs
Date: Wed,  1 Aug 2012 20:09:28 +0300
Message-ID: <1343840975-3252-6-git-send-email-ogerlitz@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:47536 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753373Ab2HARKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:10:03 -0400
In-Reply-To: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

The Ethernet IPoIB driver enslaves IPoIB devices and uses them as
VIFs (Virtual Interface) which serve an Ethernet NIC e.g present in a 
guest OS. For each such slave that acts as a VIF, eIPoIB needs to know 
the mac and optionally the vlan uses by that NIC, the new ndo opertaion 
is used to associate the mac/vlan for that slave.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/netdevice.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index eb06e58..2709551 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1013,7 +1013,10 @@ struct net_device_ops {
 						    netdev_features_t features);
 	int			(*ndo_neigh_construct)(struct neighbour *n);
 	void			(*ndo_neigh_destroy)(struct neighbour *n);
-
+	int			(*ndo_set_vif_param) (struct net_device *dev,
+						      struct net_device *vif,
+						      u16 vlan,
+						      u8 *mac);
 	int			(*ndo_fdb_add)(struct ndmsg *ndm,
 					       struct net_device *dev,
 					       unsigned char *addr,
-- 
1.7.1
