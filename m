From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v3 1/7] netvsc: fix return value for set_channels
Date: Fri, 28 Jul 2017 08:59:41 -0700
Message-ID: <20170728155947.10062-2-sthemmin@microsoft.com>
References: <20170728155947.10062-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170728155947.10062-1-sthemmin@microsoft.com>
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

The error and normal case got swapped.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 262486ce8e2a..f1eaf675d2e9 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -758,8 +758,8 @@ static int netvsc_set_channels(struct net_device *net,
 	if (!IS_ERR(nvdev)) {
 		netif_set_real_num_tx_queues(net, nvdev->num_chn);
 		netif_set_real_num_rx_queues(net, nvdev->num_chn);
-		ret = PTR_ERR(nvdev);
 	} else {
+		ret = PTR_ERR(nvdev);
 		device_info.num_chn = orig;
 		rndis_filter_device_add(dev, &device_info);
 	}
-- 
2.11.0
