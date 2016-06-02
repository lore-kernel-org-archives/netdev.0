From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix VF register on vlan devices
Date: Thu,  2 Jun 2016 12:02:04 -0700
Message-ID: <1464894124-11450-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	vkuznets@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added a condition to avoid vlan devices with same MAC registering
as VF.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 6a69b5c..5ac1267 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1500,6 +1500,10 @@ static int netvsc_netdev_event(struct notifier_block *this,
 {
 	struct net_device *event_dev = netdev_notifier_info_to_dev(ptr);
 
+	/* Avoid Vlan dev with same MAC registering as VF */
+	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
+		return NOTIFY_DONE;
+
 	switch (event) {
 	case NETDEV_REGISTER:
 		return netvsc_register_vf(event_dev);
-- 
1.7.4.1
