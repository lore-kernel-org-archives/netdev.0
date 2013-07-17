From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net] hyperv: Fix the NETIF_F_SG flag setting in netvsc
Date: Tue, 16 Jul 2013 23:01:20 -0700
Message-ID: <1374040880-20468-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

SG mode is not currently supported by netvsc, so remove this flag for now.
Otherwise, it will be unconditionally enabled by commit ec5f0615642
    "Kill link between CSUM and SG features"
Previously, the SG feature is disabled because CSUM is not set here.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4dccead..23a0fff 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -431,8 +431,8 @@ static int netvsc_probe(struct hv_device *dev,
 	net->netdev_ops = &device_ops;
 
 	/* TODO: Add GSO and Checksum offload */
-	net->hw_features = NETIF_F_SG;
-	net->features = NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_TX;
+	net->hw_features = 0;
+	net->features = NETIF_F_HW_VLAN_CTAG_TX;
 
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, &dev->device);
-- 
1.7.4.1
