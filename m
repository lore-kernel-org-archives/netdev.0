From: Tejun Heo <tj@kernel.org>
Subject: [PATCH net-next-2.6] vxge: add missing flush of reset_task
Date: Wed, 15 Dec 2010 15:03:29 +0100
Message-ID: <4D08CAB1.6040402@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, jon.mason@exar.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 6e07ebd84 (drivers/net: remove unnecessary
flush_scheduled_work() calls) incorrectly removed the flush call
without replacing it with the appropriate work specific operation.
Fix it by flushing vdev->reset_task explicitly.

Pointed out by Jon Mason.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jon Mason <jon.mason@exar.com>
---
 drivers/net/vxge/vxge-main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 537ad87..1ac9b56 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3439,6 +3439,8 @@ static void vxge_device_unregister(struct __vxge_hw_device *hldev)

 	strncpy(buf, dev->name, IFNAMSIZ);

+	flush_work_sync(&vdev->reset_task);
+
 	/* in 2.6 will call stop() if device is up */
 	unregister_netdev(dev);
