From: Joe Perches <joe@perches.com>
Subject: [PATCH next] xen: Convert printks to pr_<level>
Date: Fri, 28 Jun 2013 03:21:41 -0700
Message-ID: <1372414901.2060.44.camel@joe-AO722>
References: <1372395469.2060.36.camel@joe-AO722>
	<20130628080250.GA16643@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, xen-devel@lists.xensource.com,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"virtualization@lists.osdl.org" <virtualization@lists.linux-foundation.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130628080250.GA16643@zion.uk.xensource.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Convert printks to pr_<level> (excludes printk(KERN_DEBUG...)
to be more consistent throughout the xen subsystem.

Add pr_fmt with KBUILD_MODNAME or "xen:" KBUILD_MODNAME
Coalesce formats and add missing word spaces
Add missing newlines
Align arguments and reflow to 80 columns
Remove DRV_NAME from formats as pr_fmt adds the same content

This does change some of the prefixes of these messages
but it also does make them more consistent.

Signed-off-by: Joe Perches <joe@perches.com>
---

On Fri, 2013-06-28 at 09:02 +0100, Wei Liu wrote:
> Do you also need to replace other printk occurences in xen-netback
> directory, say, interface.c and xenbus.c?

Well, I don't _need_ to but if you want it
this is what I suggest.

 drivers/xen/balloon.c                       |  6 +++--
 drivers/xen/cpu_hotplug.c                   |  6 +++--
 drivers/xen/events.c                        | 23 +++++++++---------
 drivers/xen/evtchn.c                        |  6 +++--
 drivers/xen/gntalloc.c                      |  6 +++--
 drivers/xen/gntdev.c                        |  8 ++++---
 drivers/xen/grant-table.c                   | 17 +++++++-------
 drivers/xen/manage.c                        | 23 +++++++++---------
 drivers/xen/mcelog.c                        | 36 +++++++++++------------------
 drivers/xen/pcpu.c                          | 12 +++++-----
 drivers/xen/privcmd.c                       |  4 +++-
 drivers/xen/swiotlb-xen.c                   | 12 ++++++----
 drivers/xen/tmem.c                          | 10 ++++----
 drivers/xen/xen-acpi-cpuhotplug.c           |  2 ++
 drivers/xen/xen-acpi-memhotplug.c           |  2 ++
 drivers/xen/xen-acpi-pad.c                  |  2 ++
 drivers/xen/xen-acpi-processor.c            | 25 ++++++++++----------
 drivers/xen/xen-balloon.c                   |  6 +++--
 drivers/xen/xen-pciback/conf_space_header.c | 16 ++++++-------
 drivers/xen/xen-pciback/pci_stub.c          | 25 +++++++++-----------
 drivers/xen/xen-pciback/pciback_ops.c       |  9 +++++---
 drivers/xen/xen-pciback/vpci.c              | 10 ++++----
 drivers/xen/xen-pciback/xenbus.c            |  8 ++++---
 drivers/xen/xen-selfballoon.c               | 11 ++++-----
 drivers/xen/xenbus/xenbus_comms.c           | 13 ++++++-----
 drivers/xen/xenbus/xenbus_dev_backend.c     |  4 +++-
 drivers/xen/xenbus/xenbus_dev_frontend.c    |  4 +++-
 drivers/xen/xenbus/xenbus_probe.c           | 30 +++++++++++-------------
 drivers/xen/xenbus/xenbus_probe_backend.c   |  8 ++++---
 drivers/xen/xenbus/xenbus_probe_frontend.c  | 35 ++++++++++++++--------------
 drivers/xen/xenbus/xenbus_xs.c              | 22 ++++++++----------
 drivers/xen/xencomm.c                       |  2 ++
 drivers/xen/xenfs/super.c                   |  4 +++-
 include/xen/hvm.h                           |  4 ++--
 34 files changed, 215 insertions(+), 196 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 08e9715..4e43c0e 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -36,6 +36,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/errno.h>
@@ -231,7 +233,7 @@ static enum bp_state reserve_additional_memory(long credit)
 	rc = add_memory(nid, hotplug_start_paddr, balloon_hotplug << PAGE_SHIFT);
 
 	if (rc) {
-		pr_info("xen_balloon: %s: add_memory() failed: %i\n", __func__, rc);
+		pr_info("%s: add_memory() failed: %i\n", __func__, rc);
 		return BP_EAGAIN;
 	}
 
@@ -582,7 +584,7 @@ static int __init balloon_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	pr_info("xen/balloon: Initialising balloon driver.\n");
+	pr_info("Initialising balloon driver\n");
 
 	balloon_stats.current_pages = xen_pv_domain()
 		? min(xen_start_info->nr_pages - xen_released_pages, max_pfn)
diff --git a/drivers/xen/cpu_hotplug.c b/drivers/xen/cpu_hotplug.c
index b0b87dd..cbb02af 100644
--- a/drivers/xen/cpu_hotplug.c
+++ b/drivers/xen/cpu_hotplug.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/notifier.h>
 
 #include <xen/xen.h>
@@ -32,7 +34,7 @@ static int vcpu_online(unsigned int cpu)
 	err = xenbus_scanf(XBT_NIL, dir, "availability", "%15s", state);
 	if (err != 1) {
 		if (!xen_initial_domain())
-			printk(KERN_ERR "XENBUS: Unable to read cpu state\n");
+			pr_err("Unable to read cpu state\n");
 		return err;
 	}
 
@@ -41,7 +43,7 @@ static int vcpu_online(unsigned int cpu)
 	else if (strcmp(state, "offline") == 0)
 		return 0;
 
-	printk(KERN_ERR "XENBUS: unknown state(%s) on CPU%d\n", state, cpu);
+	pr_err("unknown state(%s) on CPU%d\n", state, cpu);
 	return -EINVAL;
 }
 static void vcpu_hotplug(unsigned int cpu)
diff --git a/drivers/xen/events.c b/drivers/xen/events.c
index 7945f88..ddb9290 100644
--- a/drivers/xen/events.c
+++ b/drivers/xen/events.c
@@ -21,6 +21,8 @@
  * Jeremy Fitzhardinge <jeremy@xensource.com>, XenSource Inc, 2007
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/linkage.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
@@ -600,8 +602,7 @@ static unsigned int __startup_pirq(unsigned int irq)
 	rc = HYPERVISOR_event_channel_op(EVTCHNOP_bind_pirq, &bind_pirq);
 	if (rc != 0) {
 		if (!probing_irq(irq))
-			printk(KERN_INFO "Failed to obtain physical IRQ %d\n",
-			       irq);
+			pr_info("Failed to obtain physical IRQ %d\n", irq);
 		return 0;
 	}
 	evtchn = bind_pirq.port;
@@ -693,8 +694,8 @@ int xen_bind_pirq_gsi_to_irq(unsigned gsi,
 
 	irq = xen_irq_from_gsi(gsi);
 	if (irq != -1) {
-		printk(KERN_INFO "xen_map_pirq_gsi: returning irq %d for gsi %u\n",
-		       irq, gsi);
+		pr_info("%s: returning irq %d for gsi %u\n",
+			__func__, irq, gsi);
 		goto out;
 	}
 
@@ -812,10 +813,10 @@ int xen_destroy_irq(int irq)
 		 * (free_domain_pirqs).
 		 */
 		if ((rc == -ESRCH && info->u.pirq.domid != DOMID_SELF))
-			printk(KERN_INFO "domain %d does not have %d anymore\n",
+			pr_info("domain %d does not have %d anymore\n",
 				info->u.pirq.domid, info->u.pirq.pirq);
 		else if (rc) {
-			printk(KERN_WARNING "unmap irq failed %d\n", rc);
+			pr_warn("unmap irq failed %d\n", rc);
 			goto out;
 		}
 	}
@@ -1621,8 +1622,8 @@ static void restore_pirqs(void)
 
 		rc = HYPERVISOR_physdev_op(PHYSDEVOP_map_pirq, &map_irq);
 		if (rc) {
-			printk(KERN_WARNING "xen map irq failed gsi=%d irq=%d pirq=%d rc=%d\n",
-					gsi, irq, pirq, rc);
+			pr_warn("xen map irq failed gsi=%d irq=%d pirq=%d rc=%d\n",
+				gsi, irq, pirq, rc);
 			xen_free_irq(irq);
 			continue;
 		}
@@ -1844,13 +1845,11 @@ void xen_callback_vector(void)
 		callback_via = HVM_CALLBACK_VECTOR(HYPERVISOR_CALLBACK_VECTOR);
 		rc = xen_set_callback_via(callback_via);
 		if (rc) {
-			printk(KERN_ERR "Request for Xen HVM callback vector"
-					" failed.\n");
+			pr_err("Request for Xen HVM callback vector failed\n");
 			xen_have_vector_callback = 0;
 			return;
 		}
-		printk(KERN_INFO "Xen HVM callback vector for event delivery is "
-				"enabled\n");
+		pr_info("Xen HVM callback vector for event delivery is enabled\n");
 		/* in the restore case the vector has already been allocated */
 		if (!test_bit(HYPERVISOR_CALLBACK_VECTOR, used_vectors))
 			alloc_intr_gate(HYPERVISOR_CALLBACK_VECTOR,
diff --git a/drivers/xen/evtchn.c b/drivers/xen/evtchn.c
index 45c8efa..8feecf0 100644
--- a/drivers/xen/evtchn.c
+++ b/drivers/xen/evtchn.c
@@ -31,6 +31,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -547,11 +549,11 @@ static int __init evtchn_init(void)
 	/* Create '/dev/xen/evtchn'. */
 	err = misc_register(&evtchn_miscdev);
 	if (err != 0) {
-		printk(KERN_ERR "Could not register /dev/xen/evtchn\n");
+		pr_err("Could not register /dev/xen/evtchn\n");
 		return err;
 	}
 
-	printk(KERN_INFO "Event-channel device installed.\n");
+	pr_info("Event-channel device installed\n");
 
 	return 0;
 }
diff --git a/drivers/xen/gntalloc.c b/drivers/xen/gntalloc.c
index 4097987..787d179 100644
--- a/drivers/xen/gntalloc.c
+++ b/drivers/xen/gntalloc.c
@@ -48,6 +48,8 @@
  * grant operation.
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/atomic.h>
 #include <linux/module.h>
 #include <linux/miscdevice.h>
@@ -507,7 +509,7 @@ static int gntalloc_mmap(struct file *filp, struct vm_area_struct *vma)
 	int rv, i;
 
 	if (!(vma->vm_flags & VM_SHARED)) {
-		printk(KERN_ERR "%s: Mapping must be shared.\n", __func__);
+		pr_err("%s: Mapping must be shared\n", __func__);
 		return -EINVAL;
 	}
 
@@ -584,7 +586,7 @@ static int __init gntalloc_init(void)
 
 	err = misc_register(&gntalloc_miscdev);
 	if (err != 0) {
-		printk(KERN_ERR "Could not register misc gntalloc device\n");
+		pr_err("Could not register misc gntalloc device\n");
 		return err;
 	}
 
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 1112a267..938dcc1 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -19,6 +19,8 @@
 
 #undef DEBUG
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -760,7 +762,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 	if (use_ptemod && map->vma)
 		goto unlock_out;
 	if (use_ptemod && priv->mm != vma->vm_mm) {
-		printk(KERN_WARNING "Huh? Other mm?\n");
+		pr_warn("Huh? Other mm?\n");
 		goto unlock_out;
 	}
 
@@ -795,7 +797,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 					  vma->vm_end - vma->vm_start,
 					  find_grant_ptes, map);
 		if (err) {
-			printk(KERN_WARNING "find_grant_ptes() failure.\n");
+			pr_warn("find_grant_ptes() failure.\n");
 			goto out_put_map;
 		}
 	}
@@ -856,7 +858,7 @@ static int __init gntdev_init(void)
 
 	err = misc_register(&gntdev_miscdev);
 	if (err != 0) {
-		printk(KERN_ERR "Could not register gntdev device\n");
+		pr_err("Could not register gntdev device\n");
 		return err;
 	}
 	return 0;
diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index f4e067b..23533ae 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -31,6 +31,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
@@ -509,8 +511,7 @@ static void gnttab_handle_deferred(unsigned long unused)
 			entry = NULL;
 		} else {
 			if (!--entry->warn_delay)
-				pr_info("g.e. %#x still pending\n",
-					entry->ref);
+				pr_info("g.e. %#x still pending\n", entry->ref);
 			if (!first)
 				first = entry;
 		}
@@ -839,7 +840,7 @@ gnttab_retry_eagain_gop(unsigned int cmd, void *gop, int16_t *status,
 	} while ((*status == GNTST_eagain) && (delay < MAX_DELAY));
 
 	if (delay >= MAX_DELAY) {
-		printk(KERN_ERR "%s: %s eagain grant\n", func, current->comm);
+		pr_err("%s: %s eagain grant\n", func, current->comm);
 		*status = GNTST_bad_page;
 	}
 }
@@ -1069,8 +1070,8 @@ static int gnttab_map(unsigned int start_idx, unsigned int end_idx)
 
 			rc = HYPERVISOR_memory_op(XENMEM_add_to_physmap, &xatp);
 			if (rc != 0) {
-				printk(KERN_WARNING
-						"grant table add_to_physmap failed, err=%d\n", rc);
+				pr_warn("grant table add_to_physmap failed, err=%d\n",
+					rc);
 				break;
 			}
 		} while (i-- > start_idx);
@@ -1152,8 +1153,7 @@ static void gnttab_request_version(void)
 		grefs_per_grant_frame = PAGE_SIZE / sizeof(struct grant_entry_v1);
 		gnttab_interface = &gnttab_v1_ops;
 	}
-	printk(KERN_INFO "Grant tables using version %d layout.\n",
-		grant_table_version);
+	pr_info("Grant tables using version %d layout\n", grant_table_version);
 }
 
 /*
@@ -1208,8 +1208,7 @@ static int gnttab_setup(void)
 		gnttab_shared.addr = xen_remap(xen_hvm_resume_frames,
 						PAGE_SIZE * max_nr_gframes);
 		if (gnttab_shared.addr == NULL) {
-			printk(KERN_WARNING
-					"Failed to ioremap gnttab share frames!");
+			pr_warn("Failed to ioremap gnttab share frames!\n");
 			return -ENOMEM;
 		}
 	}
diff --git a/drivers/xen/manage.c b/drivers/xen/manage.c
index 412b96c..8680c48 100644
--- a/drivers/xen/manage.c
+++ b/drivers/xen/manage.c
@@ -1,6 +1,9 @@
 /*
  * Handle extern requests for shutdown, reboot and sysrq
  */
+
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/err.h>
 #include <linux/slab.h>
@@ -73,8 +76,7 @@ static int xen_suspend(void *data)
 
 	err = syscore_suspend();
 	if (err) {
-		printk(KERN_ERR "xen_suspend: system core suspend failed: %d\n",
-			err);
+		pr_err("%s: system core suspend failed: %d\n", __func__, err);
 		return err;
 	}
 
@@ -115,14 +117,14 @@ static void do_suspend(void)
 	   during suspend. */
 	err = freeze_processes();
 	if (err) {
-		printk(KERN_ERR "xen suspend: freeze failed %d\n", err);
+		pr_err("%s: freeze failed %d\n", __func__, err);
 		goto out;
 	}
 #endif
 
 	err = dpm_suspend_start(PMSG_FREEZE);
 	if (err) {
-		printk(KERN_ERR "xen suspend: dpm_suspend_start %d\n", err);
+		pr_err("%s: dpm_suspend_start %d\n", __func__, err);
 		goto out_thaw;
 	}
 
@@ -131,7 +133,7 @@ static void do_suspend(void)
 
 	err = dpm_suspend_end(PMSG_FREEZE);
 	if (err) {
-		printk(KERN_ERR "dpm_suspend_end failed: %d\n", err);
+		pr_err("dpm_suspend_end failed: %d\n", err);
 		si.cancelled = 0;
 		goto out_resume;
 	}
@@ -153,7 +155,7 @@ static void do_suspend(void)
 	dpm_resume_start(si.cancelled ? PMSG_THAW : PMSG_RESTORE);
 
 	if (err) {
-		printk(KERN_ERR "failed to start xen_suspend: %d\n", err);
+		pr_err("failed to start xen_suspend: %d\n", err);
 		si.cancelled = 1;
 	}
 
@@ -245,7 +247,7 @@ static void shutdown_handler(struct xenbus_watch *watch,
 	if (handler->cb) {
 		handler->cb();
 	} else {
-		printk(KERN_INFO "Ignoring shutdown request: %s\n", str);
+		pr_info("Ignoring shutdown request: %s\n", str);
 		shutting_down = SHUTDOWN_INVALID;
 	}
 
@@ -265,8 +267,7 @@ static void sysrq_handler(struct xenbus_watch *watch, const char **vec,
 	if (err)
 		return;
 	if (!xenbus_scanf(xbt, "control", "sysrq", "%c", &sysrq_key)) {
-		printk(KERN_ERR "Unable to read sysrq code in "
-		       "control/sysrq\n");
+		pr_err("Unable to read sysrq code in control/sysrq\n");
 		xenbus_transaction_end(xbt, 1);
 		return;
 	}
@@ -299,14 +300,14 @@ static int setup_shutdown_watcher(void)
 
 	err = register_xenbus_watch(&shutdown_watch);
 	if (err) {
-		printk(KERN_ERR "Failed to set shutdown watcher\n");
+		pr_err("Failed to set shutdown watcher\n");
 		return err;
 	}
 
 #ifdef CONFIG_MAGIC_SYSRQ
 	err = register_xenbus_watch(&sysrq_watch);
 	if (err) {
-		printk(KERN_ERR "Failed to set sysrq watcher\n");
+		pr_err("Failed to set sysrq watcher\n");
 		return err;
 	}
 #endif
diff --git a/drivers/xen/mcelog.c b/drivers/xen/mcelog.c
index 8feee08..6ab6a79 100644
--- a/drivers/xen/mcelog.c
+++ b/drivers/xen/mcelog.c
@@ -32,6 +32,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) "xen_mcelog: " fmt
+
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -51,8 +53,6 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/hypervisor.h>
 
-#define XEN_MCELOG "xen_mcelog: "
-
 static struct mc_info g_mi;
 static struct mcinfo_logical_cpu *g_physinfo;
 static uint32_t ncpus;
@@ -227,7 +227,7 @@ static int convert_log(struct mc_info *mi)
 	mic = NULL;
 	x86_mcinfo_lookup(&mic, mi, MC_TYPE_GLOBAL);
 	if (unlikely(!mic)) {
-		pr_warning(XEN_MCELOG "Failed to find global error info\n");
+		pr_warn("Failed to find global error info\n");
 		return -ENODEV;
 	}
 
@@ -241,8 +241,7 @@ static int convert_log(struct mc_info *mi)
 		if (g_physinfo[i].mc_apicid == m.apicid)
 			break;
 	if (unlikely(i == ncpus)) {
-		pr_warning(XEN_MCELOG "Failed to match cpu with apicid %d\n",
-			   m.apicid);
+		pr_warn("Failed to match cpu with apicid %d\n", m.apicid);
 		return -ENODEV;
 	}
 
@@ -254,7 +253,7 @@ static int convert_log(struct mc_info *mi)
 	mic = NULL;
 	x86_mcinfo_lookup(&mic, mi, MC_TYPE_BANK);
 	if (unlikely(!mic)) {
-		pr_warning(XEN_MCELOG "Fail to find bank error info\n");
+		pr_warn("Fail to find bank error info\n");
 		return -ENODEV;
 	}
 
@@ -295,9 +294,8 @@ static int mc_queue_handle(uint32_t flags)
 		mc_op.u.mc_fetch.flags = flags;
 		ret = HYPERVISOR_mca(&mc_op);
 		if (ret) {
-			pr_err(XEN_MCELOG "Failed to fetch %s error log\n",
-			       (flags == XEN_MC_URGENT) ?
-			       "urgnet" : "nonurgent");
+			pr_err("Failed to fetch %surgent error log\n",
+			       flags == XEN_MC_URGENT ? "" : "non");
 			break;
 		}
 
@@ -307,15 +305,12 @@ static int mc_queue_handle(uint32_t flags)
 		else {
 			ret = convert_log(&g_mi);
 			if (ret)
-				pr_warning(XEN_MCELOG
-					   "Failed to convert this error log, "
-					   "continue acking it anyway\n");
+				pr_warn("Failed to convert this error log, continue acking it anyway\n");
 
 			mc_op.u.mc_fetch.flags = flags | XEN_MC_ACK;
 			ret = HYPERVISOR_mca(&mc_op);
 			if (ret) {
-				pr_err(XEN_MCELOG
-				       "Failed to ack previous error log\n");
+				pr_err("Failed to ack previous error log\n");
 				break;
 			}
 		}
@@ -334,15 +329,12 @@ static void xen_mce_work_fn(struct work_struct *work)
 	/* urgent mc_info */
 	err = mc_queue_handle(XEN_MC_URGENT);
 	if (err)
-		pr_err(XEN_MCELOG
-		       "Failed to handle urgent mc_info queue, "
-		       "continue handling nonurgent mc_info queue anyway.\n");
+		pr_err("Failed to handle urgent mc_info queue, continue handling nonurgent mc_info queue anyway\n");
 
 	/* nonurgent mc_info */
 	err = mc_queue_handle(XEN_MC_NONURGENT);
 	if (err)
-		pr_err(XEN_MCELOG
-		       "Failed to handle nonurgent mc_info queue.\n");
+		pr_err("Failed to handle nonurgent mc_info queue\n");
 
 	/* wake processes polling /dev/mcelog */
 	wake_up_interruptible(&xen_mce_chrdev_wait);
@@ -370,7 +362,7 @@ static int bind_virq_for_mce(void)
 	set_xen_guest_handle(mc_op.u.mc_physcpuinfo.info, g_physinfo);
 	ret = HYPERVISOR_mca(&mc_op);
 	if (ret) {
-		pr_err(XEN_MCELOG "Failed to get CPU numbers\n");
+		pr_err("Failed to get CPU numbers\n");
 		return ret;
 	}
 
@@ -383,7 +375,7 @@ static int bind_virq_for_mce(void)
 	set_xen_guest_handle(mc_op.u.mc_physcpuinfo.info, g_physinfo);
 	ret = HYPERVISOR_mca(&mc_op);
 	if (ret) {
-		pr_err(XEN_MCELOG "Failed to get CPU info\n");
+		pr_err("Failed to get CPU info\n");
 		kfree(g_physinfo);
 		return ret;
 	}
@@ -391,7 +383,7 @@ static int bind_virq_for_mce(void)
 	ret  = bind_virq_to_irqhandler(VIRQ_MCA, 0,
 				       xen_mce_interrupt, 0, "mce", NULL);
 	if (ret < 0) {
-		pr_err(XEN_MCELOG "Failed to bind virq\n");
+		pr_err("Failed to bind virq\n");
 		kfree(g_physinfo);
 		return ret;
 	}
diff --git a/drivers/xen/pcpu.c b/drivers/xen/pcpu.c
index 6536d5a..79e1dff 100644
--- a/drivers/xen/pcpu.c
+++ b/drivers/xen/pcpu.c
@@ -31,6 +31,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) "xen_cpu: " fmt
+
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
 #include <linux/cpu.h>
@@ -44,7 +46,6 @@
 #include <asm/xen/hypervisor.h>
 #include <asm/xen/hypercall.h>
 
-#define XEN_PCPU "xen_cpu: "
 
 /*
  * @cpu_id: Xen physical cpu logic number
@@ -242,8 +243,7 @@ static struct pcpu *create_and_register_pcpu(struct xenpf_pcpuinfo *info)
 
 	err = register_pcpu(pcpu);
 	if (err) {
-		pr_warning(XEN_PCPU "Failed to register pcpu%u\n",
-			   info->xen_cpuid);
+		pr_warn("Failed to register pcpu%u\n", info->xen_cpuid);
 		return ERR_PTR(-ENOENT);
 	}
 
@@ -378,19 +378,19 @@ static int __init xen_pcpu_init(void)
 				      xen_pcpu_interrupt, 0,
 				      "xen-pcpu", NULL);
 	if (irq < 0) {
-		pr_warning(XEN_PCPU "Failed to bind pcpu virq\n");
+		pr_warn("Failed to bind pcpu virq\n");
 		return irq;
 	}
 
 	ret = subsys_system_register(&xen_pcpu_subsys, NULL);
 	if (ret) {
-		pr_warning(XEN_PCPU "Failed to register pcpu subsys\n");
+		pr_warn("Failed to register pcpu subsys\n");
 		goto err1;
 	}
 
 	ret = xen_sync_pcpus();
 	if (ret) {
-		pr_warning(XEN_PCPU "Failed to sync pcpu info\n");
+		pr_warn("Failed to sync pcpu info\n");
 		goto err2;
 	}
 
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 2cfc24d..f8e5dd7 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -6,6 +6,8 @@
  * Copyright (c) 2002-2004, K A Fraser, B Dragovic
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/sched.h>
@@ -565,7 +567,7 @@ static int __init privcmd_init(void)
 
 	err = misc_register(&privcmd_dev);
 	if (err != 0) {
-		printk(KERN_ERR "Could not register Xen privcmd device\n");
+		pr_err("Could not register Xen privcmd device\n");
 		return err;
 	}
 	return 0;
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 1d94316..aadffcf 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -33,6 +33,8 @@
  *
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/bootmem.h>
 #include <linux/dma-mapping.h>
 #include <linux/export.h>
@@ -202,8 +204,8 @@ retry:
 			order--;
 		}
 		if (order != get_order(bytes)) {
-			pr_warn("Warning: only able to allocate %ld MB "
-				"for software IO TLB\n", (PAGE_SIZE << order) >> 20);
+			pr_warn("Warning: only able to allocate %ld MB for software IO TLB\n",
+				(PAGE_SIZE << order) >> 20);
 			xen_io_tlb_nslabs = SLABS_PER_PAGE << order;
 			bytes = xen_io_tlb_nslabs << IO_TLB_SHIFT;
 		}
@@ -242,11 +244,11 @@ error:
 	if (repeat--) {
 		xen_io_tlb_nslabs = max(1024UL, /* Min is 2MB */
 					(xen_io_tlb_nslabs >> 1));
-		printk(KERN_INFO "Xen-SWIOTLB: Lowering to %luMB\n",
-		      (xen_io_tlb_nslabs << IO_TLB_SHIFT) >> 20);
+		pr_info("Lowering to %luMB\n",
+			(xen_io_tlb_nslabs << IO_TLB_SHIFT) >> 20);
 		goto retry;
 	}
-	pr_err("%s (rc:%d)", xen_swiotlb_error(m_ret), rc);
+	pr_err("%s (rc:%d)\n", xen_swiotlb_error(m_ret), rc);
 	if (early)
 		panic("%s (rc:%d)", xen_swiotlb_error(m_ret), rc);
 	else
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 0f0493c..83b5c53 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -5,6 +5,8 @@
  * Author: Dan Magenheimer
  */
 
+#define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -388,8 +390,8 @@ static int xen_tmem_init(void)
 				return PTR_ERR(old_ops);
 			s = " (WARNING: frontswap_ops overridden)";
 		}
-		printk(KERN_INFO "frontswap enabled, RAM provided by "
-				 "Xen Transcendent Memory%s\n", s);
+		pr_info("frontswap enabled, RAM provided by Xen Transcendent Memory%s\n",
+			s);
 	}
 #endif
 #ifdef CONFIG_CLEANCACHE
@@ -400,8 +402,8 @@ static int xen_tmem_init(void)
 			cleancache_register_ops(&tmem_cleancache_ops);
 		if (old_ops)
 			s = " (WARNING: cleancache_ops overridden)";
-		printk(KERN_INFO "cleancache enabled, RAM provided by "
-				 "Xen Transcendent Memory%s\n", s);
+		pr_info("cleancache enabled, RAM provided by Xen Transcendent Memory%s\n",
+			s);
 	}
 #endif
 #ifdef CONFIG_XEN_SELFBALLOONING
diff --git a/drivers/xen/xen-acpi-cpuhotplug.c b/drivers/xen/xen-acpi-cpuhotplug.c
index b7d5d95..8dae6c1 100644
--- a/drivers/xen/xen-acpi-cpuhotplug.c
+++ b/drivers/xen/xen-acpi-cpuhotplug.c
@@ -15,6 +15,8 @@
  * details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
diff --git a/drivers/xen/xen-acpi-memhotplug.c b/drivers/xen/xen-acpi-memhotplug.c
index faef5b3..9083f1e 100644
--- a/drivers/xen/xen-acpi-memhotplug.c
+++ b/drivers/xen/xen-acpi-memhotplug.c
@@ -15,6 +15,8 @@
  * details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
diff --git a/drivers/xen/xen-acpi-pad.c b/drivers/xen/xen-acpi-pad.c
index c763479..59708fd 100644
--- a/drivers/xen/xen-acpi-pad.c
+++ b/drivers/xen/xen-acpi-pad.c
@@ -14,6 +14,8 @@
  * more details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <acpi/acpi_bus.h>
diff --git a/drivers/xen/xen-acpi-processor.c b/drivers/xen/xen-acpi-processor.c
index 8abd7d5..13bc6c3 100644
--- a/drivers/xen/xen-acpi-processor.c
+++ b/drivers/xen/xen-acpi-processor.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/cpumask.h>
 #include <linux/cpufreq.h>
 #include <linux/freezer.h>
@@ -34,8 +36,6 @@
 #include <xen/interface/platform.h>
 #include <asm/xen/hypercall.h>
 
-#define DRV_NAME "xen-acpi-processor: "
-
 static int no_hypercall;
 MODULE_PARM_DESC(off, "Inhibit the hypercall.");
 module_param_named(off, no_hypercall, int, 0400);
@@ -104,7 +104,7 @@ static int push_cxx_to_hypervisor(struct acpi_processor *_pr)
 		set_xen_guest_handle(dst_cx->dp, NULL);
 	}
 	if (!ok) {
-		pr_debug(DRV_NAME "No _Cx for ACPI CPU %u\n", _pr->acpi_id);
+		pr_debug("No _Cx for ACPI CPU %u\n", _pr->acpi_id);
 		kfree(dst_cx_states);
 		return -EINVAL;
 	}
@@ -133,7 +133,7 @@ static int push_cxx_to_hypervisor(struct acpi_processor *_pr)
 		/* EINVAL means the ACPI ID is incorrect - meaning the ACPI
 		 * table is referencing a non-existing CPU - which can happen
 		 * with broken ACPI tables. */
-		pr_err(DRV_NAME "(CX): Hypervisor error (%d) for ACPI CPU%u\n",
+		pr_err("(CX): Hypervisor error (%d) for ACPI CPU%u\n",
 		       ret, _pr->acpi_id);
 
 	kfree(dst_cx_states);
@@ -239,7 +239,7 @@ static int push_pxx_to_hypervisor(struct acpi_processor *_pr)
 		dst_perf->flags |= XEN_PX_PSD;
 
 	if (dst_perf->flags != (XEN_PX_PSD | XEN_PX_PSS | XEN_PX_PCT | XEN_PX_PPC)) {
-		pr_warn(DRV_NAME "ACPI CPU%u missing some P-state data (%x), skipping.\n",
+		pr_warn("ACPI CPU%u missing some P-state data (%x), skipping\n",
 			_pr->acpi_id, dst_perf->flags);
 		ret = -ENODEV;
 		goto err_free;
@@ -265,8 +265,8 @@ static int push_pxx_to_hypervisor(struct acpi_processor *_pr)
 		/* EINVAL means the ACPI ID is incorrect - meaning the ACPI
 		 * table is referencing a non-existing CPU - which can happen
 		 * with broken ACPI tables. */
-		pr_warn(DRV_NAME "(_PXX): Hypervisor error (%d) for ACPI CPU%u\n",
-		       ret, _pr->acpi_id);
+		pr_warn("(_PXX): Hypervisor error (%d) for ACPI CPU%u\n",
+			ret, _pr->acpi_id);
 err_free:
 	if (!IS_ERR_OR_NULL(dst_states))
 		kfree(dst_states);
@@ -318,7 +318,7 @@ static unsigned int __init get_max_acpi_id(void)
 		max_acpi_id = max(info->acpi_id, max_acpi_id);
 	}
 	max_acpi_id *= 2; /* Slack for CPU hotplug support. */
-	pr_debug(DRV_NAME "Max ACPI ID: %u\n", max_acpi_id);
+	pr_debug("Max ACPI ID: %u\n", max_acpi_id);
 	return max_acpi_id;
 }
 /*
@@ -365,15 +365,14 @@ read_acpi_id(acpi_handle handle, u32 lvl, void *context, void **rv)
 	/* There are more ACPI Processor objects than in x2APIC or MADT.
 	 * This can happen with incorrect ACPI SSDT declerations. */
 	if (acpi_id > nr_acpi_bits) {
-		pr_debug(DRV_NAME "We only have %u, trying to set %u\n",
+		pr_debug("We only have %u, trying to set %u\n",
 			 nr_acpi_bits, acpi_id);
 		return AE_OK;
 	}
 	/* OK, There is a ACPI Processor object */
 	__set_bit(acpi_id, acpi_id_present);
 
-	pr_debug(DRV_NAME "ACPI CPU%u w/ PBLK:0x%lx\n", acpi_id,
-		 (unsigned long)pblk);
+	pr_debug("ACPI CPU%u w/ PBLK:0x%lx\n", acpi_id, (unsigned long)pblk);
 
 	status = acpi_evaluate_object(handle, "_CST", NULL, &buffer);
 	if (ACPI_FAILURE(status)) {
@@ -476,7 +475,7 @@ static int xen_upload_processor_pm_data(void)
 	unsigned int i;
 	int rc = 0;
 
-	pr_info(DRV_NAME "Uploading Xen processor PM info\n");
+	pr_info("Uploading Xen processor PM info\n");
 
 	for_each_possible_cpu(i) {
 		struct acpi_processor *_pr;
@@ -523,7 +522,7 @@ static int __init xen_acpi_processor_init(void)
 
 	acpi_perf_data = alloc_percpu(struct acpi_processor_performance);
 	if (!acpi_perf_data) {
-		pr_debug(DRV_NAME "Memory allocation error for acpi_perf_data.\n");
+		pr_debug("Memory allocation error for acpi_perf_data\n");
 		kfree(acpi_ids_done);
 		return -ENOMEM;
 	}
diff --git a/drivers/xen/xen-balloon.c b/drivers/xen/xen-balloon.c
index 8f37e23..e555845 100644
--- a/drivers/xen/xen-balloon.c
+++ b/drivers/xen/xen-balloon.c
@@ -30,6 +30,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/capability.h>
@@ -81,7 +83,7 @@ static int balloon_init_watcher(struct notifier_block *notifier,
 
 	err = register_xenbus_watch(&target_watch);
 	if (err)
-		printk(KERN_ERR "Failed to set balloon watcher\n");
+		pr_err("Failed to set balloon watcher\n");
 
 	return NOTIFY_DONE;
 }
@@ -95,7 +97,7 @@ static int __init balloon_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	pr_info("xen-balloon: Initialising balloon driver.\n");
+	pr_info("Initialising balloon driver\n");
 
 	register_balloon(&balloon_dev);
 
diff --git a/drivers/xen/xen-pciback/conf_space_header.c b/drivers/xen/xen-pciback/conf_space_header.c
index 3daf862..c5ee825 100644
--- a/drivers/xen/xen-pciback/conf_space_header.c
+++ b/drivers/xen/xen-pciback/conf_space_header.c
@@ -4,6 +4,8 @@
  * Author: Ryan Wilson <hap9@epoch.ncsc.mil>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/pci.h>
 #include "pciback.h"
@@ -75,10 +77,8 @@ static int command_write(struct pci_dev *dev, int offset, u16 value, void *data)
 			       pci_name(dev));
 		err = pci_set_mwi(dev);
 		if (err) {
-			printk(KERN_WARNING
-			       DRV_NAME ": %s: cannot enable "
-			       "memory-write-invalidate (%d)\n",
-			       pci_name(dev), err);
+			pr_warn("%s: cannot enable memory-write-invalidate (%d)\n",
+				pci_name(dev), err);
 			value &= ~PCI_COMMAND_INVALIDATE;
 		}
 	}
@@ -91,7 +91,7 @@ static int rom_write(struct pci_dev *dev, int offset, u32 value, void *data)
 	struct pci_bar_info *bar = data;
 
 	if (unlikely(!bar)) {
-		printk(KERN_WARNING DRV_NAME ": driver data not found for %s\n",
+		pr_warn(DRV_NAME ": driver data not found for %s\n",
 		       pci_name(dev));
 		return XEN_PCI_ERR_op_failed;
 	}
@@ -125,7 +125,7 @@ static int bar_write(struct pci_dev *dev, int offset, u32 value, void *data)
 	struct pci_bar_info *bar = data;
 
 	if (unlikely(!bar)) {
-		printk(KERN_WARNING DRV_NAME ": driver data not found for %s\n",
+		pr_warn(DRV_NAME ": driver data not found for %s\n",
 		       pci_name(dev));
 		return XEN_PCI_ERR_op_failed;
 	}
@@ -153,7 +153,7 @@ static int bar_read(struct pci_dev *dev, int offset, u32 * value, void *data)
 	struct pci_bar_info *bar = data;
 
 	if (unlikely(!bar)) {
-		printk(KERN_WARNING DRV_NAME ": driver data not found for %s\n",
+		pr_warn(DRV_NAME ": driver data not found for %s\n",
 		       pci_name(dev));
 		return XEN_PCI_ERR_op_failed;
 	}
@@ -375,7 +375,7 @@ int xen_pcibk_config_header_add_fields(struct pci_dev *dev)
 
 	default:
 		err = -EINVAL;
-		printk(KERN_ERR DRV_NAME ": %s: Unsupported header type %d!\n",
+		pr_err("%s: Unsupported header type %d!\n",
 		       pci_name(dev), dev->hdr_type);
 		break;
 	}
diff --git a/drivers/xen/xen-pciback/pci_stub.c b/drivers/xen/xen-pciback/pci_stub.c
index 0020899..62fcd48 100644
--- a/drivers/xen/xen-pciback/pci_stub.c
+++ b/drivers/xen/xen-pciback/pci_stub.c
@@ -4,6 +4,9 @@
  * Ryan Wilson <hap9@epoch.ncsc.mil>
  * Chris Bookholt <hap10@epoch.ncsc.mil>
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/rwsem.h>
@@ -425,8 +428,6 @@ static int __init pcistub_init_devices_late(void)
 	unsigned long flags;
 	int err = 0;
 
-	pr_debug(DRV_NAME ": pcistub_init_devices_late\n");
-
 	spin_lock_irqsave(&pcistub_devices_lock, flags);
 
 	while (!list_empty(&seized_devices)) {
@@ -544,15 +545,11 @@ static void pcistub_remove(struct pci_dev *dev)
 			found_psdev->pdev);
 
 		if (found_psdev->pdev) {
-			printk(KERN_WARNING DRV_NAME ": ****** removing device "
-			       "%s while still in-use! ******\n",
+			pr_warn("****** removing device %s while still in-use! ******\n",
 			       pci_name(found_psdev->dev));
-			printk(KERN_WARNING DRV_NAME ": ****** driver domain may"
-			       " still access this device's i/o resources!\n");
-			printk(KERN_WARNING DRV_NAME ": ****** shutdown driver "
-			       "domain before binding device\n");
-			printk(KERN_WARNING DRV_NAME ": ****** to other drivers "
-			       "or domains\n");
+			pr_warn("****** driver domain may still access this device's i/o resources!\n");
+			pr_warn("****** shutdown driver domain before binding device\n");
+			pr_warn("****** to other drivers or domains\n");
 
 			xen_pcibk_release_pci_dev(found_psdev->pdev,
 						found_psdev->dev);
@@ -1018,7 +1015,7 @@ static int pcistub_device_id_add(int domain, int bus, int slot, int func)
 	pci_dev_id->bus = bus;
 	pci_dev_id->devfn = devfn;
 
-	pr_debug(DRV_NAME ": wants to seize %04x:%02x:%02x.%d\n",
+	pr_debug("wants to seize %04x:%02x:%02x.%d\n",
 		 domain, bus, slot, func);
 
 	spin_lock_irqsave(&device_ids_lock, flags);
@@ -1048,8 +1045,8 @@ static int pcistub_device_id_remove(int domain, int bus, int slot, int func)
 
 			err = 0;
 
-			pr_debug(DRV_NAME ": removed %04x:%02x:%02x.%d from "
-				 "seize list\n", domain, bus, slot, func);
+			pr_debug("removed %04x:%02x:%02x.%d from seize list\n",
+				 domain, bus, slot, func);
 		}
 	}
 	spin_unlock_irqrestore(&device_ids_lock, flags);
@@ -1474,7 +1471,7 @@ out:
 	return err;
 
 parse_error:
-	printk(KERN_ERR DRV_NAME ": Error parsing pci_devs_to_hide at \"%s\"\n",
+	pr_err("Error parsing pci_devs_to_hide at \"%s\"\n",
 	       pci_devs_to_hide + pos);
 	return -EINVAL;
 }
diff --git a/drivers/xen/xen-pciback/pciback_ops.c b/drivers/xen/xen-pciback/pciback_ops.c
index b98cf0c..64eb0cd 100644
--- a/drivers/xen/xen-pciback/pciback_ops.c
+++ b/drivers/xen/xen-pciback/pciback_ops.c
@@ -3,6 +3,9 @@
  *
  *   Author: Ryan Wilson <hap9@epoch.ncsc.mil>
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/wait.h>
 #include <linux/bitops.h>
@@ -144,7 +147,7 @@ int xen_pcibk_enable_msi(struct xen_pcibk_device *pdev,
 	status = pci_enable_msi(dev);
 
 	if (status) {
-		pr_warn_ratelimited(DRV_NAME ": %s: error enabling MSI for guest %u: err %d\n",
+		pr_warn_ratelimited("%s: error enabling MSI for guest %u: err %d\n",
 				    pci_name(dev), pdev->xdev->otherend_id,
 				    status);
 		op->value = 0;
@@ -225,7 +228,7 @@ int xen_pcibk_enable_msix(struct xen_pcibk_device *pdev,
 						op->msix_entries[i].vector);
 		}
 	} else
-		pr_warn_ratelimited(DRV_NAME ": %s: error enabling MSI-X for guest %u: err %d!\n",
+		pr_warn_ratelimited("%s: error enabling MSI-X for guest %u: err %d!\n",
 				    pci_name(dev), pdev->xdev->otherend_id,
 				    result);
 	kfree(entries);
@@ -372,7 +375,7 @@ static irqreturn_t xen_pcibk_guest_interrupt(int irq, void *dev_id)
 		dev_data->handled++;
 		if ((dev_data->handled % 1000) == 0) {
 			if (xen_test_irq_shared(irq)) {
-				printk(KERN_INFO "%s IRQ line is not shared "
+				pr_info("%s IRQ line is not shared "
 					"with other domains. Turning ISR off\n",
 					 dev_data->irq_name);
 				dev_data->ack_intr = 0;
diff --git a/drivers/xen/xen-pciback/vpci.c b/drivers/xen/xen-pciback/vpci.c
index 0f478ac..3165ce3 100644
--- a/drivers/xen/xen-pciback/vpci.c
+++ b/drivers/xen/xen-pciback/vpci.c
@@ -5,6 +5,8 @@
  *   Author: Ryan Wilson <hap9@epoch.ncsc.mil>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
@@ -102,8 +104,7 @@ static int __xen_pcibk_add_pci_dev(struct xen_pcibk_device *pdev,
 				       struct pci_dev_entry, list);
 
 			if (match_slot(dev, t->dev)) {
-				pr_info(DRV_NAME ": vpci: %s: "
-					"assign to virtual slot %d func %d\n",
+				pr_info("vpci: %s: assign to virtual slot %d func %d\n",
 					pci_name(dev), slot,
 					PCI_FUNC(dev->devfn));
 				list_add_tail(&dev_entry->list,
@@ -117,9 +118,8 @@ static int __xen_pcibk_add_pci_dev(struct xen_pcibk_device *pdev,
 	/* Assign to a new slot on the virtual PCI bus */
 	for (slot = 0; slot < PCI_SLOT_MAX; slot++) {
 		if (list_empty(&vpci_dev->dev_list[slot])) {
-			printk(KERN_INFO DRV_NAME
-			       ": vpci: %s: assign to virtual slot %d\n",
-			       pci_name(dev), slot);
+			pr_info("vpci: %s: assign to virtual slot %d\n",
+				pci_name(dev), slot);
 			list_add_tail(&dev_entry->list,
 				      &vpci_dev->dev_list[slot]);
 			func = dev->is_virtfn ? 0 : PCI_FUNC(dev->devfn);
diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
index 64b11f9..a9ed867 100644
--- a/drivers/xen/xen-pciback/xenbus.c
+++ b/drivers/xen/xen-pciback/xenbus.c
@@ -3,6 +3,9 @@
  *
  *   Author: Ryan Wilson <hap9@epoch.ncsc.mil>
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/list.h>
@@ -723,14 +726,13 @@ int __init xen_pcibk_xenbus_register(void)
 {
 	xen_pcibk_wq = create_workqueue("xen_pciback_workqueue");
 	if (!xen_pcibk_wq) {
-		printk(KERN_ERR "%s: create"
-			"xen_pciback_workqueue failed\n", __func__);
+		pr_err("%s: create xen_pciback_workqueue failed\n", __func__);
 		return -EFAULT;
 	}
 	xen_pcibk_backend = &xen_pcibk_vpci_backend;
 	if (passthrough)
 		xen_pcibk_backend = &xen_pcibk_passthrough_backend;
-	pr_info(DRV_NAME ": backend is %s\n", xen_pcibk_backend->name);
+	pr_info("backend is %s\n", xen_pcibk_backend->name);
 	return xenbus_register_backend(&xen_pcibk_driver);
 }
 
diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index f70984a8..02817a8 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -64,6 +64,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/bootmem.h>
 #include <linux/swap.h>
@@ -510,22 +512,19 @@ int xen_selfballoon_init(bool use_selfballooning, bool use_frontswap_selfshrink)
 		return -ENODEV;
 
 	if (xen_initial_domain()) {
-		pr_info("xen/balloon: Xen selfballooning driver "
-				"disabled for domain0.\n");
+		pr_info("Xen selfballooning driver disabled for domain0\n");
 		return -ENODEV;
 	}
 
 	xen_selfballooning_enabled = tmem_enabled && use_selfballooning;
 	if (xen_selfballooning_enabled) {
-		pr_info("xen/balloon: Initializing Xen "
-					"selfballooning driver.\n");
+		pr_info("Initializing Xen selfballooning driver\n");
 		enable = true;
 	}
 #ifdef CONFIG_FRONTSWAP
 	frontswap_selfshrinking = tmem_enabled && use_frontswap_selfshrink;
 	if (frontswap_selfshrinking) {
-		pr_info("xen/balloon: Initializing frontswap "
-					"selfshrinking driver.\n");
+		pr_info("Initializing frontswap selfshrinking driver\n");
 		enable = true;
 	}
 #endif
diff --git a/drivers/xen/xenbus/xenbus_comms.c b/drivers/xen/xenbus/xenbus_comms.c
index c5aa55c..fdb0f33 100644
--- a/drivers/xen/xenbus/xenbus_comms.c
+++ b/drivers/xen/xenbus/xenbus_comms.c
@@ -30,6 +30,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/wait.h>
 #include <linux/interrupt.h>
 #include <linux/sched.h>
@@ -205,13 +207,12 @@ int xb_init_comms(void)
 	struct xenstore_domain_interface *intf = xen_store_interface;
 
 	if (intf->req_prod != intf->req_cons)
-		printk(KERN_ERR "XENBUS request ring is not quiescent "
-		       "(%08x:%08x)!\n", intf->req_cons, intf->req_prod);
+		pr_err("request ring is not quiescent (%08x:%08x)!\n",
+		       intf->req_cons, intf->req_prod);
 
 	if (intf->rsp_prod != intf->rsp_cons) {
-		printk(KERN_WARNING "XENBUS response ring is not quiescent "
-		       "(%08x:%08x): fixing up\n",
-		       intf->rsp_cons, intf->rsp_prod);
+		pr_warn("response ring is not quiescent (%08x:%08x): fixing up\n",
+			intf->rsp_cons, intf->rsp_prod);
 		/* breaks kdump */
 		if (!reset_devices)
 			intf->rsp_cons = intf->rsp_prod;
@@ -225,7 +226,7 @@ int xb_init_comms(void)
 		err = bind_evtchn_to_irqhandler(xen_store_evtchn, wake_waiting,
 						0, "xenbus", &xb_waitq);
 		if (err < 0) {
-			printk(KERN_ERR "XENBUS request irq failed %i\n", err);
+			pr_err("request irq failed %i\n", err);
 			return err;
 		}
 
diff --git a/drivers/xen/xenbus/xenbus_dev_backend.c b/drivers/xen/xenbus/xenbus_dev_backend.c
index a6f42fc0..b17707e 100644
--- a/drivers/xen/xenbus/xenbus_dev_backend.c
+++ b/drivers/xen/xenbus/xenbus_dev_backend.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/mm.h>
@@ -127,7 +129,7 @@ static int __init xenbus_backend_init(void)
 
 	err = misc_register(&xenbus_backend_dev);
 	if (err)
-		printk(KERN_ERR "Could not register xenbus backend device\n");
+		pr_err("Could not register xenbus backend device\n");
 	return err;
 }
 
diff --git a/drivers/xen/xenbus/xenbus_dev_frontend.c b/drivers/xen/xenbus/xenbus_dev_frontend.c
index ac72702..85534ea 100644
--- a/drivers/xen/xenbus/xenbus_dev_frontend.c
+++ b/drivers/xen/xenbus/xenbus_dev_frontend.c
@@ -35,6 +35,8 @@
  *                              Turned xenfs into a loadable module.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/uio.h>
@@ -616,7 +618,7 @@ static int __init xenbus_init(void)
 
 	err = misc_register(&xenbus_dev);
 	if (err)
-		printk(KERN_ERR "Could not register xenbus frontend device\n");
+		pr_err("Could not register xenbus frontend device\n");
 	return err;
 }
 
diff --git a/drivers/xen/xenbus/xenbus_probe.c b/drivers/xen/xenbus/xenbus_probe.c
index 8c9db16..38e92b7 100644
--- a/drivers/xen/xenbus/xenbus_probe.c
+++ b/drivers/xen/xenbus/xenbus_probe.c
@@ -30,6 +30,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DPRINTK(fmt, args...)				\
 	pr_debug("xenbus_probe (%s:%d) " fmt ".\n",	\
 		 __func__, __LINE__, ##args)
@@ -280,15 +282,15 @@ void xenbus_dev_shutdown(struct device *_dev)
 
 	get_device(&dev->dev);
 	if (dev->state != XenbusStateConnected) {
-		printk(KERN_INFO "%s: %s: %s != Connected, skipping\n", __func__,
-		       dev->nodename, xenbus_strstate(dev->state));
+		pr_info("%s: %s: %s != Connected, skipping\n",
+			__func__, dev->nodename, xenbus_strstate(dev->state));
 		goto out;
 	}
 	xenbus_switch_state(dev, XenbusStateClosing);
 	timeout = wait_for_completion_timeout(&dev->down, timeout);
 	if (!timeout)
-		printk(KERN_INFO "%s: %s timeout closing device\n",
-		       __func__, dev->nodename);
+		pr_info("%s: %s timeout closing device\n",
+			__func__, dev->nodename);
  out:
 	put_device(&dev->dev);
 }
@@ -579,8 +581,7 @@ int xenbus_dev_suspend(struct device *dev)
 	if (drv->suspend)
 		err = drv->suspend(xdev);
 	if (err)
-		printk(KERN_WARNING
-		       "xenbus: suspend %s failed: %i\n", dev_name(dev), err);
+		pr_warn("suspend %s failed: %i\n", dev_name(dev), err);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xenbus_dev_suspend);
@@ -599,9 +600,8 @@ int xenbus_dev_resume(struct device *dev)
 	drv = to_xenbus_driver(dev->driver);
 	err = talk_to_otherend(xdev);
 	if (err) {
-		printk(KERN_WARNING
-		       "xenbus: resume (talk_to_otherend) %s failed: %i\n",
-		       dev_name(dev), err);
+		pr_warn("resume (talk_to_otherend) %s failed: %i\n",
+			dev_name(dev), err);
 		return err;
 	}
 
@@ -610,18 +610,15 @@ int xenbus_dev_resume(struct device *dev)
 	if (drv->resume) {
 		err = drv->resume(xdev);
 		if (err) {
-			printk(KERN_WARNING
-			       "xenbus: resume %s failed: %i\n",
-			       dev_name(dev), err);
+			pr_warn("resume %s failed: %i\n", dev_name(dev), err);
 			return err;
 		}
 	}
 
 	err = watch_otherend(xdev);
 	if (err) {
-		printk(KERN_WARNING
-		       "xenbus_probe: resume (watch_otherend) %s failed: "
-		       "%d.\n", dev_name(dev), err);
+		pr_warn("resume (watch_otherend) %s failed: %d.\n",
+			dev_name(dev), err);
 		return err;
 	}
 
@@ -776,8 +773,7 @@ static int __init xenbus_init(void)
 	/* Initialize the interface to xenstore. */
 	err = xs_init();
 	if (err) {
-		printk(KERN_WARNING
-		       "XENBUS: Error initializing xenstore comms: %i\n", err);
+		pr_warn("Error initializing xenstore comms: %i\n", err);
 		goto out_error;
 	}
 
diff --git a/drivers/xen/xenbus/xenbus_probe_backend.c b/drivers/xen/xenbus/xenbus_probe_backend.c
index 257be37..998bbba 100644
--- a/drivers/xen/xenbus/xenbus_probe_backend.c
+++ b/drivers/xen/xenbus/xenbus_probe_backend.c
@@ -31,9 +31,11 @@
  * IN THE SOFTWARE.
  */
 
-#define DPRINTK(fmt, args...)				\
-	pr_debug("xenbus_probe (%s:%d) " fmt ".\n",	\
-		 __func__, __LINE__, ##args)
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#define DPRINTK(fmt, ...)				\
+	pr_debug("(%s:%d) " fmt "\n",			\
+		 __func__, __LINE__, ##__VA_ARGS__)
 
 #include <linux/kernel.h>
 #include <linux/err.h>
diff --git a/drivers/xen/xenbus/xenbus_probe_frontend.c b/drivers/xen/xenbus/xenbus_probe_frontend.c
index a7e2507..6ed8a9d 100644
--- a/drivers/xen/xenbus/xenbus_probe_frontend.c
+++ b/drivers/xen/xenbus/xenbus_probe_frontend.c
@@ -1,6 +1,8 @@
-#define DPRINTK(fmt, args...)				\
-	pr_debug("xenbus_probe (%s:%d) " fmt ".\n",	\
-		 __func__, __LINE__, ##args)
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#define DPRINTK(fmt, ...)				\
+	pr_debug("(%s:%d) " fmt "\n",			\
+		 __func__, __LINE__, ##__VA_ARGS__)
 
 #include <linux/kernel.h>
 #include <linux/err.h>
@@ -36,13 +38,13 @@ static int frontend_bus_id(char bus_id[XEN_BUS_ID_SIZE], const char *nodename)
 {
 	nodename = strchr(nodename, '/');
 	if (!nodename || strlen(nodename + 1) >= XEN_BUS_ID_SIZE) {
-		printk(KERN_WARNING "XENBUS: bad frontend %s\n", nodename);
+		pr_warn("bad frontend %s\n", nodename);
 		return -EINVAL;
 	}
 
 	strlcpy(bus_id, nodename + 1, XEN_BUS_ID_SIZE);
 	if (!strchr(bus_id, '/')) {
-		printk(KERN_WARNING "XENBUS: bus_id %s no slash\n", bus_id);
+		pr_warn("bus_id %s no slash\n", bus_id);
 		return -EINVAL;
 	}
 	*strchr(bus_id, '/') = '-';
@@ -234,15 +236,13 @@ static int print_device_status(struct device *dev, void *data)
 
 	if (!dev->driver) {
 		/* Information only: is this too noisy? */
-		printk(KERN_INFO "XENBUS: Device with no driver: %s\n",
-		       xendev->nodename);
+		pr_info("Device with no driver: %s\n", xendev->nodename);
 	} else if (xendev->state < XenbusStateConnected) {
 		enum xenbus_state rstate = XenbusStateUnknown;
 		if (xendev->otherend)
 			rstate = xenbus_read_driver_state(xendev->otherend);
-		printk(KERN_WARNING "XENBUS: Timeout connecting "
-		       "to device: %s (local state %d, remote state %d)\n",
-		       xendev->nodename, xendev->state, rstate);
+		pr_warn("Timeout connecting to device: %s (local state %d, remote state %d)\n",
+			xendev->nodename, xendev->state, rstate);
 	}
 
 	return 0;
@@ -256,12 +256,13 @@ static bool wait_loop(unsigned long start, unsigned int max_delay,
 {
 	if (time_after(jiffies, start + (*seconds_waited+5)*HZ)) {
 		if (!*seconds_waited)
-			printk(KERN_WARNING "XENBUS: Waiting for "
-			       "devices to initialise: ");
+			pr_warn("Waiting for devices to initialise: ");
 		*seconds_waited += 5;
-		printk("%us...", max_delay - *seconds_waited);
-		if (*seconds_waited == max_delay)
+		pr_cont("%us...", max_delay - *seconds_waited);
+		if (*seconds_waited == max_delay) {
+			pr_cont("\n");
 			return true;
+		}
 	}
 
 	schedule_timeout_interruptible(HZ/10);
@@ -342,7 +343,7 @@ static void xenbus_reset_wait_for_backend(char *be, int expected)
 	timeout = wait_event_interruptible_timeout(backend_state_wq,
 			backend_state == expected, 5 * HZ);
 	if (timeout <= 0)
-		printk(KERN_INFO "XENBUS: backend %s timed out.\n", be);
+		pr_info("backend %s timed out\n", be);
 }
 
 /*
@@ -365,7 +366,7 @@ static void xenbus_reset_frontend(char *fe, char *be, int be_state)
 	be_watch.callback = xenbus_reset_backend_state_changed;
 	backend_state = XenbusStateUnknown;
 
-	printk(KERN_INFO "XENBUS: triggering reconnect on %s\n", be);
+	pr_info("triggering reconnect on %s\n", be);
 	register_xenbus_watch(&be_watch);
 
 	/* fall through to forward backend to state XenbusStateInitialising */
@@ -384,7 +385,7 @@ static void xenbus_reset_frontend(char *fe, char *be, int be_state)
 	}
 
 	unregister_xenbus_watch(&be_watch);
-	printk(KERN_INFO "XENBUS: reconnect done on %s\n", be);
+	pr_info("reconnect done on %s\n", be);
 	kfree(be_watch.node);
 }
 
diff --git a/drivers/xen/xenbus/xenbus_xs.c b/drivers/xen/xenbus/xenbus_xs.c
index 88e677b..b6d5fff 100644
--- a/drivers/xen/xenbus/xenbus_xs.c
+++ b/drivers/xen/xenbus/xenbus_xs.c
@@ -31,6 +31,8 @@
  * IN THE SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/unistd.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -129,9 +131,8 @@ static int get_error(const char *errorstring)
 
 	for (i = 0; strcmp(errorstring, xsd_errors[i].errstring) != 0; i++) {
 		if (i == ARRAY_SIZE(xsd_errors) - 1) {
-			printk(KERN_WARNING
-			       "XENBUS xen store gave: unknown error %s",
-			       errorstring);
+			pr_warn("xen store gave: unknown error %s\n",
+				errorstring);
 			return EINVAL;
 		}
 	}
@@ -272,10 +273,8 @@ static void *xs_talkv(struct xenbus_transaction t,
 	}
 
 	if (msg.type != type) {
-		if (printk_ratelimit())
-			printk(KERN_WARNING
-			       "XENBUS unexpected type [%d], expected [%d]\n",
-			       msg.type, type);
+		pr_warn_ratelimited("unexpected type [%d], expected [%d]\n",
+				    msg.type, type);
 		kfree(ret);
 		return ERR_PTR(-EINVAL);
 	}
@@ -655,7 +654,7 @@ static void xs_reset_watches(void)
 
 	err = xs_error(xs_single(XBT_NIL, XS_RESET_WATCHES, "", NULL));
 	if (err && err != -EEXIST)
-		printk(KERN_WARNING "xs_reset_watches failed: %d\n", err);
+		pr_warn("xs_reset_watches failed: %d\n", err);
 }
 
 /* Register callback to watch this node. */
@@ -705,9 +704,7 @@ void unregister_xenbus_watch(struct xenbus_watch *watch)
 
 	err = xs_unwatch(watch->node, token);
 	if (err)
-		printk(KERN_WARNING
-		       "XENBUS Failed to release watch %s: %i\n",
-		       watch->node, err);
+		pr_warn("Failed to release watch %s: %i\n", watch->node, err);
 
 	up_read(&xs_state.watch_mutex);
 
@@ -901,8 +898,7 @@ static int xenbus_thread(void *unused)
 	for (;;) {
 		err = process_msg();
 		if (err)
-			printk(KERN_WARNING "XENBUS error %d while reading "
-			       "message\n", err);
+			pr_warn("error %d while reading message\n", err);
 		if (kthread_should_stop())
 			break;
 	}
diff --git a/drivers/xen/xencomm.c b/drivers/xen/xencomm.c
index b91f8ff..4793fc5 100644
--- a/drivers/xen/xencomm.c
+++ b/drivers/xen/xencomm.c
@@ -18,6 +18,8 @@
  * Authors: Hollis Blanchard <hollisb@us.ibm.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <asm/page.h>
diff --git a/drivers/xen/xenfs/super.c b/drivers/xen/xenfs/super.c
index 7167987..06092e0 100644
--- a/drivers/xen/xenfs/super.c
+++ b/drivers/xen/xenfs/super.c
@@ -7,6 +7,8 @@
  *                              Turned xenfs into a loadable module.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/module.h>
@@ -82,7 +84,7 @@ static int __init xenfs_init(void)
 	if (xen_domain())
 		return register_filesystem(&xenfs_type);
 
-	printk(KERN_INFO "XENFS: not registering filesystem on non-xen platform\n");
+	pr_info("not registering filesystem on non-xen platform\n");
 	return 0;
 }
 
diff --git a/include/xen/hvm.h b/include/xen/hvm.h
index 13e43e4..63917a8 100644
--- a/include/xen/hvm.h
+++ b/include/xen/hvm.h
@@ -44,8 +44,8 @@ static inline int hvm_get_parameter(int idx, uint64_t *value)
 	xhv.index = idx;
 	r = HYPERVISOR_hvm_op(HVMOP_get_param, &xhv);
 	if (r < 0) {
-		printk(KERN_ERR "Cannot get hvm parameter %s (%d): %d!\n",
-			param_name(idx), idx, r);
+		pr_err("Cannot get hvm parameter %s (%d): %d!\n",
+		       param_name(idx), idx, r);
 		return r;
 	}
 	*value = xhv.value;
