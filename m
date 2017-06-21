From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 1/2] ldmvsw: add vio version and remote-mac to ethtool info
Date: Wed, 21 Jun 2017 09:09:53 -0700
Message-ID: <1498061394-233018-2-git-send-email-shannon.nelson@oracle.com>
References: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the ethtool -i output print the vio version and the remote-mac
of the ldom that the vif device is serving as this vif info is
not exposed elsewhere.  The remote-mac address is most useful for
tracking which client ldom is being served by the vif.

Orabug: 26316362

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/ldmvsw.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 8603e39..de512ef 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -62,8 +62,15 @@
 static void vsw_get_drvinfo(struct net_device *dev,
 			    struct ethtool_drvinfo *info)
 {
+	struct vnet_port *port = netdev_priv(dev);
+
 	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
+
+	snprintf(info->fw_version, sizeof(info->fw_version),
+		 "vio %d.%d", port->vio.ver.major, port->vio.ver.minor);
+	snprintf(info->bus_info, sizeof(info->bus_info),
+		 "remote-mac %pM", port->raddr);
 }
 
 static u32 vsw_get_msglevel(struct net_device *dev)
-- 
1.7.1

