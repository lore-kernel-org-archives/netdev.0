From: Colin King <colin.king@canonical.com>
Subject: [PATCH] netvsc: fix unititialized return value in variable ret
Date: Sat, 25 Mar 2017 14:16:53 +0000
Message-ID: <20170325141653.11238-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "K . Y . Srinivasan" <kys@microsoft.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, devel@linuxdriverproject.org,
 netdev@vger.kernel.org
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

From: Colin Ian King <colin.king@canonical.com>

It is possible for an uninitialized value of ret to be returned
so fix this by initializing ret to zero.

Detected by CoverityScan, CID#1420762 ("Uninitialized scalar variable")

Fixes: 163891d7d429 ("netvsc: handle offline mtu and channel change")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index eb7ae79d47bb..f830bbbd8ad4 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -855,7 +855,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	struct hv_device *hdev = ndevctx->device_ctx;
 	struct netvsc_device_info device_info;
 	bool was_running;
-	int ret;
+	int ret = 0;
 
 	if (!nvdev || nvdev->destroy)
 		return -ENODEV;
-- 
2.11.0
