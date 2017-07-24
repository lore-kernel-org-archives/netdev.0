From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/6] netvsc: remove no longer used max_num_rss queues
Date: Mon, 24 Jul 2017 10:57:30 -0700
Message-ID: <20170724175730.31806-7-sthemmin@microsoft.com>
References: <20170724175730.31806-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170724175730.31806-1-sthemmin@microsoft.com>
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

This value has been calculated in rndis_device_attach since 4.11.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h | 1 -
 drivers/net/hyperv/netvsc_drv.c | 2 --
 2 files changed, 3 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index afb65f753574..4e7ff348327e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -147,7 +147,6 @@ struct hv_netvsc_packet {
 struct netvsc_device_info {
 	unsigned char mac_adr[ETH_ALEN];
 	int  ring_size;
-	u32  max_num_vrss_chns;
 	u32  num_chn;
 };
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b2b0a1f96940..8136dd2d927f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -754,7 +754,6 @@ static int netvsc_set_channels(struct net_device *net,
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.num_chn = count;
 	device_info.ring_size = ring_size;
-	device_info.max_num_vrss_chns = count;
 
 	nvdev = rndis_filter_device_add(dev, &device_info);
 	if (!IS_ERR(nvdev)) {
@@ -763,7 +762,6 @@ static int netvsc_set_channels(struct net_device *net,
 		ret = PTR_ERR(nvdev);
 	} else {
 		device_info.num_chn = orig;
-		device_info.max_num_vrss_chns = count;
 		rndis_filter_device_add(dev, &device_info);
 	}
 
-- 
2.11.0
