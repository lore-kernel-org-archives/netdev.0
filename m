From: Simon Xiao <sixiao@microsoft.com>
Subject: [PATCH V2 net-next] hv_netvsc: cleanup netdev feature flags for netvsc
Date: Thu,  4 Feb 2016 15:49:34 -0800
Message-ID: <1454629774-22257-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kys@microsoft.com, haiyangz@microsoft.com, devel@linuxdriverproject.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

1. Adding NETIF_F_TSO6 feature flag;
2. Adding NETIF_F_HW_CSUM. NETIF_F_IPV6_CSUM and NETIF_F_IP_CSUM are 
being deprecated;
3. Cleanup the coding style of flag assignment by using macro.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1d3a665..c72e5b8 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -43,6 +43,11 @@
 
 #define RING_SIZE_MIN 64
 #define LINKCHANGE_INT (2 * HZ)
+#define NETVSC_HW_FEATURES	(NETIF_F_RXCSUM | \
+				 NETIF_F_SG | \
+				 NETIF_F_TSO | \
+				 NETIF_F_TSO6 | \
+				 NETIF_F_HW_CSUM)
 static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
@@ -1081,10 +1086,8 @@ static int netvsc_probe(struct hv_device *dev,
 
 	net->netdev_ops = &device_ops;
 
-	net->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM |
-				NETIF_F_TSO;
-	net->features = NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM |
-			NETIF_F_IP_CSUM | NETIF_F_TSO;
+	net->hw_features = NETVSC_HW_FEATURES;
+	net->features = NETVSC_HW_FEATURES | NETIF_F_HW_VLAN_CTAG_TX;
 
 	net->ethtool_ops = &ethtool_ops;
 	SET_NETDEV_DEV(net, &dev->device);
-- 
2.5.0
