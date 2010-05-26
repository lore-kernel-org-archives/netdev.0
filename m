From: Eli Cohen <eli@mellanox.co.il>
Subject: [PATCH] net/core: use net_device dev_id to indicate port number
Date: Wed, 26 May 2010 12:52:00 +0300
Message-ID: <20100526095200.GA7370@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	rdreier@cisco.com, yevgenyp@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:36988 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932591Ab0EZJvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 05:51:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, there are no means to know which port of a hardware device a netdev
interface uses. struct net_device conatins a field, dev_id, that can be used
for that. This patch adds a new macro, SET_NETDEV_DEV_ID(), to provide a
standard way to set the value of this field.
Also also make use of this feature in the mlx4_en driver to set the port
number; port numbers are zero based.

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    1 +
 include/linux/netdevice.h    |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 6c2b15b..612df1e 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -978,6 +978,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	SET_NETDEV_DEV(dev, &mdev->dev->pdev->dev);
+	SET_NETDEV_DEV_ID(dev, port - 1);
 
 	/*
 	 * Initialize driver private data
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3857517..8d5f2c7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1080,6 +1080,11 @@ static inline void *netdev_priv(const struct net_device *dev)
  */
 #define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
 
+/*
+ * Set the port number of the physical device that this port net device uses
+ */
+#define SET_NETDEV_DEV_ID(net, devid)	((net)->dev_id = (devid))
+
 /**
  *	netif_napi_add - initialize a napi context
  *	@dev:  network device
-- 
1.7.1

