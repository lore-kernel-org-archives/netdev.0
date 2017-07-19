From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/8] netvsc: force link update after MTU change
Date: Wed, 19 Jul 2017 11:53:12 -0700
Message-ID: <20170719185319.25871-2-sthemmin@microsoft.com>
References: <20170719185319.25871-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170719185319.25871-1-sthemmin@microsoft.com>
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

If two MTU changes are in less than update interval (2 seconds),
then the netvsc network device may get stuck with no carrier.

The netvsc driver debounces link status events which is fine
for unsolicited updates, but blocks getting the update after
down/up from MTU reinitialization.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 63c98bbbc596..09b07ca9e69a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -783,6 +783,7 @@ static int netvsc_set_channels(struct net_device *net,
 		ret = netvsc_open(net);
 
 	/* We may have missed link change notifications */
+	net_device_ctx->last_reconfig = 0;
 	schedule_delayed_work(&net_device_ctx->dwork, 0);
 
 	return ret;
-- 
2.11.0
