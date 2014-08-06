From: Martin Fuzzey <mfuzzey@parkeon.com>
Subject: [Regression] FEC: Panic on suspend in 3.16
Date: Wed, 06 Aug 2014 16:52:55 +0200
Message-ID: <53E24147.4050304@parkeon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:44281 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaHFOw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 10:52:58 -0400
Received: by mail-wi0-f169.google.com with SMTP id n3so9651532wiv.4
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 07:52:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am using the fec ethernet driver on a i.MX53 SoC.

All was working fine on 3.13 but, after upgrading to 3.16 I now get a 
panic on suspend:

# echo mem > /sys/power/state
[   24.429549] PM: Syncing filesystems ... done.
[   24.439586] (NULL device *): Direct firmware load failed with error -2
[   24.446157] (NULL device *): Falling back to user helper
[   24.451574] (NULL device *): Direct firmware load failed with error -2
[   24.458121] (NULL device *): Falling back to user helper
[   24.517968] Freezing user space processes ... (elapsed 0.001 seconds) 
done.
[   24.526274] Freezing remaining freezable tasks ... (elapsed 0.001 
seconds) done.
[   24.579436] @MF@ fec_suspend: dev=dc421048 (63fec000.etherne) ndev=  
(null)
[   24.586429] Unable to handle kernel NULL pointer dereference at 
virtual address 0000002c
[   24.594553] pgd = dd324000
[   24.597261] [0000002c] *pgd=00000000
[   24.600867] Internal error: Oops: 5 [#1] ARM
[   24.605137] Modules linked in:
[   24.608208] CPU: 0 PID: 91 Comm: sh Not tainted 
3.16.0-pknbsp-svn1549-atag-v3.16-101-gabdac82-dirty #426
[   24.617691] task: dd1e2400 ti: dd22c000 task.ti: dd22c000
[   24.623106] PC is at fec_suspend+0x2c/0x90
[   24.627203] LR is at fec_suspend+0x2c/0x90
[   24.631301] pc : [<c0370564>]    lr : [<c0370564>] psr: 60070013
[   24.631301] sp : dd22de18  ip : 00000001  fp : c08521bc
[   24.642778] r10: c0840e1c  r9 : 00000000  r8 : c0370538
[   24.648002] r7 : dc421048  r6 : c08d33cc  r5 : 00000000  r4 : 00000000
[   24.654529] r3 : 00000000  r2 : c0840f84  r1 : 00000000  r0 : 0000003f
[   24.661058] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM 
Segment user
[   24.668193] Control: 10c5387d  Table: 8d324019  DAC: 00000015
[   24.673938] Process sh (pid: 91, stack limit = 0xdd22c238)
[   24.679423] Stack: (0xdd22de18 to 0xdd22e000)
[   24.683781] 
de00:                                                       00000000 
00000000
[   24.691961] de20: 00000000 c02da7e0 00000000 c08d33cc 00000000 
00000000 dc421048 00000000
[   24.700141] de40: c08d33cc 00000002 dc42107c c02db6ec c08521bc 
008521bc dc4210ac dc421048
[   24.708320] de60: c08521bc c08d33cc c08521f4 c02dc964 c08521bc 
00000002 b263440a 00000005
[   24.716500] de80: b263440a 00000005 00000003 c0883430 00000003 
c0872e48 dd846400 c0840f44
[   24.724680] dea0: 00000004 c0705838 00000000 c0047a34 00000000 
c05c3bdc c076781c dd22ded4
[   24.732859] dec0: 00000003 dd22ded4 dd846400 00000000 00000003 
c0872e48 dd846400 c0840f44
[   24.741038] dee0: c0705838 c0047f84 c0840f3c 00000003 00000003 
c0046c0c dc04c2d0 dd846400
[   24.749218] df00: 00000004 dd22df80 dd846400 dd84648c dd846480 
c0241e04 00000004 c0101848
[   24.757398] df20: c0101804 00000000 00000000 c0100f10 00000000 
00000000 dd7570c0 00000004
[   24.765579] df40: b741ea8c dd22df80 00000004 dd22c000 b741ea8c 
c00acf70 00000000 c00c4310
[   24.773759] df60: 00060003 00000000 00000000 dd7570c0 dd7570c0 
00000004 b741ea8c c00ad380
[   24.781938] df80: 00000000 00000000 dd7570c0 b741ea8c 00000004 
00000001 00000004 c000f044
[   24.790117] dfa0: 00000000 c000eec0 b741ea8c 00000004 00000001 
b741ea8c 00000004 ffffffff
[   24.798298] dfc0: b741ea8c 00000004 00000001 00000004 be917930 
b741d550 00000000 00000000
[   24.806479] dfe0: b6ff0f40 be917908 b6fd4ed3 b6f3f408 60030010 
00000001 00280004 e4518008
[   24.814677] [<c0370564>] (fec_suspend) from [<c02da7e0>] 
(dpm_run_callback+0x44/0x7c)
[   24.822514] [<c02da7e0>] (dpm_run_callback) from [<c02db6ec>] 
(__device_suspend+0x128/0x388)
[   24.830958] [<c02db6ec>] (__device_suspend) from [<c02dc964>] 
(dpm_suspend+0x58/0x214)
[   24.838889] [<c02dc964>] (dpm_suspend) from [<c0047a34>] 
(suspend_devices_and_enter+0x98/0x3b8)
[   24.847596] [<c0047a34>] (suspend_devices_and_enter) from 
[<c0047f84>] (pm_suspend+0x230/0x2dc)
[   24.856299] [<c0047f84>] (pm_suspend) from [<c0046c0c>] 
(state_store+0x70/0xd4)
[   24.863623] [<c0046c0c>] (state_store) from [<c0241e04>] 
(kobj_attr_store+0x14/0x20)
[   24.871379] [<c0241e04>] (kobj_attr_store) from [<c0101848>] 
(sysfs_kf_write+0x44/0x48)
[   24.879392] [<c0101848>] (sysfs_kf_write) from [<c0100f10>] 
(kernfs_fop_write+0xd0/0x180)
[   24.887576] [<c0100f10>] (kernfs_fop_write) from [<c00acf70>] 
(vfs_write+0xa4/0x1ac)
[   24.895324] [<c00acf70>] (vfs_write) from [<c00ad380>] 
(SyS_write+0x40/0x8c)
[   24.902385] [<c00ad380>] (SyS_write) from [<c000eec0>] 
(ret_fast_syscall+0x0/0x30)
[   24.909959] Code: 05903008 e58d4000 e59f0060 eb094d90 (e594302c)
[   24.916110] ---[ end trace cce4e72dfc39eadf ]---
[   24.920755] Kernel panic - not syncing: Fatal exception
[   24.925983] drm_kms_helper: panic occurred, switching back to text 
console
[   24.932892] ---[ end Kernel panic - not syncing: Fatal exception


The problem is that in
static int
fec_suspend(struct device *dev)
{
     struct net_device *ndev = dev_get_drvdata(dev);
     struct fec_enet_private *fep = netdev_priv(ndev);


ndev is NULL


Adding the following hack patch:

diff --git a/drivers/net/ethernet/freescale/fec_main.c 
b/drivers/net/ethernet/freescale/fec_main.c
index 77037fd..64edfa8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2486,6 +2486,9 @@ fec_probe(struct platform_device *pdev)
         const struct of_device_id *of_id;
         static int dev_id;

+       printk(KERN_INFO "@MF@ %s probing dev=%p (%s)\n", __func__,
+               &pdev->dev, dev_name(&pdev->dev));
+
         of_id = of_match_device(fec_dt_ids, &pdev->dev);
         if (of_id)
                 pdev->id_entry = of_id->data;
@@ -2616,6 +2619,9 @@ fec_probe(struct platform_device *pdev)
                 netdev_info(ndev, "registered PHC device %d\n", 
fep->dev_id);

         INIT_DELAYED_WORK(&(fep->delay_work.delay_work), fec_enet_work);
+
+       printk(KERN_INFO "@MF@ %s probed dev=%p (%s)\n", __func__,
+               &pdev->dev, dev_name(&pdev->dev));
         return 0;

  failed_register:
@@ -2661,6 +2667,12 @@ fec_suspend(struct device *dev)
         struct net_device *ndev = dev_get_drvdata(dev);
         struct fec_enet_private *fep = netdev_priv(ndev);

+       printk(KERN_INFO "@MF@ %s: dev=%p (%s) ndev=%p\n", __func__, 
dev, dev_name(dev), ndev);
+       if (!ndev) {
+               printk(KERN_INFO "@MF@ ignoring null\n");
+               return 0;
+       }
+
         if (netif_running(ndev)) {
                 fec_stop(ndev);
                 netif_device_detach(ndev);
@@ -2681,6 +2693,12 @@ fec_resume(struct device *dev)
         struct fec_enet_private *fep = netdev_priv(ndev);
         int ret;

+       printk(KERN_INFO "@MF@ %s: dev=%p (%s) ndev=%p\n", __func__, 
dev, dev_name(dev), ndev);
+       if (!ndev) {
+               printk(KERN_INFO "@MF@ ignoring null\n");
+               return 0;
+       }
+
         if (fep->reg_phy) {
                 ret = regulator_enable(fep->reg_phy);
                 if (ret)


Gives these logs:
# dmesg | grep MF
<6>[    1.025267] @MF@ fec_probe probing dev=dc0cfa10 (63fec000.ethernet)
<6>[    1.057471] @MF@ fec_probe probed dev=dc0cfa10 (63fec000.ethernet)
# echo mem > /sys/power/state

[   33.329502] PM: Syncing filesystems ... done.
[   33.357146] (NULL device *): Direct firmware load failed with error -2
[   33.363769] (NULL device *): Falling back to user helper
[   33.369260] (NULL device *): Direct firmware load failed with error -2
[   33.375792] (NULL device *): Falling back to user helper
[   33.461774] Freezing user space processes ... (elapsed 0.001 seconds) 
done.
[   33.470200] Freezing remaining freezable tasks ... (elapsed 0.001 
seconds) done.
[   33.519954] @MF@ fec_suspend: dev=dc421048 (63fec000.etherne) ndev=  
(null)
[   33.526931] @MF@ ignoring null  <==== Would have panicked here
[   33.533289] @MF@ fec_suspend: dev=dc0cfa10 (63fec000.ethernet) 
ndev=dc02c000
[   33.542266] PM: suspend of devices complete after 61.683 msecs
[   33.548114] PM: suspend devices took 0.070 seconds
[   33.554874] PM: late suspend of devices complete after 1.918 msecs
[   33.563101] PM: noirq suspend of devices complete after 1.971 msecs


So we see that the driver is only being probed once (with name 
63fec000.ethernet)
But that the suspend callback is being called twice, for 
"63fec000.etherne" and "63fec000.ethernet"
The first of which has no driver data, hence the panic.

The same patch on 3.13 gives:
6>[    0.998656] @MF@ fec_probe probing dev=dc10b410 (63fec000.ethernet)
<6>[    1.032098] @MF@ fec_probe probed dev=dc10b410 (63fec000.ethernet)
# echo mem > /sys/power/state
[   52.854713] PM: Syncing filesystems ... done.
[   52.897069] (NULL device *): Direct firmware load failed with error -2
[   52.903895] (NULL device *): Falling back to user helper
[   52.910300] (NULL device *): Direct firmware load failed with error -2
[   52.916914] (NULL device *): Falling back to user helper
[   53.065496] Freezing user space processes ... (elapsed 0.024 seconds) 
done.
[   53.097279] Freezing remaining freezable tasks ... (elapsed 0.001 
seconds) done.
[   53.157807] @MF@ fec_suspend: dev=dc10b410 (63fec000.ethernet) 
ndev=dc1e7800
[   53.173097] PM: suspend of devices complete after 65.114 msecs
[   53.178964] PM: suspend devices took 0.070 seconds
[   53.185287] PM: late suspend of devices complete after 1.513 msecs
[   53.192888] PM: noirq suspend of devices complete after 1.404 msecs

No second device here.

Anyone else seeing this?

Any ideas?

Unfortunately I have local patches that will make bisect difficult.

Regards,

Martin
