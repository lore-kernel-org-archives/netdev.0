From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 19/21] ntb_netdev: declare unused variables and fix missing initializer
Date: Sat, 19 Jan 2013 02:02:33 -0700
Message-ID: <1358586155-23322-20-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tag qp in ntb_netdev_tx_handler and net_device in ntb_get_settings as
unused function parameters.  Also, correct missing initializer errors
for 'struct device_driver' in ntb_netdev_client.  This corrects issues
found by 'EXTRA_CFLAGS=-W'.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/net/ntb_netdev.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 07c06cd..37173ce 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -125,8 +125,9 @@ static void ntb_netdev_rx_handler(struct ntb_transport_qp *qp, void *qp_data,
 	}
 }
 
-static void ntb_netdev_tx_handler(struct ntb_transport_qp *qp, void *qp_data,
-				  void *data, int len)
+static void
+ntb_netdev_tx_handler(__attribute__((unused)) struct ntb_transport_qp *qp,
+		      void *qp_data, void *data, int len)
 {
 	struct net_device *ndev = qp_data;
 	struct sk_buff *skb;
@@ -284,7 +285,8 @@ static void ntb_get_drvinfo(struct net_device *ndev,
 	strlcpy(info->bus_info, pci_name(dev->pdev), sizeof(info->bus_info));
 }
 
-static int ntb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int ntb_get_settings(__attribute__((unused)) struct net_device *dev,
+			    struct ethtool_cmd *cmd)
 {
 	cmd->supported = SUPPORTED_Backplane;
 	cmd->advertising = ADVERTISED_Backplane;
@@ -383,8 +385,10 @@ static void ntb_netdev_remove(struct pci_dev *pdev)
 }
 
 static struct ntb_client ntb_netdev_client = {
-	.driver.name = KBUILD_MODNAME,
-	.driver.owner = THIS_MODULE,
+	.driver = {
+		.name = KBUILD_MODNAME,
+		.owner = THIS_MODULE,
+	},
 	.probe = ntb_netdev_probe,
 	.remove = ntb_netdev_remove,
 };
-- 
1.7.9.5
