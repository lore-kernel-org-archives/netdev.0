From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 02/13] fsl/fman: fix loadable module compilation
Date: Tue, 4 Oct 2016 10:32:48 +0300
Message-ID: <1475566379-5078-3-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
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

From: Igal Liberman <igal.liberman@freescale.com>

Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Makefile    | 10 ++++---
 drivers/net/ethernet/freescale/fman/fman.c      | 35 +++++++++++++++++++++++--
 drivers/net/ethernet/freescale/fman/fman_port.c | 23 +++++++++++++++-
 drivers/net/ethernet/freescale/fman/fman_sp.c   |  3 +++
 4 files changed, 64 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index 51fd2e6..6049177 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -1,7 +1,9 @@
 subdir-ccflags-y +=  -I$(srctree)/drivers/net/ethernet/freescale/fman
 
-obj-y		+= fsl_fman.o fsl_fman_mac.o fsl_mac.o
+obj-$(CONFIG_FSL_FMAN) += fsl_fman.o
+obj-$(CONFIG_FSL_FMAN) += fsl_fman_port.o
+obj-$(CONFIG_FSL_FMAN) += fsl_mac.o
 
-fsl_fman-objs	:= fman_muram.o fman.o fman_sp.o fman_port.o
-fsl_fman_mac-objs := fman_dtsec.o fman_memac.o fman_tgec.o
-fsl_mac-objs += mac.o
+fsl_fman-objs	:= fman_muram.o fman.o fman_sp.o
+fsl_fman_port-objs := fman_port.o
+fsl_mac-objs:= mac.o fman_dtsec.o fman_memac.o fman_tgec.o
diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index 1de2e1e..ef5f228 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2115,6 +2115,7 @@ void fman_register_intr(struct fman *fman, enum fman_event_modules module,
 	fman->intr_mng[event].isr_cb = isr_cb;
 	fman->intr_mng[event].src_handle = src_arg;
 }
+EXPORT_SYMBOL(fman_register_intr);
 
 /**
  * fman_unregister_intr
@@ -2138,6 +2139,7 @@ void fman_unregister_intr(struct fman *fman, enum fman_event_modules module,
 	fman->intr_mng[event].isr_cb = NULL;
 	fman->intr_mng[event].src_handle = NULL;
 }
+EXPORT_SYMBOL(fman_unregister_intr);
 
 /**
  * fman_set_port_params
@@ -2241,6 +2243,7 @@ return_err:
 	spin_unlock_irqrestore(&fman->spinlock, flags);
 	return err;
 }
+EXPORT_SYMBOL(fman_set_port_params);
 
 /**
  * fman_reset_mac
@@ -2310,6 +2313,7 @@ int fman_reset_mac(struct fman *fman, u8 mac_id)
 
 	return 0;
 }
+EXPORT_SYMBOL(fman_reset_mac);
 
 /**
  * fman_set_mac_max_frame
@@ -2337,6 +2341,7 @@ int fman_set_mac_max_frame(struct fman *fman, u8 mac_id, u16 mfl)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(fman_set_mac_max_frame);
 
 /**
  * fman_get_clock_freq
@@ -2363,6 +2368,7 @@ u32 fman_get_bmi_max_fifo_size(struct fman *fman)
 {
 	return fman->state->bmi_max_fifo_size;
 }
+EXPORT_SYMBOL(fman_get_bmi_max_fifo_size);
 
 /**
  * fman_get_revision
@@ -2384,6 +2390,7 @@ void fman_get_revision(struct fman *fman, struct fman_rev_info *rev_info)
 				FPM_REV1_MAJOR_SHIFT);
 	rev_info->minor = tmp & FPM_REV1_MINOR_MASK;
 }
+EXPORT_SYMBOL(fman_get_revision);
 
 /**
  * fman_get_qman_channel_id
@@ -2419,6 +2426,7 @@ u32 fman_get_qman_channel_id(struct fman *fman, u32 port_id)
 
 	return fman->state->qman_channel_base + i;
 }
+EXPORT_SYMBOL(fman_get_qman_channel_id);
 
 /**
  * fman_get_mem_region
@@ -2432,6 +2440,7 @@ struct resource *fman_get_mem_region(struct fman *fman)
 {
 	return fman->state->res;
 }
+EXPORT_SYMBOL(fman_get_mem_region);
 
 /* Bootargs defines */
 /* Extra headroom for RX buffers - Default, min and max */
@@ -2538,6 +2547,7 @@ struct fman *fman_bind(struct device *fm_dev)
 {
 	return (struct fman *)(dev_get_drvdata(get_device(fm_dev)));
 }
+EXPORT_SYMBOL(fman_bind);
 
 static irqreturn_t fman_err_irq(int irq, void *handle)
 {
@@ -2930,7 +2940,7 @@ static const struct of_device_id fman_match[] = {
 	{}
 };
 
-MODULE_DEVICE_TABLE(of, fm_match);
+MODULE_DEVICE_TABLE(of, fman_match);
 
 static struct platform_driver fman_driver = {
 	.driver = {
@@ -2940,4 +2950,25 @@ static struct platform_driver fman_driver = {
 	.probe = fman_probe,
 };
 
-builtin_platform_driver(fman_driver);
+static int __init fman_load(void)
+{
+	int err;
+
+	pr_debug("FSL DPAA FMan driver\n");
+
+	err = platform_driver_register(&fman_driver);
+	if (err < 0)
+		pr_err("Error, platform_driver_register() = %d\n", err);
+
+	return err;
+}
+module_init(fman_load);
+
+static void __exit fman_unload(void)
+{
+	platform_driver_unregister(&fman_driver);
+}
+module_exit(fman_unload);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_DESCRIPTION("Freescale DPAA Frame Manager driver");
diff --git a/drivers/net/ethernet/freescale/fman/fman_port.c b/drivers/net/ethernet/freescale/fman/fman_port.c
index 70c198d..6de808e 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.c
+++ b/drivers/net/ethernet/freescale/fman/fman_port.c
@@ -1775,4 +1775,25 @@ static struct platform_driver fman_port_driver = {
 	.probe = fman_port_probe,
 };
 
-builtin_platform_driver(fman_port_driver);
+static int __init fman_port_load(void)
+{
+	int err;
+
+	pr_debug("FSL DPAA FMan driver\n");
+
+	err = platform_driver_register(&fman_port_driver);
+	if (err < 0)
+		pr_err("Error, platform_driver_register() = %d\n", err);
+
+	return err;
+}
+module_init(fman_port_load);
+
+static void __exit fman_port_unload(void)
+{
+	platform_driver_unregister(&fman_port_driver);
+}
+module_exit(fman_port_unload);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_DESCRIPTION("Freescale DPAA Frame Manager Port driver");
diff --git a/drivers/net/ethernet/freescale/fman/fman_sp.c b/drivers/net/ethernet/freescale/fman/fman_sp.c
index f9e7aa3..248f5bc 100644
--- a/drivers/net/ethernet/freescale/fman/fman_sp.c
+++ b/drivers/net/ethernet/freescale/fman/fman_sp.c
@@ -80,6 +80,7 @@ void fman_sp_set_buf_pools_in_asc_order_of_buf_sizes(struct fman_ext_pools
 		}
 	}
 }
+EXPORT_SYMBOL(fman_sp_set_buf_pools_in_asc_order_of_buf_sizes);
 
 int fman_sp_build_buffer_struct(struct fman_sp_int_context_data_copy *
 				int_context_data_copy,
@@ -164,3 +165,5 @@ int fman_sp_build_buffer_struct(struct fman_sp_int_context_data_copy *
 
 	return 0;
 }
+EXPORT_SYMBOL(fman_sp_build_buffer_struct);
+
-- 
2.1.0
