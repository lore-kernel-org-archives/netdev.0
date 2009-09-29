From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 3/5] qlge: Fix spin_lock warning.
Date: Tue, 29 Sep 2009 11:39:23 -0700
Message-ID: <1254249565-16381-4-git-send-email-ron.mercer@qlogic.com>
References: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8737 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953AbZI2SpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 14:45:15 -0400
In-Reply-To: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unnecessary locking around the call to ql_adapter_reset().

Sep 25 08:17:29 localhost kernel:    SOFTIRQ-ON-W at:
Sep 25 08:17:29 localhost kernel:                         [<c0000000000a2964>] .lock_acquire+0x10c/0x158
Sep 25 08:17:29 localhost kernel:                         [<c0000000004542e0>] ._spin_lock+0x34/0x58
Sep 25 08:17:29 localhost kernel:                         [<d000000006723070>] .ql_adapter_down+0x40c/0x4a0 [qlge]
Sep 25 08:17:29 localhost kernel:                         [<d0000000067256d8>] .qlge_close+0x38/0x58 [qlge]
Sep 25 08:17:29 localhost kernel:                         [<c0000000003ada6c>] .dev_close+0xdc/0x118
Sep 25 08:17:29 localhost kernel:                         [<c0000000003adb48>] .rollback_registered+0xa0/0x158
Sep 25 08:17:29 localhost kernel:                         [<c0000000003adc50>] .unregister_netdevice+0x50/0x7c
Sep 25 08:17:29 localhost kernel:                         [<c0000000003adca0>] .unregister_netdev+0x24/0x40
Sep 25 08:17:29 localhost kernel:                         [<d00000000672e0c0>] .qlge_remove+0x28/0x64 [qlge]
Sep 25 08:17:29 localhost kernel:                         [<c000000000253fdc>] .pci_device_remove+0x50/0x90
Sep 25 08:17:29 localhost kernel:                         [<c0000000002f5434>] .__device_release_driver+0x94/0xf8
Sep 25 08:17:29 localhost kernel:                         [<c0000000002f5560>] .driver_detach+0xc8/0xfc
Sep 25 08:17:29 localhost kernel:                         [<c0000000002f3fd8>] .bus_remove_driver+0xb4/0x114
Sep 25 08:17:29 localhost kernel:                         [<c0000000002f5d4c>] .driver_unregister+0x80/0xa4
Sep 25 08:17:29 localhost kernel:                         [<c00000000025421c>] .pci_unregister_driver+0x50/0xc8
Sep 25 08:17:29 localhost kernel:                         [<d00000000672e044>] .qlge_exit+0x1c/0x34 [qlge]
Sep 25 08:17:29 localhost kernel:                         [<c0000000000ac8b0>] .SyS_delete_module+0x234/0x2d0
Sep 25 08:17:29 localhost kernel:                         [<c000000000008554>] syscall_exit+0x0/0x40
Sep 25 08:17:29 localhost kernel:    INITIAL USE at:

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e4b756d..b05300d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3380,12 +3380,10 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	ql_free_rx_buffers(qdev);
 
-	spin_lock(&qdev->hw_lock);
 	status = ql_adapter_reset(qdev);
 	if (status)
 		QPRINTK(qdev, IFDOWN, ERR, "reset(func #%d) FAILED!\n",
 			qdev->func);
-	spin_unlock(&qdev->hw_lock);
 	return status;
 }
 
-- 
1.6.0.2

