From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 1/1] Constify struct sysfs_ops for v2.6.33-rc4
Date: Sun, 17 Jan 2010 21:15:49 +0100
Message-ID: <4B536FF5.3000705@gmail.com>
References: <4B5338D6.2050209@gmail.com> <20100117182537.GQ19799@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, teigland@redhat.com,
	Matt_Domsch@dell.com, maciej.sosnowski@intel.com,
	hjk@linutronix.de, Pekka Enberg <penberg@cs.helsinki.fi>,
	jens.axboe@oracle.com, shemminger@vyatta.com,
	akpm@linux-foundation.org, davem@davemloft.net,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754597Ab0AQUO1@vger.kernel.org>
In-Reply-To: <20100117182537.GQ19799@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> On Sun, Jan 17, 2010 at 05:20:38PM +0100, Emese Revfy wrote:
> 
>> Signed-off-by: Emese Revfy <re.emese@gmail.com>
>> Acked-by: David Teigland <teigland@redhat.com>
>> Acked-by: Matt Domsch <Matt_Domsch@dell.com>
>> Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
>> Acked-by: Hans J. Koch <hjk@linutronix.de>
>> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
>> Acked-by: Jens Axboe <jens.axboe@oracle.com>
>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> NACKed-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> Same reason.
> 
>> -        ssize_t (*show)(struct kobject *, struct attribute *, char *);
>> -        ssize_t (*store)(struct kobject *, struct attribute *, const char *);
>> +        ssize_t (* const show)(struct kobject *, struct attribute *, char *);
>> +        ssize_t (* const store)(struct kobject *, struct attribute *, const char *);
> 

Ok, I removed the field constification, here's the updated patch:

diff --git a/Documentation/kobject.txt b/Documentation/kobject.txt
index c79ab99..a310df9 100644
--- a/Documentation/kobject.txt
+++ b/Documentation/kobject.txt
@@ -266,7 +266,7 @@ kobj_type:
 
     struct kobj_type {
 	    void (*release)(struct kobject *);
-	    struct sysfs_ops	*sysfs_ops;
+	    const struct sysfs_ops	*sysfs_ops;
 	    struct attribute	**default_attrs;
     };
 
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 8f06035..b3a5818 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -282,7 +282,7 @@ static ssize_t cache_show(struct kobject * kobj, struct attribute * attr, char *
 	return ret;
 }
 
-static struct sysfs_ops cache_sysfs_ops = {
+static const struct sysfs_ops cache_sysfs_ops = {
 	.show   = cache_show
 };
 
diff --git a/arch/powerpc/kernel/cacheinfo.c b/arch/powerpc/kernel/cacheinfo.c
index bb37b1d..01fe9ce 100644
--- a/arch/powerpc/kernel/cacheinfo.c
+++ b/arch/powerpc/kernel/cacheinfo.c
@@ -642,7 +642,7 @@ static struct kobj_attribute *cache_index_opt_attrs[] = {
 	&cache_assoc_attr,
 };
 
-static struct sysfs_ops cache_index_ops = {
+static const struct sysfs_ops cache_index_ops = {
 	.show = cache_index_show,
 };
 
diff --git a/arch/sh/kernel/cpu/sh4/sq.c b/arch/sh/kernel/cpu/sh4/sq.c
index 8a8a993..7b3079b 100644
--- a/arch/sh/kernel/cpu/sh4/sq.c
+++ b/arch/sh/kernel/cpu/sh4/sq.c
@@ -327,7 +327,7 @@ static struct attribute *sq_sysfs_attrs[] = {
 	NULL,
 };
 
-static struct sysfs_ops sq_sysfs_ops = {
+static const struct sysfs_ops sq_sysfs_ops = {
 	.show	= sq_sysfs_show,
 	.store	= sq_sysfs_store,
 };
diff --git a/arch/x86/kernel/cpu/intel_cacheinfo.c b/arch/x86/kernel/cpu/intel_cacheinfo.c
index fc6c8ef..4018846 100644
--- a/arch/x86/kernel/cpu/intel_cacheinfo.c
+++ b/arch/x86/kernel/cpu/intel_cacheinfo.c
@@ -848,7 +848,7 @@ static ssize_t store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static struct sysfs_ops sysfs_ops = {
+static const struct sysfs_ops sysfs_ops = {
 	.show   = show,
 	.store  = store,
 };
diff --git a/arch/x86/kernel/cpu/mcheck/mce_amd.c b/arch/x86/kernel/cpu/mcheck/mce_amd.c
index 83a3d1f..cda932c 100644
--- a/arch/x86/kernel/cpu/mcheck/mce_amd.c
+++ b/arch/x86/kernel/cpu/mcheck/mce_amd.c
@@ -388,7 +388,7 @@ static ssize_t store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static struct sysfs_ops threshold_ops = {
+static const struct sysfs_ops threshold_ops = {
 	.show			= show,
 	.store			= store,
 };
diff --git a/block/blk-integrity.c b/block/blk-integrity.c
index 15c6308..96e83c2 100644
--- a/block/blk-integrity.c
+++ b/block/blk-integrity.c
@@ -278,7 +278,7 @@ static struct attribute *integrity_attrs[] = {
 	NULL,
 };
 
-static struct sysfs_ops integrity_ops = {
+static const struct sysfs_ops integrity_ops = {
 	.show	= &integrity_attr_show,
 	.store	= &integrity_attr_store,
 };
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 8606c95..f443753 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -447,7 +447,7 @@ static void blk_release_queue(struct kobject *kobj)
 	kmem_cache_free(blk_requestq_cachep, q);
 }
 
-static struct sysfs_ops queue_sysfs_ops = {
+static const struct sysfs_ops queue_sysfs_ops = {
 	.show	= queue_attr_show,
 	.store	= queue_attr_store,
 };
diff --git a/block/elevator.c b/block/elevator.c
index 9ad5ccc..38e8920 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -883,7 +883,7 @@ elv_attr_store(struct kobject *kobj, struct attribute *attr,
 	return error;
 }
 
-static struct sysfs_ops elv_sysfs_ops = {
+static const struct sysfs_ops elv_sysfs_ops = {
 	.show	= elv_attr_show,
 	.store	= elv_attr_store,
 };
diff --git a/drivers/base/bus.c b/drivers/base/bus.c
index c0c5a43..d820f3e 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -70,7 +70,7 @@ static ssize_t drv_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static struct sysfs_ops driver_sysfs_ops = {
+static const struct sysfs_ops driver_sysfs_ops = {
 	.show	= drv_attr_show,
 	.store	= drv_attr_store,
 };
@@ -115,7 +115,7 @@ static ssize_t bus_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static struct sysfs_ops bus_sysfs_ops = {
+static const struct sysfs_ops bus_sysfs_ops = {
 	.show	= bus_attr_show,
 	.store	= bus_attr_store,
 };
diff --git a/drivers/base/class.c b/drivers/base/class.c
index 161746d..c2359c8 100644
--- a/drivers/base/class.c
+++ b/drivers/base/class.c
@@ -61,7 +61,7 @@ static void class_release(struct kobject *kobj)
 			 "be careful\n", class->name);
 }
 
-static struct sysfs_ops class_sysfs_ops = {
+static const struct sysfs_ops class_sysfs_ops = {
 	.show	= class_attr_show,
 	.store	= class_attr_store,
 };
diff --git a/drivers/base/core.c b/drivers/base/core.c
index 2820257..e0c9a3c 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -100,7 +100,7 @@ static ssize_t dev_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static struct sysfs_ops dev_sysfs_ops = {
+static const struct sysfs_ops dev_sysfs_ops = {
 	.show	= dev_attr_show,
 	.store	= dev_attr_store,
 };
diff --git a/drivers/base/sys.c b/drivers/base/sys.c
index 0d90390..dd710ca 100644
--- a/drivers/base/sys.c
+++ b/drivers/base/sys.c
@@ -54,7 +54,7 @@ sysdev_store(struct kobject *kobj, struct attribute *attr,
 	return -EIO;
 }
 
-static struct sysfs_ops sysfs_ops = {
+static const struct sysfs_ops sysfs_ops = {
 	.show	= sysdev_show,
 	.store	= sysdev_store,
 };
@@ -104,7 +104,7 @@ static ssize_t sysdev_class_store(struct kobject *kobj, struct attribute *attr,
 	return -EIO;
 }
 
-static struct sysfs_ops sysfs_class_ops = {
+static const struct sysfs_ops sysfs_class_ops = {
 	.show	= sysdev_class_show,
 	.store	= sysdev_class_store,
 };
diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
index 2ddf03a..44eab68 100644
--- a/drivers/block/pktcdvd.c
+++ b/drivers/block/pktcdvd.c
@@ -284,7 +284,7 @@ static ssize_t kobj_pkt_store(struct kobject *kobj,
 	return len;
 }
 
-static struct sysfs_ops kobj_pkt_ops = {
+static const struct sysfs_ops kobj_pkt_ops = {
 	.show = kobj_pkt_show,
 	.store = kobj_pkt_store
 };
diff --git a/drivers/cpufreq/cpufreq.c b/drivers/cpufreq/cpufreq.c
index 67bc2ec..2d5d575 100644
--- a/drivers/cpufreq/cpufreq.c
+++ b/drivers/cpufreq/cpufreq.c
@@ -766,7 +766,7 @@ static void cpufreq_sysfs_release(struct kobject *kobj)
 	complete(&policy->kobj_unregister);
 }
 
-static struct sysfs_ops sysfs_ops = {
+static const struct sysfs_ops sysfs_ops = {
 	.show	= show,
 	.store	= store,
 };
diff --git a/drivers/cpuidle/sysfs.c b/drivers/cpuidle/sysfs.c
index 97b0038..aaaa360 100644
--- a/drivers/cpuidle/sysfs.c
+++ b/drivers/cpuidle/sysfs.c
@@ -191,7 +191,7 @@ static ssize_t cpuidle_store(struct kobject * kobj, struct attribute * attr,
 	return ret;
 }
 
-static struct sysfs_ops cpuidle_sysfs_ops = {
+static const struct sysfs_ops cpuidle_sysfs_ops = {
 	.show = cpuidle_show,
 	.store = cpuidle_store,
 };
@@ -277,7 +277,7 @@ static ssize_t cpuidle_state_show(struct kobject * kobj,
 	return ret;
 }
 
-static struct sysfs_ops cpuidle_state_sysfs_ops = {
+static const struct sysfs_ops cpuidle_state_sysfs_ops = {
 	.show = cpuidle_state_show,
 };
 
diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index dcc4ab7..cc834bb 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -1146,7 +1146,7 @@ ioat_attr_show(struct kobject *kobj, struct attribute *attr, char *page)
 	return entry->show(&chan->common, page);
 }
 
-struct sysfs_ops ioat_sysfs_ops = {
+const struct sysfs_ops ioat_sysfs_ops = {
 	.show	= ioat_attr_show,
 };
 
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index bbc3e78..f2db62c 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -347,7 +347,7 @@ bool ioat_cleanup_preamble(struct ioat_chan_common *chan,
 			   unsigned long *phys_complete);
 void ioat_kobject_add(struct ioatdma_device *device, struct kobj_type *type);
 void ioat_kobject_del(struct ioatdma_device *device);
-extern struct sysfs_ops ioat_sysfs_ops;
+extern const struct sysfs_ops ioat_sysfs_ops;
 extern struct ioat_sysfs_entry ioat_version_attr;
 extern struct ioat_sysfs_entry ioat_cap_attr;
 #endif /* IOATDMA_H */
diff --git a/drivers/edac/edac_device_sysfs.c b/drivers/edac/edac_device_sysfs.c
index 5376457..5fdedbc 100644
--- a/drivers/edac/edac_device_sysfs.c
+++ b/drivers/edac/edac_device_sysfs.c
@@ -137,7 +137,7 @@ static ssize_t edac_dev_ctl_info_store(struct kobject *kobj,
 }
 
 /* edac_dev file operations for an 'ctl_info' */
-static struct sysfs_ops device_ctl_info_ops = {
+static const struct sysfs_ops device_ctl_info_ops = {
 	.show = edac_dev_ctl_info_show,
 	.store = edac_dev_ctl_info_store
 };
@@ -373,7 +373,7 @@ static ssize_t edac_dev_instance_store(struct kobject *kobj,
 }
 
 /* edac_dev file operations for an 'instance' */
-static struct sysfs_ops device_instance_ops = {
+static const struct sysfs_ops device_instance_ops = {
 	.show = edac_dev_instance_show,
 	.store = edac_dev_instance_store
 };
@@ -476,7 +476,7 @@ static ssize_t edac_dev_block_store(struct kobject *kobj,
 }
 
 /* edac_dev file operations for a 'block' */
-static struct sysfs_ops device_block_ops = {
+static const struct sysfs_ops device_block_ops = {
 	.show = edac_dev_block_show,
 	.store = edac_dev_block_store
 };
diff --git a/drivers/edac/edac_mc_sysfs.c b/drivers/edac/edac_mc_sysfs.c
index e1d4ce0..88840e9 100644
--- a/drivers/edac/edac_mc_sysfs.c
+++ b/drivers/edac/edac_mc_sysfs.c
@@ -245,7 +245,7 @@ static ssize_t csrowdev_store(struct kobject *kobj, struct attribute *attr,
 	return -EIO;
 }
 
-static struct sysfs_ops csrowfs_ops = {
+static const struct sysfs_ops csrowfs_ops = {
 	.show = csrowdev_show,
 	.store = csrowdev_store
 };
@@ -575,7 +575,7 @@ static ssize_t mcidev_store(struct kobject *kobj, struct attribute *attr,
 }
 
 /* Intermediate show/store table */
-static struct sysfs_ops mci_ops = {
+static const struct sysfs_ops mci_ops = {
 	.show = mcidev_show,
 	.store = mcidev_store
 };
diff --git a/drivers/edac/edac_pci_sysfs.c b/drivers/edac/edac_pci_sysfs.c
index fb60a87..bef94e3 100644
--- a/drivers/edac/edac_pci_sysfs.c
+++ b/drivers/edac/edac_pci_sysfs.c
@@ -121,7 +121,7 @@ static ssize_t edac_pci_instance_store(struct kobject *kobj,
 }
 
 /* fs_ops table */
-static struct sysfs_ops pci_instance_ops = {
+static const struct sysfs_ops pci_instance_ops = {
 	.show = edac_pci_instance_show,
 	.store = edac_pci_instance_store
 };
@@ -261,7 +261,7 @@ static ssize_t edac_pci_dev_store(struct kobject *kobj,
 	return -EIO;
 }
 
-static struct sysfs_ops edac_pci_sysfs_ops = {
+static const struct sysfs_ops edac_pci_sysfs_ops = {
 	.show = edac_pci_dev_show,
 	.store = edac_pci_dev_store
 };
diff --git a/drivers/firmware/edd.c b/drivers/firmware/edd.c
index 9e4f59d..110e24e 100644
--- a/drivers/firmware/edd.c
+++ b/drivers/firmware/edd.c
@@ -122,7 +122,7 @@ edd_attr_show(struct kobject * kobj, struct attribute *attr, char *buf)
 	return ret;
 }
 
-static struct sysfs_ops edd_attr_ops = {
+static const struct sysfs_ops edd_attr_ops = {
 	.show = edd_attr_show,
 };
 
diff --git a/drivers/firmware/efivars.c b/drivers/firmware/efivars.c
index f4f709d..082f06e 100644
--- a/drivers/firmware/efivars.c
+++ b/drivers/firmware/efivars.c
@@ -362,7 +362,7 @@ static ssize_t efivar_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static struct sysfs_ops efivar_attr_ops = {
+static const struct sysfs_ops efivar_attr_ops = {
 	.show = efivar_attr_show,
 	.store = efivar_attr_store,
 };
diff --git a/drivers/firmware/iscsi_ibft.c b/drivers/firmware/iscsi_ibft.c
index 051d1eb..0a5d4e7 100644
--- a/drivers/firmware/iscsi_ibft.c
+++ b/drivers/firmware/iscsi_ibft.c
@@ -525,7 +525,7 @@ static ssize_t ibft_show_attribute(struct kobject *kobj,
 	return ret;
 }
 
-static struct sysfs_ops ibft_attr_ops = {
+static const struct sysfs_ops ibft_attr_ops = {
 	.show = ibft_show_attribute,
 };
 
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 56f9234..8c58c7b 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -74,7 +74,7 @@ static struct attribute *def_attrs[] = {
 	NULL
 };
 
-static struct sysfs_ops memmap_attr_ops = {
+static const struct sysfs_ops memmap_attr_ops = {
 	.show = memmap_attr_show,
 };
 
diff --git a/drivers/gpu/drm/ttm/ttm_bo.c b/drivers/gpu/drm/ttm/ttm_bo.c
index 2920f9a..b342b3d 100644
--- a/drivers/gpu/drm/ttm/ttm_bo.c
+++ b/drivers/gpu/drm/ttm/ttm_bo.c
@@ -128,7 +128,7 @@ static struct attribute *ttm_bo_global_attrs[] = {
 	NULL
 };
 
-static struct sysfs_ops ttm_bo_global_ops = {
+static const struct sysfs_ops ttm_bo_global_ops = {
 	.show = &ttm_bo_global_show
 };
 
diff --git a/drivers/gpu/drm/ttm/ttm_memory.c b/drivers/gpu/drm/ttm/ttm_memory.c
index f5245c0..eb143e0 100644
--- a/drivers/gpu/drm/ttm/ttm_memory.c
+++ b/drivers/gpu/drm/ttm/ttm_memory.c
@@ -152,7 +152,7 @@ static struct attribute *ttm_mem_zone_attrs[] = {
 	NULL
 };
 
-static struct sysfs_ops ttm_mem_zone_ops = {
+static const struct sysfs_ops ttm_mem_zone_ops = {
 	.show = &ttm_mem_zone_show,
 	.store = &ttm_mem_zone_store
 };
diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 5130fc5..764787e 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -3597,7 +3597,7 @@ static ssize_t cm_show_counter(struct kobject *obj, struct attribute *attr,
 		       atomic_long_read(&group->counter[cm_attr->index]));
 }
 
-static struct sysfs_ops cm_counter_ops = {
+static const struct sysfs_ops cm_counter_ops = {
 	.show = cm_show_counter
 };
 
diff --git a/drivers/infiniband/core/sysfs.c b/drivers/infiniband/core/sysfs.c
index 158a214..1558bb7 100644
--- a/drivers/infiniband/core/sysfs.c
+++ b/drivers/infiniband/core/sysfs.c
@@ -79,7 +79,7 @@ static ssize_t port_attr_show(struct kobject *kobj,
 	return port_attr->show(p, port_attr, buf);
 }
 
-static struct sysfs_ops port_sysfs_ops = {
+static const struct sysfs_ops port_sysfs_ops = {
 	.show = port_attr_show
 };
 
diff --git a/drivers/md/dm-sysfs.c b/drivers/md/dm-sysfs.c
index f53392d..ed83d1c 100644
--- a/drivers/md/dm-sysfs.c
+++ b/drivers/md/dm-sysfs.c
@@ -75,7 +75,7 @@ static struct attribute *dm_attrs[] = {
 	NULL,
 };
 
-static struct sysfs_ops dm_sysfs_ops = {
+static const struct sysfs_ops dm_sysfs_ops = {
 	.show	= dm_attr_show,
 };
 
diff --git a/drivers/md/md.c b/drivers/md/md.c
index dd3dfe4..c599615 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -2642,7 +2642,7 @@ static void rdev_free(struct kobject *ko)
 	mdk_rdev_t *rdev = container_of(ko, mdk_rdev_t, kobj);
 	kfree(rdev);
 }
-static struct sysfs_ops rdev_sysfs_ops = {
+static const struct sysfs_ops rdev_sysfs_ops = {
 	.show		= rdev_attr_show,
 	.store		= rdev_attr_store,
 };
@@ -4059,7 +4059,7 @@ static void md_free(struct kobject *ko)
 	kfree(mddev);
 }
 
-static struct sysfs_ops md_sysfs_ops = {
+static const struct sysfs_ops md_sysfs_ops = {
 	.show	= md_attr_show,
 	.store	= md_attr_store,
 };
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index a866939..50715b4 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1577,7 +1577,7 @@ static struct attribute * veth_pool_attrs[] = {
 	NULL,
 };
 
-static struct sysfs_ops veth_pool_ops = {
+static const struct sysfs_ops veth_pool_ops = {
 	.show   = veth_pool_show,
 	.store  = veth_pool_store,
 };
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 16c9191..3fa4677 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -384,7 +384,7 @@ static struct attribute *veth_cnx_default_attrs[] = {
 	NULL
 };
 
-static struct sysfs_ops veth_cnx_sysfs_ops = {
+static const struct sysfs_ops veth_cnx_sysfs_ops = {
 		.show = veth_cnx_attribute_show
 };
 
@@ -441,7 +441,7 @@ static struct attribute *veth_port_default_attrs[] = {
 	NULL
 };
 
-static struct sysfs_ops veth_port_sysfs_ops = {
+static const struct sysfs_ops veth_port_sysfs_ops = {
 	.show = veth_port_attribute_show
 };
 
diff --git a/drivers/parisc/pdc_stable.c b/drivers/parisc/pdc_stable.c
index 0bc5d47..1062b8f 100644
--- a/drivers/parisc/pdc_stable.c
+++ b/drivers/parisc/pdc_stable.c
@@ -481,7 +481,7 @@ pdcspath_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static struct sysfs_ops pdcspath_attr_ops = {
+static const struct sysfs_ops pdcspath_attr_ops = {
 	.show = pdcspath_attr_show,
 	.store = pdcspath_attr_store,
 };
diff --git a/drivers/pci/hotplug/fakephp.c b/drivers/pci/hotplug/fakephp.c
index 6151389..0a894ef 100644
--- a/drivers/pci/hotplug/fakephp.c
+++ b/drivers/pci/hotplug/fakephp.c
@@ -73,7 +73,7 @@ static void legacy_release(struct kobject *kobj)
 }
 
 static struct kobj_type legacy_ktype = {
-	.sysfs_ops = &(struct sysfs_ops){
+	.sysfs_ops = &(const struct sysfs_ops){
 		.store = legacy_store, .show = legacy_show
 	},
 	.release = &legacy_release,
diff --git a/drivers/pci/slot.c b/drivers/pci/slot.c
index 8c02b6c..5584d8e 100644
--- a/drivers/pci/slot.c
+++ b/drivers/pci/slot.c
@@ -29,7 +29,7 @@ static ssize_t pci_slot_attr_store(struct kobject *kobj,
 	return attribute->store ? attribute->store(slot, buf, len) : -EIO;
 }
 
-static struct sysfs_ops pci_slot_sysfs_ops = {
+static const struct sysfs_ops pci_slot_sysfs_ops = {
 	.show = pci_slot_attr_show,
 	.store = pci_slot_attr_store,
 };
diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
index e941367..4de382a 100644
--- a/drivers/uio/uio.c
+++ b/drivers/uio/uio.c
@@ -129,7 +129,7 @@ static ssize_t map_type_show(struct kobject *kobj, struct attribute *attr,
 	return entry->show(mem, buf);
 }
 
-static struct sysfs_ops map_sysfs_ops = {
+static const struct sysfs_ops map_sysfs_ops = {
 	.show = map_type_show,
 };
 
@@ -217,7 +217,7 @@ static ssize_t portio_type_show(struct kobject *kobj, struct attribute *attr,
 	return entry->show(port, buf);
 }
 
-static struct sysfs_ops portio_sysfs_ops = {
+static const struct sysfs_ops portio_sysfs_ops = {
 	.show = portio_type_show,
 };
 
diff --git a/drivers/uwb/wlp/sysfs.c b/drivers/uwb/wlp/sysfs.c
index 0370399..6627c94 100644
--- a/drivers/uwb/wlp/sysfs.c
+++ b/drivers/uwb/wlp/sysfs.c
@@ -615,8 +615,7 @@ ssize_t wlp_wss_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static
-struct sysfs_ops wss_sysfs_ops = {
+static const struct sysfs_ops wss_sysfs_ops = {
 	.show	= wlp_wss_attr_show,
 	.store	= wlp_wss_attr_store,
 };
diff --git a/drivers/video/omap2/dss/manager.c b/drivers/video/omap2/dss/manager.c
index 27d9c46..378f493 100644
--- a/drivers/video/omap2/dss/manager.c
+++ b/drivers/video/omap2/dss/manager.c
@@ -341,7 +341,7 @@ static ssize_t manager_attr_store(struct kobject *kobj, struct attribute *attr,
 	return manager_attr->store(manager, buf, size);
 }
 
-static struct sysfs_ops manager_sysfs_ops = {
+static const struct sysfs_ops manager_sysfs_ops = {
 	.show = manager_attr_show,
 	.store = manager_attr_store,
 };
diff --git a/drivers/video/omap2/dss/overlay.c b/drivers/video/omap2/dss/overlay.c
index b7f9a73..465b141 100644
--- a/drivers/video/omap2/dss/overlay.c
+++ b/drivers/video/omap2/dss/overlay.c
@@ -320,7 +320,7 @@ static ssize_t overlay_attr_store(struct kobject *kobj, struct attribute *attr,
 	return overlay_attr->store(overlay, buf, size);
 }
 
-static struct sysfs_ops overlay_sysfs_ops = {
+static const struct sysfs_ops overlay_sysfs_ops = {
 	.show = overlay_attr_show,
 	.store = overlay_attr_store,
 };
diff --git a/drivers/xen/sys-hypervisor.c b/drivers/xen/sys-hypervisor.c
index ae5cb05..bb71ab2 100644
--- a/drivers/xen/sys-hypervisor.c
+++ b/drivers/xen/sys-hypervisor.c
@@ -426,7 +426,7 @@ static ssize_t hyp_sysfs_store(struct kobject *kobj,
 	return 0;
 }
 
-static struct sysfs_ops hyp_sysfs_ops = {
+static const struct sysfs_ops hyp_sysfs_ops = {
 	.show = hyp_sysfs_show,
 	.store = hyp_sysfs_store,
 };
diff --git a/fs/btrfs/sysfs.c b/fs/btrfs/sysfs.c
index a240b6f..4ce16ef 100644
--- a/fs/btrfs/sysfs.c
+++ b/fs/btrfs/sysfs.c
@@ -164,12 +164,12 @@ static void btrfs_root_release(struct kobject *kobj)
 	complete(&root->kobj_unregister);
 }
 
-static struct sysfs_ops btrfs_super_attr_ops = {
+static const struct sysfs_ops btrfs_super_attr_ops = {
 	.show	= btrfs_super_attr_show,
 	.store	= btrfs_super_attr_store,
 };
 
-static struct sysfs_ops btrfs_root_attr_ops = {
+static const struct sysfs_ops btrfs_root_attr_ops = {
 	.show	= btrfs_root_attr_show,
 	.store	= btrfs_root_attr_store,
 };
diff --git a/fs/dlm/lockspace.c b/fs/dlm/lockspace.c
index c010ecf..a8d8c59 100644
--- a/fs/dlm/lockspace.c
+++ b/fs/dlm/lockspace.c
@@ -148,7 +148,7 @@ static void lockspace_kobj_release(struct kobject *k)
 	kfree(ls);
 }
 
-static struct sysfs_ops dlm_attr_ops = {
+static const struct sysfs_ops dlm_attr_ops = {
 	.show  = dlm_attr_show,
 	.store = dlm_attr_store,
 };
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 735c20d..af2eb20 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -2292,7 +2292,7 @@ static void ext4_sb_release(struct kobject *kobj)
 }
 
 
-static struct sysfs_ops ext4_attr_ops = {
+static const struct sysfs_ops ext4_attr_ops = {
 	.show	= ext4_attr_show,
 	.store	= ext4_attr_store,
 };
diff --git a/fs/gfs2/sys.c b/fs/gfs2/sys.c
index 0dc3462..0621f4b 100644
--- a/fs/gfs2/sys.c
+++ b/fs/gfs2/sys.c
@@ -49,7 +49,7 @@ static ssize_t gfs2_attr_store(struct kobject *kobj, struct attribute *attr,
 	return a->store ? a->store(sdp, buf, len) : len;
 }
 
-static struct sysfs_ops gfs2_attr_ops = {
+static const struct sysfs_ops gfs2_attr_ops = {
 	.show  = gfs2_attr_show,
 	.store = gfs2_attr_store,
 };
diff --git a/fs/ocfs2/cluster/masklog.c b/fs/ocfs2/cluster/masklog.c
index 1cd2934..880b5d2 100644
--- a/fs/ocfs2/cluster/masklog.c
+++ b/fs/ocfs2/cluster/masklog.c
@@ -135,7 +135,7 @@ static ssize_t mlog_store(struct kobject *obj, struct attribute *attr,
 	return mlog_mask_store(mlog_attr->mask, buf, count);
 }
 
-static struct sysfs_ops mlog_attr_ops = {
+static const struct sysfs_ops mlog_attr_ops = {
 	.show  = mlog_show,
 	.store = mlog_store,
 };
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index dc30d9e..9d561f1 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -53,7 +53,7 @@ struct sysfs_buffer {
 	size_t			count;
 	loff_t			pos;
 	char			* page;
-	struct sysfs_ops	* ops;
+	const struct sysfs_ops	* ops;
 	struct mutex		mutex;
 	int			needs_read_fill;
 	int			event;
@@ -75,7 +75,7 @@ static int fill_read_buffer(struct dentry * dentry, struct sysfs_buffer * buffer
 {
 	struct sysfs_dirent *attr_sd = dentry->d_fsdata;
 	struct kobject *kobj = attr_sd->s_parent->s_dir.kobj;
-	struct sysfs_ops * ops = buffer->ops;
+	const struct sysfs_ops * ops = buffer->ops;
 	int ret = 0;
 	ssize_t count;
 
@@ -199,7 +199,7 @@ flush_write_buffer(struct dentry * dentry, struct sysfs_buffer * buffer, size_t
 {
 	struct sysfs_dirent *attr_sd = dentry->d_fsdata;
 	struct kobject *kobj = attr_sd->s_parent->s_dir.kobj;
-	struct sysfs_ops * ops = buffer->ops;
+	const struct sysfs_ops * ops = buffer->ops;
 	int rc;
 
 	/* need attr_sd for attr and ops, its parent for kobj */
@@ -335,7 +335,7 @@ static int sysfs_open_file(struct inode *inode, struct file *file)
 	struct sysfs_dirent *attr_sd = file->f_path.dentry->d_fsdata;
 	struct kobject *kobj = attr_sd->s_parent->s_dir.kobj;
 	struct sysfs_buffer *buffer;
-	struct sysfs_ops *ops;
+	const struct sysfs_ops *ops;
 	int error = -EACCES;
 	char *p;
 
diff --git a/include/linux/kobject.h b/include/linux/kobject.h
index 58ae8e0..072cee4 100644
--- a/include/linux/kobject.h
+++ b/include/linux/kobject.h
@@ -106,7 +106,7 @@ extern char *kobject_get_path(struct kobject *kobj, gfp_t flag);
 
 struct kobj_type {
 	void (*release)(struct kobject *kobj);
-	struct sysfs_ops *sysfs_ops;
+	const struct sysfs_ops *sysfs_ops;
 	struct attribute **default_attrs;
 };
 
@@ -132,7 +132,7 @@ struct kobj_attribute {
 			 const char *buf, size_t count);
 };
 
-extern struct sysfs_ops kobj_sysfs_ops;
+extern const struct sysfs_ops kobj_sysfs_ops;
 
 /**
  * struct kset - a set of kobjects of a specific type, belonging to a specific subsystem.
diff --git a/kernel/params.c b/kernel/params.c
index cf1b691..53de0d8 100644
--- a/kernel/params.c
+++ b/kernel/params.c
@@ -723,7 +723,7 @@ static ssize_t module_attr_store(struct kobject *kobj,
 	return ret;
 }
 
-static struct sysfs_ops module_sysfs_ops = {
+static const struct sysfs_ops module_sysfs_ops = {
 	.show = module_attr_show,
 	.store = module_attr_store,
 };
diff --git a/lib/kobject.c b/lib/kobject.c
index b512b74..6567393 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -700,7 +700,7 @@ static ssize_t kobj_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-struct sysfs_ops kobj_sysfs_ops = {
+const struct sysfs_ops kobj_sysfs_ops = {
 	.show	= kobj_attr_show,
 	.store	= kobj_attr_store,
 };
diff --git a/mm/slub.c b/mm/slub.c
index 8d71aaf..0aa5ad6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4519,7 +4519,7 @@ static void kmem_cache_release(struct kobject *kobj)
 	kfree(s);
 }
 
-static struct sysfs_ops slab_sysfs_ops = {
+static const struct sysfs_ops slab_sysfs_ops = {
 	.show = slab_attr_show,
 	.store = slab_attr_store,
 };
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2114e45..c53bdd9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -254,7 +254,7 @@ extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
 
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
-extern struct sysfs_ops brport_sysfs_ops;
+extern const struct sysfs_ops brport_sysfs_ops;
 extern int br_sysfs_addif(struct net_bridge_port *p);
 
 /* br_sysfs_br.c */
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 820643a..ce77fb3 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -220,7 +220,7 @@ static ssize_t brport_store(struct kobject * kobj,
 	return ret;
 }
 
-struct sysfs_ops brport_sysfs_ops = {
+const struct sysfs_ops brport_sysfs_ops = {
 	.show = brport_show,
 	.store = brport_store,
 };
diff --git a/samples/kobject/kset-example.c b/samples/kobject/kset-example.c
index 45b7d56..19e828c 100644
--- a/samples/kobject/kset-example.c
+++ b/samples/kobject/kset-example.c
@@ -87,7 +87,7 @@ static ssize_t foo_attr_store(struct kobject *kobj,
 }
 
 /* Our custom sysfs_ops that we will associate with our ktype later on */
-static struct sysfs_ops foo_sysfs_ops = {
+static const struct sysfs_ops foo_sysfs_ops = {
 	.show = foo_attr_show,
 	.store = foo_attr_store,
 };
