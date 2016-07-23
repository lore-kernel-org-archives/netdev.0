From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix VF register on bonding devices
Date: Fri, 22 Jul 2016 18:14:50 -0700
Message-ID: <1469236490-27704-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de
To: davem@davemloft.net,
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

From: Haiyang Zhang <haiyangz@microsoft.com>

Added a condition to avoid bonding devices with same MAC registering
as VF.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 787a202..41bd952 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1494,8 +1494,8 @@ static int netvsc_netdev_event(struct notifier_block *this,
 {
 	struct net_device *event_dev = netdev_notifier_info_to_dev(ptr);
 
-	/* Avoid Vlan dev with same MAC registering as VF */
-	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
+	/* Avoid Vlan, Bonding dev with same MAC registering as VF */
+	if (event_dev->priv_flags & (IFF_802_1Q_VLAN | IFF_BONDING))
 		return NOTIFY_DONE;
 
 	switch (event) {
-- 
1.7.4.1
