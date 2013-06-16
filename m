From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/9] PTR_RET is now PTR_ERR_OR_ZERO(): Replace most.
Date: Sun, 16 Jun 2013 14:12:41 +0930
Message-ID: <1371357768-4968-2-git-send-email-rusty@rustcorp.com.au>
References: <87ehc2rczo.fsf@rustcorp.com.au>
 <1371357768-4968-1-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
 Julia Lawall <julia.lawall@lip6.fr>
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1371357768-4968-1-git-send-email-rusty@rustcorp.com.au>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Sweep of the simple cases.

Cc: netdev@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 arch/arm/mach-omap2/i2c.c                         |  2 +-
 arch/m68k/amiga/platform.c                        |  2 +-
 arch/m68k/kernel/time.c                           |  2 +-
 arch/m68k/q40/config.c                            |  2 +-
 arch/powerpc/kernel/iommu.c                       |  2 +-
 arch/powerpc/kernel/time.c                        |  2 +-
 arch/powerpc/platforms/ps3/time.c                 |  2 +-
 arch/powerpc/sysdev/rtc_cmos_setup.c              |  2 +-
 arch/s390/hypfs/hypfs_dbfs.c                      |  2 +-
 drivers/char/tile-srom.c                          |  2 +-
 drivers/infiniband/core/cma.c                     |  2 +-
 drivers/net/appletalk/cops.c                      |  2 +-
 drivers/net/appletalk/ltpc.c                      |  2 +-
 drivers/net/ethernet/amd/atarilance.c             |  2 +-
 drivers/net/ethernet/amd/mvme147.c                |  2 +-
 drivers/net/ethernet/amd/ni65.c                   |  2 +-
 drivers/net/ethernet/amd/sun3lance.c              |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c |  2 +-
 drivers/net/wireless/brcm80211/brcmsmac/debug.c   |  2 +-
 drivers/platform/x86/samsung-q10.c                |  2 +-
 drivers/regulator/fan53555.c                      |  2 +-
 drivers/spi/spi-fsl-spi.c                         |  2 +-
 drivers/spi/spidev.c                              |  2 +-
 drivers/video/omap2/dss/core.c                    |  2 +-
 fs/btrfs/dev-replace.c                            |  2 +-
 fs/btrfs/inode.c                                  |  2 +-
 net/bluetooth/hci_sysfs.c                         |  2 +-
 net/bridge/netfilter/ebtable_broute.c             |  2 +-
 net/bridge/netfilter/ebtable_filter.c             |  2 +-
 net/bridge/netfilter/ebtable_nat.c                |  2 +-
 net/ipv4/netfilter/arptable_filter.c              |  2 +-
 net/ipv4/netfilter/iptable_filter.c               |  2 +-
 net/ipv4/netfilter/iptable_mangle.c               |  2 +-
 net/ipv4/netfilter/iptable_nat.c                  |  2 +-
 net/ipv4/netfilter/iptable_raw.c                  |  2 +-
 net/ipv4/netfilter/iptable_security.c             |  2 +-
 net/ipv6/netfilter/ip6table_filter.c              |  2 +-
 net/ipv6/netfilter/ip6table_mangle.c              |  2 +-
 net/ipv6/netfilter/ip6table_nat.c                 |  2 +-
 net/ipv6/netfilter/ip6table_raw.c                 |  2 +-
 net/ipv6/netfilter/ip6table_security.c            |  2 +-
 scripts/coccinelle/api/ptr_ret.cocci              | 10 +++++-----
 sound/soc/soc-io.c                                |  2 +-
 43 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/arch/arm/mach-omap2/i2c.c b/arch/arm/mach-omap2/i2c.c
index d940e53..b456b44 100644
--- a/arch/arm/mach-omap2/i2c.c
+++ b/arch/arm/mach-omap2/i2c.c
@@ -181,7 +181,7 @@ int __init omap_i2c_add_bus(struct omap_i2c_bus_platform_data *i2c_pdata,
 				 sizeof(struct omap_i2c_bus_platform_data));
 	WARN(IS_ERR(pdev), "Could not build omap_device for %s\n", name);
 
-	return PTR_RET(pdev);
+	return PTR_ERR_OR_ZERO(pdev);
 }
 
 static  int __init omap_i2c_cmdline(void)
diff --git a/arch/m68k/amiga/platform.c b/arch/m68k/amiga/platform.c
index 6083088..dacd9f9 100644
--- a/arch/m68k/amiga/platform.c
+++ b/arch/m68k/amiga/platform.c
@@ -56,7 +56,7 @@ static int __init amiga_init_bus(void)
 	n = AMIGAHW_PRESENT(ZORRO3) ? 4 : 2;
 	pdev = platform_device_register_simple("amiga-zorro", -1,
 					       zorro_resources, n);
-	return PTR_RET(pdev);
+	return PTR_ERR_OR_ZERO(pdev);
 }
 
 subsys_initcall(amiga_init_bus);
diff --git a/arch/m68k/kernel/time.c b/arch/m68k/kernel/time.c
index bea6bcf..7eb9792 100644
--- a/arch/m68k/kernel/time.c
+++ b/arch/m68k/kernel/time.c
@@ -90,7 +90,7 @@ static int __init rtc_init(void)
 		return -ENODEV;
 
 	pdev = platform_device_register_simple("rtc-generic", -1, NULL, 0);
-	return PTR_RET(pdev);
+	return PTR_ERR_OR_ZERO(pdev);
 }
 
 module_init(rtc_init);
diff --git a/arch/m68k/q40/config.c b/arch/m68k/q40/config.c
index 658542b..078bb74 100644
--- a/arch/m68k/q40/config.c
+++ b/arch/m68k/q40/config.c
@@ -338,6 +338,6 @@ static __init int q40_add_kbd_device(void)
 		return -ENODEV;
 
 	pdev = platform_device_register_simple("q40kbd", -1, NULL, 0);
-	return PTR_RET(pdev);
+	return PTR_ERR_OR_ZERO(pdev);
 }
 arch_initcall(q40_add_kbd_device);
diff --git a/arch/powerpc/kernel/iommu.c b/arch/powerpc/kernel/iommu.c
index c0d0dbd..3a149eb 100644
--- a/arch/powerpc/kernel/iommu.c
+++ b/arch/powerpc/kernel/iommu.c
@@ -102,7 +102,7 @@ static int __init fail_iommu_debugfs(void)
 	struct dentry *dir = fault_create_debugfs_attr("fail_iommu",
 						       NULL, &fail_iommu);
 
-	return PTR_RET(dir);
+	return PTR_ERR_OR_ZERO(dir);
 }
 late_initcall(fail_iommu_debugfs);
 
diff --git a/arch/powerpc/kernel/time.c b/arch/powerpc/kernel/time.c
index 5fc29ad..77e78ef 100644
--- a/arch/powerpc/kernel/time.c
+++ b/arch/powerpc/kernel/time.c
@@ -1050,7 +1050,7 @@ static int __init rtc_init(void)
 
 	pdev = platform_device_register_simple("rtc-generic", -1, NULL, 0);
 
-	return PTR_RET(pdev);
+	return PTR_ERR_OR_ZERO(pdev);
 }
 
 module_init(rtc_init);
diff --git a/arch/powerpc/platforms/ps3/time.c b/arch/powerpc/platforms/ps3/time.c
index cba1e6b..ce73ce8 100644
--- a/arch/powerpc/platforms/ps3/time.c
+++ b/arch/powerpc/platforms/ps3/time.c
@@ -90,7 +90,7 @@ static int __init ps3_rtc_init(void)
 
 	pdev = platform_device_register_simple("rtc-ps3", -1, NULL, 0);
 
-	return PTR_RET(pdev);
+	return PTR_ERR_OR_ZERO(pdev);
 }
 
 module_init(ps3_rtc_init);
diff --git a/arch/powerpc/sysdev/rtc_cmos_setup.c b/arch/powerpc/sysdev/rtc_cmos_setup.c
index af79e1e..af0f9be 100644
--- a/arch/powerpc/sysdev/rtc_cmos_setup.c
+++ b/arch/powerpc/sysdev/rtc_cmos_setup.c
@@ -62,7 +62,7 @@ static int  __init add_rtc(void)
 	pd = platform_device_register_simple("rtc_cmos", -1,
 					     &res[0], num_res);
 
-	return PTR_RET(pd);
+	return PTR_ERR_OR_ZERO(pd);
 }
 fs_initcall(add_rtc);
 
diff --git a/arch/s390/hypfs/hypfs_dbfs.c b/arch/s390/hypfs/hypfs_dbfs.c
index bb5dd49..17ab8b7 100644
--- a/arch/s390/hypfs/hypfs_dbfs.c
+++ b/arch/s390/hypfs/hypfs_dbfs.c
@@ -105,7 +105,7 @@ void hypfs_dbfs_remove_file(struct hypfs_dbfs_file *df)
 int hypfs_dbfs_init(void)
 {
 	dbfs_dir = debugfs_create_dir("s390_hypfs", NULL);
-	return PTR_RET(dbfs_dir);
+	return PTR_ERR_OR_ZERO(dbfs_dir);
 }
 
 void hypfs_dbfs_exit(void)
diff --git a/drivers/char/tile-srom.c b/drivers/char/tile-srom.c
index 2e2036e..a3a792f 100644
--- a/drivers/char/tile-srom.c
+++ b/drivers/char/tile-srom.c
@@ -371,7 +371,7 @@ static int srom_setup_minor(struct srom_dev *srom, int index)
 
 	dev = device_create(srom_class, &platform_bus,
 			    MKDEV(srom_major, index), srom, "%d", index);
-	return PTR_RET(dev);
+	return PTR_ERR_OR_ZERO(dev);
 }
 
 /** srom_init() - Initialize the driver's module. */
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 71c2c71..17a6ec5 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3055,7 +3055,7 @@ static int cma_join_ib_multicast(struct rdma_id_private *id_priv,
 						id_priv->id.port_num, &rec,
 						comp_mask, GFP_KERNEL,
 						cma_ib_mc_handler, mc);
-	return PTR_RET(mc->multicast.ib);
+	return PTR_ERR_OR_ZERO(mc->multicast.ib);
 }
 
 static void iboe_mcast_work_handler(struct work_struct *work)
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index cff6f02..7f2a032 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -996,7 +996,7 @@ static int __init cops_module_init(void)
 		printk(KERN_WARNING "%s: You shouldn't autoprobe with insmod\n",
 			cardname);
 	cops_dev = cops_probe(-1);
-	return PTR_RET(cops_dev);
+	return PTR_ERR_OR_ZERO(cops_dev);
 }
 
 static void __exit cops_module_exit(void)
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index b5782cd..01e2ac5 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1243,7 +1243,7 @@ static int __init ltpc_module_init(void)
 		       "ltpc: Autoprobing is not recommended for modules\n");
 
 	dev_ltpc = ltpc_probe();
-	return PTR_RET(dev_ltpc);
+	return PTR_ERR_OR_ZERO(dev_ltpc);
 }
 module_init(ltpc_module_init);
 #endif
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index e8d0ef5..10ceca5 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -1147,7 +1147,7 @@ static struct net_device *atarilance_dev;
 static int __init atarilance_module_init(void)
 {
 	atarilance_dev = atarilance_probe(-1);
-	return PTR_RET(atarilance_dev);
+	return PTR_ERR_OR_ZERO(atarilance_dev);
 }
 
 static void __exit atarilance_module_exit(void)
diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index a51497c..e108e91 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -188,7 +188,7 @@ static struct net_device *dev_mvme147_lance;
 int __init init_module(void)
 {
 	dev_mvme147_lance = mvme147lance_probe(-1);
-	return PTR_RET(dev_mvme147_lance);
+	return PTR_ERR_OR_ZERO(dev_mvme147_lance);
 }
 
 void __exit cleanup_module(void)
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 26fc0ce..1cf33ad 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -1238,7 +1238,7 @@ MODULE_PARM_DESC(dma, "ni6510 ISA DMA channel (ignored for some cards)");
 int __init init_module(void)
 {
  	dev_ni65 = ni65_probe(-1);
-	return PTR_RET(dev_ni65);
+	return PTR_ERR_OR_ZERO(dev_ni65);
 }
 
 void __exit cleanup_module(void)
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index 4375abe..d6b2029 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -940,7 +940,7 @@ static struct net_device *sun3lance_dev;
 int __init init_module(void)
 {
 	sun3lance_dev = sun3lance_probe(-1);
-	return PTR_RET(sun3lance_dev);
+	return PTR_ERR_OR_ZERO(sun3lance_dev);
 }
 
 void __exit cleanup_module(void)
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c
index 202869c..3962a7a 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c
@@ -50,7 +50,7 @@ int brcmf_debugfs_attach(struct brcmf_pub *drvr)
 		return -ENODEV;
 
 	drvr->dbgfs_dir = debugfs_create_dir(dev_name(dev), root_folder);
-	return PTR_RET(drvr->dbgfs_dir);
+	return PTR_ERR_OR_ZERO(drvr->dbgfs_dir);
 }
 
 void brcmf_debugfs_detach(struct brcmf_pub *drvr)
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/debug.c b/drivers/net/wireless/brcm80211/brcmsmac/debug.c
index 9761deb..a5d4add 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/debug.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/debug.c
@@ -56,7 +56,7 @@ int brcms_debugfs_attach(struct brcms_pub *drvr)
 
 	drvr->dbgfs_dir = debugfs_create_dir(
 		 dev_name(&drvr->wlc->hw->d11core->dev), root_folder);
-	return PTR_RET(drvr->dbgfs_dir);
+	return PTR_ERR_OR_ZERO(drvr->dbgfs_dir);
 }
 
 void brcms_debugfs_detach(struct brcms_pub *drvr)
diff --git a/drivers/platform/x86/samsung-q10.c b/drivers/platform/x86/samsung-q10.c
index 1a90b62..4430b8c 100644
--- a/drivers/platform/x86/samsung-q10.c
+++ b/drivers/platform/x86/samsung-q10.c
@@ -176,7 +176,7 @@ static int __init samsungq10_init(void)
 						   samsungq10_probe,
 						   NULL, 0, NULL, 0);
 
-	return PTR_RET(samsungq10_device);
+	return PTR_ERR_OR_ZERO(samsungq10_device);
 }
 
 static void __exit samsungq10_exit(void)
diff --git a/drivers/regulator/fan53555.c b/drivers/regulator/fan53555.c
index f0e1ae5..192444a 100644
--- a/drivers/regulator/fan53555.c
+++ b/drivers/regulator/fan53555.c
@@ -219,7 +219,7 @@ static int fan53555_regulator_register(struct fan53555_device_info *di,
 	rdesc->owner = THIS_MODULE;
 
 	di->rdev = regulator_register(&di->desc, config);
-	return PTR_RET(di->rdev);
+	return PTR_ERR_OR_ZERO(di->rdev);
 
 }
 
diff --git a/drivers/spi/spi-fsl-spi.c b/drivers/spi/spi-fsl-spi.c
index 14e202e..6e80639 100644
--- a/drivers/spi/spi-fsl-spi.c
+++ b/drivers/spi/spi-fsl-spi.c
@@ -901,7 +901,7 @@ static int plat_mpc8xxx_spi_probe(struct platform_device *pdev)
 		return -EINVAL;
 
 	master = fsl_spi_probe(&pdev->dev, mem, irq);
-	return PTR_RET(master);
+	return PTR_ERR_OR_ZERO(master);
 }
 
 static int plat_mpc8xxx_spi_remove(struct platform_device *pdev)
diff --git a/drivers/spi/spidev.c b/drivers/spi/spidev.c
index 911e9e0..ca5bcfe 100644
--- a/drivers/spi/spidev.c
+++ b/drivers/spi/spidev.c
@@ -603,7 +603,7 @@ static int spidev_probe(struct spi_device *spi)
 		dev = device_create(spidev_class, &spi->dev, spidev->devt,
 				    spidev, "spidev%d.%d",
 				    spi->master->bus_num, spi->chip_select);
-		status = PTR_RET(dev);
+		status = PTR_ERR_OR_ZERO(dev);
 	} else {
 		dev_dbg(&spi->dev, "no minor number available!\n");
 		status = -ENODEV;
diff --git a/drivers/video/omap2/dss/core.c b/drivers/video/omap2/dss/core.c
index c9c2252..a65f1ac 100644
--- a/drivers/video/omap2/dss/core.c
+++ b/drivers/video/omap2/dss/core.c
@@ -189,7 +189,7 @@ int dss_debugfs_create_file(const char *name, void (*write)(struct seq_file *))
 	d = debugfs_create_file(name, S_IRUGO, dss_debugfs_dir,
 			write, &dss_debug_fops);
 
-	return PTR_RET(d);
+	return PTR_ERR_OR_ZERO(d);
 }
 #else /* CONFIG_OMAP2_DSS_DEBUGFS */
 static inline int dss_initialize_debugfs(void)
diff --git a/fs/btrfs/dev-replace.c b/fs/btrfs/dev-replace.c
index 65241f3..b63903f 100644
--- a/fs/btrfs/dev-replace.c
+++ b/fs/btrfs/dev-replace.c
@@ -747,7 +747,7 @@ int btrfs_resume_dev_replace_async(struct btrfs_fs_info *fs_info)
 	WARN_ON(atomic_xchg(
 		&fs_info->mutually_exclusive_operation_running, 1));
 	task = kthread_run(btrfs_dev_replace_kthread, fs_info, "btrfs-devrepl");
-	return PTR_RET(task);
+	return PTR_ERR_OR_ZERO(task);
 }
 
 static int btrfs_dev_replace_kthread(void *data)
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index af978f7..1850a96 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -3140,7 +3140,7 @@ int btrfs_orphan_cleanup(struct btrfs_root *root)
 		found_key.type = BTRFS_INODE_ITEM_KEY;
 		found_key.offset = 0;
 		inode = btrfs_iget(root->fs_info->sb, &found_key, root, NULL);
-		ret = PTR_RET(inode);
+		ret = PTR_ERR_OR_ZERO(inode);
 		if (ret && ret != -ESTALE)
 			goto out;
 
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 7ad6ecf..edf623a 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -590,7 +590,7 @@ int __init bt_sysfs_init(void)
 
 	bt_class = class_create(THIS_MODULE, "bluetooth");
 
-	return PTR_RET(bt_class);
+	return PTR_ERR_OR_ZERO(bt_class);
 }
 
 void bt_sysfs_cleanup(void)
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 70f656c..dbd1c78 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -64,7 +64,7 @@ static int ebt_broute(struct sk_buff *skb)
 static int __net_init broute_net_init(struct net *net)
 {
 	net->xt.broute_table = ebt_register_table(net, &broute_table);
-	return PTR_RET(net->xt.broute_table);
+	return PTR_ERR_OR_ZERO(net->xt.broute_table);
 }
 
 static void __net_exit broute_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 3c2e9dc..94b2b70 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -100,7 +100,7 @@ static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 static int __net_init frame_filter_net_init(struct net *net)
 {
 	net->xt.frame_filter = ebt_register_table(net, &frame_filter);
-	return PTR_RET(net->xt.frame_filter);
+	return PTR_ERR_OR_ZERO(net->xt.frame_filter);
 }
 
 static void __net_exit frame_filter_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 10871bc..322555a 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -100,7 +100,7 @@ static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 static int __net_init frame_nat_net_init(struct net *net)
 {
 	net->xt.frame_nat = ebt_register_table(net, &frame_nat);
-	return PTR_RET(net->xt.frame_nat);
+	return PTR_ERR_OR_ZERO(net->xt.frame_nat);
 }
 
 static void __net_exit frame_nat_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index eadab1e..a865f6f 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -48,7 +48,7 @@ static int __net_init arptable_filter_net_init(struct net *net)
 	net->ipv4.arptable_filter =
 		arpt_register_table(net, &packet_filter, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv4.arptable_filter);
+	return PTR_ERR_OR_ZERO(net->ipv4.arptable_filter);
 }
 
 static void __net_exit arptable_filter_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 6b3da5c..50af5b4 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -69,7 +69,7 @@ static int __net_init iptable_filter_net_init(struct net *net)
 	net->ipv4.iptable_filter =
 		ipt_register_table(net, &packet_filter, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv4.iptable_filter);
+	return PTR_ERR_OR_ZERO(net->ipv4.iptable_filter);
 }
 
 static void __net_exit iptable_filter_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index cba5658..0d8cd82 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -107,7 +107,7 @@ static int __net_init iptable_mangle_net_init(struct net *net)
 	net->ipv4.iptable_mangle =
 		ipt_register_table(net, &packet_mangler, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv4.iptable_mangle);
+	return PTR_ERR_OR_ZERO(net->ipv4.iptable_mangle);
 }
 
 static void __net_exit iptable_mangle_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 6383273..683bfaf 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -292,7 +292,7 @@ static int __net_init iptable_nat_net_init(struct net *net)
 		return -ENOMEM;
 	net->ipv4.nat_table = ipt_register_table(net, &nf_nat_ipv4_table, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv4.nat_table);
+	return PTR_ERR_OR_ZERO(net->ipv4.nat_table);
 }
 
 static void __net_exit iptable_nat_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 03d9696..1f82aea 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -48,7 +48,7 @@ static int __net_init iptable_raw_net_init(struct net *net)
 	net->ipv4.iptable_raw =
 		ipt_register_table(net, &packet_raw, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv4.iptable_raw);
+	return PTR_ERR_OR_ZERO(net->ipv4.iptable_raw);
 }
 
 static void __net_exit iptable_raw_net_exit(struct net *net)
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index b283d8e..f867a8d 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -66,7 +66,7 @@ static int __net_init iptable_security_net_init(struct net *net)
 	net->ipv4.iptable_security =
 		ipt_register_table(net, &security_table, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv4.iptable_security);
+	return PTR_ERR_OR_ZERO(net->ipv4.iptable_security);
 }
 
 static void __net_exit iptable_security_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index beb5777..29b44b1 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -61,7 +61,7 @@ static int __net_init ip6table_filter_net_init(struct net *net)
 	net->ipv6.ip6table_filter =
 		ip6t_register_table(net, &packet_filter, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv6.ip6table_filter);
+	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_filter);
 }
 
 static void __net_exit ip6table_filter_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index e075399..c705907 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -101,7 +101,7 @@ static int __net_init ip6table_mangle_net_init(struct net *net)
 	net->ipv6.ip6table_mangle =
 		ip6t_register_table(net, &packet_mangler, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv6.ip6table_mangle);
+	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_mangle);
 }
 
 static void __net_exit ip6table_mangle_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 6383f90..9b076d2 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -293,7 +293,7 @@ static int __net_init ip6table_nat_net_init(struct net *net)
 		return -ENOMEM;
 	net->ipv6.ip6table_nat = ip6t_register_table(net, &nf_nat_ipv6_table, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv6.ip6table_nat);
+	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_nat);
 }
 
 static void __net_exit ip6table_nat_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 60d1bdd..9a626d8 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -40,7 +40,7 @@ static int __net_init ip6table_raw_net_init(struct net *net)
 	net->ipv6.ip6table_raw =
 		ip6t_register_table(net, &packet_raw, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv6.ip6table_raw);
+	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_raw);
 }
 
 static void __net_exit ip6table_raw_net_exit(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index db15535..ce88d1d 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -58,7 +58,7 @@ static int __net_init ip6table_security_net_init(struct net *net)
 	net->ipv6.ip6table_security =
 		ip6t_register_table(net, &security_table, repl);
 	kfree(repl);
-	return PTR_RET(net->ipv6.ip6table_security);
+	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_security);
 }
 
 static void __net_exit ip6table_security_net_exit(struct net *net)
diff --git a/scripts/coccinelle/api/ptr_ret.cocci b/scripts/coccinelle/api/ptr_ret.cocci
index 15f076f..e0981bb 100644
--- a/scripts/coccinelle/api/ptr_ret.cocci
+++ b/scripts/coccinelle/api/ptr_ret.cocci
@@ -1,5 +1,5 @@
 ///
-/// Use PTR_RET rather than if(IS_ERR(...)) + PTR_ERR
+/// Use PTR_ERR_OR_ZERO rather than if(IS_ERR(...)) + PTR_ERR
 ///
 // Confidence: High
 // Copyright: (C) 2012 Julia Lawall, INRIA/LIP6.  GPLv2.
@@ -7,7 +7,7 @@
 // URL: http://coccinelle.lip6.fr/
 // Options: -no_includes -include_headers
 //
-// Keywords: ERR_PTR, PTR_ERR, PTR_RET
+// Keywords: ERR_PTR, PTR_ERR, PTR_RET, PTR_ERR_OR_ZERO
 // Version min: 2.6.39
 //
 
@@ -21,21 +21,21 @@ expression ptr;
 @@
 
 - if (IS_ERR(ptr)) return PTR_ERR(ptr); else return 0;
-+ return PTR_RET(ptr);
++ return PTR_ERR_OR_ZERO(ptr);
 
 @depends on patch@
 expression ptr;
 @@
 
 - if (IS_ERR(ptr)) return PTR_ERR(ptr); return 0;
-+ return PTR_RET(ptr);
++ return PTR_ERR_OR_ZERO(ptr);
 
 @depends on patch@
 expression ptr;
 @@
 
 - (IS_ERR(ptr) ? PTR_ERR(ptr) : 0)
-+ PTR_RET(ptr)
++ PTR_ERR_OR_ZERO(ptr)
 
 @r1 depends on !patch@
 expression ptr;
diff --git a/sound/soc/soc-io.c b/sound/soc/soc-io.c
index 8ca9ecc..122c0c1 100644
--- a/sound/soc/soc-io.c
+++ b/sound/soc/soc-io.c
@@ -158,7 +158,7 @@ int snd_soc_codec_set_cache_io(struct snd_soc_codec *codec,
 		return -EINVAL;
 	}
 
-	return PTR_RET(codec->control_data);
+	return PTR_ERR_OR_ZERO(codec->control_data);
 }
 EXPORT_SYMBOL_GPL(snd_soc_codec_set_cache_io);
 #else
-- 
1.8.1.2
