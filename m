From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] hyperv: NULL dereference on error
Date: Thu, 4 Sep 2014 14:11:23 +0300
Message-ID: <20140904111123.GD21504@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, kernel-janitors@vger.kernel.org,
 netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
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

We try to call free_netvsc_device(net_device) when "net_device" is NULL.
It leads to an Oops.

Fixes: f90251c8a6d0 ('hyperv: Increase the buffer length for netvsc_channel_cb()')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 5b5644a..977984b 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1054,10 +1054,8 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	struct net_device *ndev;
 
 	net_device = alloc_net_device(device);
-	if (!net_device) {
-		ret = -ENOMEM;
-		goto cleanup;
-	}
+	if (!net_device)
+		return -ENOMEM;
 
 	net_device->ring_size = ring_size;
