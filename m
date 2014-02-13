From: Heiko Schocher <hs@denx.de>
Subject: [PATCH] drivers: net: cpsw: fix buggy loop condition
Date: Thu, 13 Feb 2014 14:47:27 +0100
Message-ID: <1392299247-16917-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs@denx.de>, Mugunthan V N <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Siewior <bigeasy@linutronix.de>,
	Daniel Mack <zonque@gmail.com>, Felipe Balbi <balbi@ti.com>,
	Markus Pargmann <mpa@pengutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit:
>From 0cd8f9cc0654c06adde353c6532114c5f53a18e8 Mon Sep 17 00:00:00 2001
From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 23 Jan 2014 00:03:12 +0530
Subject: [PATCH] drivers: net: cpsw: enable promiscuous mode support

Enable promiscuous mode support for CPSW.

Introduced a crash on an am335x based board (similiar to am335x-evm).
Reason is buggy end condition in for loop in cpsw_set_promiscious()

for (i = 0; i <= priv->data.slaves; i++)

should be

for (i = 0; i < priv->data.slaves; i++)

Fix this ...

Signed-off-by: Heiko Schocher <hs@denx.de>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Sebastian Siewior <bigeasy@linutronix.de>
Cc: Daniel Mack <zonque@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Cc: Markus Pargmann <mpa@pengutronix.de>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

---
complete crash dump
[    4.986544] Unable to handle kernel NULL pointer dereference at virtual address 00000120
[    4.995056] pgd = c0004000
[    4.997906] [00000120] *pgd=00000000
[    5.001723] Internal error: Oops: 5 [#1] SMP ARM
[    5.006560] Modules linked in:
[    5.009773] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc1-01621-ga10cd7e-dirty #9
[    5.018243] task: c607b540 ti: c607c000 task.ti: c607c000
[    5.023914] PC is at cpsw_set_promiscious+0x1d8/0x2a4
[    5.029204] LR is at cpsw_set_promiscious+0x1c0/0x2a4
[    5.034494] pc : [<c0407c18>]    lr : [<c0407c00>]    psr: 60000113
[    5.034494] sp : c607dd88  ip : c0984ab8  fp : c085c7cc
[    5.046506] r10: 00000024  r9 : c64b31d8  r8 : 00000003
[    5.051974] r7 : 00000000  r6 : c64ad800  r5 : c64b3080  r4 : 00000000
[    5.058806] r3 : 00000003  r2 : c64b3190  r1 : 00000002  r0 : 00000000
[    5.065641] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[    5.073291] Control: 10c5387d  Table: 80004019  DAC: 00000017
[    5.079303] Process swapper/0 (pid: 1, stack limit = 0xc607c248)
[    5.085592] Stack: (0xc607dd88 to 0xc607e000)
[    5.090158] dd80:                   c64ad800 c05ff710 00000000 00000000 00000000 00001002
[    5.098722] dda0: 0000016b c0409c44 00000000 00000000 c64ad800 c05ff710 00000000 00000000
[    5.107287] ddc0: 00000000 00001002 0000016b c04cd8cc c64ad964 c64ad800 c64ad82c c04cd920
[    5.115850] dde0: 00001003 c64ad800 c05ff710 c04cd9f0 00000000 c64ad800 00001002 c64ad800
[    5.124414] de00: 00001003 00000001 00001002 c04cdc58 c64ad800 00000128 00001002 c08fe840
[    5.132979] de20: 00000000 c04cdd58 c64ad800 00000003 c085c7e0 c08fe840 c085c7cc c0847ce8
[    5.141543] de40: 00000000 c058fbf4 c607b540 c5b17cd0 c5b131c8 00000000 12400000 c02a1558
[    5.150105] de60: c5b17d0c 00000000 00000002 00000000 00000000 00000000 00000002 00000000
[    5.158669] de80: c05185b4 c00873ac 00000002 00000000 00000000 c05185b4 00000000 c607c030
[    5.167233] dea0: c607c008 60000113 c08f79c0 c0901610 00000007 c090bdc0 c090bdc0 c08459c8
[    5.175798] dec0: c0901610 00000007 c090bdc0 c08615ac 00000007 c090bdc0 c090bdc0 c0847b58
[    5.184362] dee0: 000000bd c607c030 00000000 c0008918 00000004 c08bfa30 c08bfa30 60000113
[    5.192926] df00: c0089d00 00000000 c08bfa2c 00000000 00000000 c0590db0 00000002 c607c000
[    5.201489] df20: c7eff36d c05dd514 000000bd c005df1c c07d1ed4 00000007 c7eff419 00000007
[    5.210054] df40: 60000113 c08615ac 00000007 c090bdc0 c090bdc0 c080450c 000000bd c084d950
[    5.218620] df60: c084d948 c0804c1c 00000007 00000007 c080450c dfdedeff fcdfffff c7dd9ec0
[    5.227183] df80: c607c018 00000000 c058668c 00000000 00000000 00000000 00000000 00000000
[    5.235747] dfa0: 00000000 c0586694 00000000 c000e548 00000000 00000000 00000000 00000000
[    5.244310] dfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    5.252873] dfe0: 00000000 00000000 00000000 00000000 00000013 00000000 fffff6f7 7ffeefbf
[    5.261448] [<c0407c18>] (cpsw_set_promiscious) from [<c0409c44>] (cpsw_ndo_set_rx_mode+0x20/0xf8)
[    5.270841] [<c0409c44>] (cpsw_ndo_set_rx_mode) from [<c04cd8cc>] (__dev_set_rx_mode+0x5c/0x94)
[    5.279952] [<c04cd8cc>] (__dev_set_rx_mode) from [<c04cd920>] (dev_set_rx_mode+0x1c/0x28)
[    5.288609] [<c04cd920>] (dev_set_rx_mode) from [<c04cd9f0>] (__dev_open+0xc4/0x110)
[    5.296720] [<c04cd9f0>] (__dev_open) from [<c04cdc58>] (__dev_change_flags+0x88/0x170)
[    5.305102] [<c04cdc58>] (__dev_change_flags) from [<c04cdd58>] (dev_change_flags+0x18/0x48)
[    5.313945] [<c04cdd58>] (dev_change_flags) from [<c0847ce8>] (ip_auto_config+0x190/0x110c)
[    5.322697] [<c0847ce8>] (ip_auto_config) from [<c0008918>] (do_one_initcall+0xe8/0x148)
[    5.331190] [<c0008918>] (do_one_initcall) from [<c0804c1c>] (kernel_init_freeable+0x104/0x1c8)
[    5.340316] [<c0804c1c>] (kernel_init_freeable) from [<c0586694>] (kernel_init+0x8/0x118)
[    5.348890] [<c0586694>] (kernel_init) from [<c000e548>] (ret_from_fork+0x14/0x2c)
[    5.356821] Code: e0829009 e2888001 e5990018 e1a03008 (e5900120)
[    5.363291] ---[ end trace ba29586f1d312ca3 ]---
[    5.369343] Kernel panic - not syncing: Fatal exception in interrupt
[    5.376005] drm_kms_helper: panic occurred, switching back to text console
---
 drivers/net/ethernet/ti/cpsw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index bde63e3..34b4262 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -554,7 +554,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 		 * common for both the interface as the interface shares
 		 * the same hardware resource.
 		 */
-		for (i = 0; i <= priv->data.slaves; i++)
+		for (i = 0; i < priv->data.slaves; i++)
 			if (priv->slaves[i].ndev->flags & IFF_PROMISC)
 				flag = true;
 
@@ -578,7 +578,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			unsigned long timeout = jiffies + HZ;
 
 			/* Disable Learn for all ports */
-			for (i = 0; i <= priv->data.slaves; i++) {
+			for (i = 0; i < priv->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 1);
 				cpsw_ale_control_set(ale, i,
@@ -606,7 +606,7 @@ static void cpsw_set_promiscious(struct net_device *ndev, bool enable)
 			cpsw_ale_control_set(ale, 0, ALE_P0_UNI_FLOOD, 0);
 
 			/* Enable Learn for all ports */
-			for (i = 0; i <= priv->data.slaves; i++) {
+			for (i = 0; i < priv->data.slaves; i++) {
 				cpsw_ale_control_set(ale, i,
 						     ALE_PORT_NOLEARN, 0);
 				cpsw_ale_control_set(ale, i,
-- 
1.8.3.1
