From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: remove cpsw_ale_stop from cpsw_ale_destroy
Date: Wed, 5 Nov 2014 18:33:31 +0530
Message-ID: <1415192611-22722-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:40269 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035AbaKENDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 08:03:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when cpsw is build as modulea and simple insert and removal of module
creates a deadlock, due to delete timer. the timer is created and destroyed
in cpsw_ale_start and cpsw_ale_stop which are from device open and close.

root@am437x-evm:~# modprobe -r ti_cpsw
[  158.505333] INFO: trying to register non-static key.
[  158.510623] the code is fine but needs lockdep annotation.
[  158.516448] turning off the locking correctness validator.
[  158.522282] CPU: 0 PID: 1339 Comm: modprobe Not tainted 3.14.23-00445-gd41c88f #44
[  158.530359] [<c0015380>] (unwind_backtrace) from [<c0012088>] (show_stack+0x10/0x14)
[  158.538603] [<c0012088>] (show_stack) from [<c054ad70>] (dump_stack+0x78/0x94)
[  158.546295] [<c054ad70>] (dump_stack) from [<c0088008>] (__lock_acquire+0x176c/0x1b74)
[  158.554711] [<c0088008>] (__lock_acquire) from [<c0088944>] (lock_acquire+0x9c/0x104)
[  158.563043] [<c0088944>] (lock_acquire) from [<c004e520>] (del_timer_sync+0x44/0xd8)
[  158.571289] [<c004e520>] (del_timer_sync) from [<bf2eac1c>] (cpsw_ale_destroy+0x10/0x3c [ti_cpsw])
[  158.580821] [<bf2eac1c>] (cpsw_ale_destroy [ti_cpsw]) from [<bf2eb268>] (cpsw_remove+0x30/0xa0 [ti_cpsw])
[  158.591000] [<bf2eb268>] (cpsw_remove [ti_cpsw]) from [<c035ef44>] (platform_drv_remove+0x18/0x1c)
[  158.600527] [<c035ef44>] (platform_drv_remove) from [<c035d8bc>] (__device_release_driver+0x70/0xc8)
[  158.610236] [<c035d8bc>] (__device_release_driver) from [<c035e0d4>] (driver_detach+0xb4/0xb8)
[  158.619386] [<c035e0d4>] (driver_detach) from [<c035d6e4>] (bus_remove_driver+0x4c/0x90)
[  158.627988] [<c035d6e4>] (bus_remove_driver) from [<c00af2a8>] (SyS_delete_module+0x10c/0x198)
[  158.637144] [<c00af2a8>] (SyS_delete_module) from [<c000e580>] (ret_fast_syscall+0x0/0x48)
[  179.524727] INFO: rcu_sched detected stalls on CPUs/tasks: {} (detected by 0, t=2102 jiffies, g=1487, c=1486, q=6)
[  179.535741] INFO: Stall ended before state dump start

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw_ale.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 3ae8387..097ebe7 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -785,7 +785,6 @@ int cpsw_ale_destroy(struct cpsw_ale *ale)
 {
 	if (!ale)
 		return -EINVAL;
-	cpsw_ale_stop(ale);
 	cpsw_ale_control_set(ale, 0, ALE_ENABLE, 0);
 	kfree(ale);
 	return 0;
-- 
2.1.2.484.g13da0fc
