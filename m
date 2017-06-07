From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2 1/3] netvsc: fix rcu dereference warning from ethtool
Date: Wed,  7 Jun 2017 15:53:47 -0700
Message-ID: <20170607225349.28359-2-sthemmin@microsoft.com>
References: <20170607225349.28359-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170607225349.28359-1-sthemmin@microsoft.com>
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

The ethtool info command calls the netvsc get_sset_count with RTNL
but not with RCU. Which causes warning:

drivers/net/hyperv/netvsc_drv.c:1010 suspicious rcu_dereference_check() usage!

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4421a6d00375..d93e4da25fd2 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1028,7 +1028,7 @@ static const struct {
 static int netvsc_get_sset_count(struct net_device *dev, int string_set)
 {
 	struct net_device_context *ndc = netdev_priv(dev);
-	struct netvsc_device *nvdev = rcu_dereference(ndc->nvdev);
+	struct netvsc_device *nvdev = rtnl_dereference(ndc->nvdev);
 
 	if (!nvdev)
 		return -ENODEV;
-- 
2.11.0
