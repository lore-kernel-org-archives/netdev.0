From: Avinash kumar <avi.kp.137@gmail.com>
Subject: [PATCH 2/2] drivers: net: vmxnet3 : vmxnet3_drv.c: removed checkaptch warning related to msleep()
Date: Sun, 22 Sep 2013 21:39:47 +0530
Message-ID: <1379866187-3158-1-git-send-email-avi.kp.137@gmail.com>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Avinash kumar <avi.kp.137@gmail.com>
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

replaced msleep(1) by usleep_range(1000,1500). Documentation/timers/timers_howto.txt
suggests use of usleep_range() in place of msleep() where desired delay is of range
1-20 ms.

Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7e2788c..34fd6b6 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2608,7 +2608,7 @@ vmxnet3_close(struct net_device *netdev)
 	 * completion.
 	 */
 	while (test_and_set_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 1500);
 
 	vmxnet3_quiesce_dev(adapter);
 
@@ -2656,7 +2656,7 @@ vmxnet3_change_mtu(struct net_device *netdev, int new_mtu)
 	 * completion.
 	 */
 	while (test_and_set_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 1500);
 
 	if (netif_running(netdev)) {
 		vmxnet3_quiesce_dev(adapter);
-- 
1.7.9.5
