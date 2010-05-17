From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vhost: Storage class should be before const qualifier
Date: Mon, 17 May 2010 06:54:57 -0700
Message-ID: <1274104497.1705.589.camel@Joe-Laptop.home>
References: <1274101969-21109-1-git-send-email-tklauser@distanz.ch>
	 <20100517131335.GA12126@redhat.com>  <20100517132748.GQ9489@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100517132748.GQ9489@distanz.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-05-17 at 15:27 +0200, Tobias Klauser wrote:
> On 2010-05-17 at 15:13:35 +0200, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Mon, May 17, 2010 at 03:12:49PM +0200, Tobias Klauser wrote:
> > > The C99 specification states in section 6.11.5:
> > > The placement of a storage-class specifier other than at the beginning
> > > of the declaration specifiers in a declaration is an obsolescent
> > > feature.
> > > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> > Just to clarify: does some compiler/checker actually barf on this?
> GCC does emit a warning if the options '-std=c99 -W -Wall' are present.
> ICC also does warn about this, though I don't know whether this depends
> on any commandline options.

Perhaps others should be converted as well.

$ grep -rPl --include=*.[ch] "^[ \t]*const\s+static" * | \
  xargs sed -i -r -e 's/^[ \t]*const[ \t]+static\b/static const/g' 

gives:
---
 arch/arm/mach-pxa/palmtc.c                        |    4 +-
 arch/xtensa/variants/s6000/include/variant/dmac.h |    2 +-
 drivers/gpu/drm/i915/i915_drv.c                   |   38 ++++++++++----------
 drivers/mfd/timberdale.c                          |   18 +++++-----
 drivers/net/wireless/iwlwifi/iwl-core.c           |    4 +-
 drivers/staging/hv/vmbus_drv.c                    |    2 +-
 fs/ceph/mds_client.c                              |    4 +-
 fs/ceph/mon_client.c                              |    4 +-
 fs/ceph/osd_client.c                              |    4 +-
 sound/pci/hda/patch_realtek.c                     |    2 +-
 10 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/arch/arm/mach-pxa/palmtc.c b/arch/arm/mach-pxa/palmtc.c
index 717d7a6..8c09d48 100644
--- a/arch/arm/mach-pxa/palmtc.c
+++ b/arch/arm/mach-pxa/palmtc.c
@@ -263,11 +263,11 @@ const struct matrix_keymap_data palmtc_keymap_data = {
 	.keymap_size		= ARRAY_SIZE(palmtc_matrix_keys),
 };
 
-const static unsigned int palmtc_keypad_row_gpios[] = {
+static const unsigned int palmtc_keypad_row_gpios[] = {
 	0, 9, 10, 11
 };
 
-const static unsigned int palmtc_keypad_col_gpios[] = {
+static const unsigned int palmtc_keypad_col_gpios[] = {
 	18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 79, 80
 };
 
diff --git a/arch/xtensa/variants/s6000/include/variant/dmac.h b/arch/xtensa/variants/s6000/include/variant/dmac.h
index 89ab948..a24c4bb 100644
--- a/arch/xtensa/variants/s6000/include/variant/dmac.h
+++ b/arch/xtensa/variants/s6000/include/variant/dmac.h
@@ -357,7 +357,7 @@ static inline u32 s6dmac_channel_enabled(u32 dmac, int chan)
 static inline void s6dmac_dp_setup_group(u32 dmac, int port,
 			int nrch, int frrep)
 {
-	const static u8 mask[4] = {0, 3, 1, 2};
+static const u8 mask[4] = {0, 3, 1, 2};
 	BUG_ON(dmac != S6_REG_DPDMA);
 	if ((port < 0) || (port > 3) || (nrch < 1) || (nrch > 4))
 		return;
diff --git a/drivers/gpu/drm/i915/i915_drv.c b/drivers/gpu/drm/i915/i915_drv.c
index cc03537..20533ce 100644
--- a/drivers/gpu/drm/i915/i915_drv.c
+++ b/drivers/gpu/drm/i915/i915_drv.c
@@ -60,95 +60,95 @@ extern int intel_agp_enabled;
 	.subdevice = PCI_ANY_ID,		\
 	.driver_data = (unsigned long) info }
 
-const static struct intel_device_info intel_i830_info = {
+static const struct intel_device_info intel_i830_info = {
 	.is_i8xx = 1, .is_mobile = 1, .cursor_needs_physical = 1,
 };
 
-const static struct intel_device_info intel_845g_info = {
+static const struct intel_device_info intel_845g_info = {
 	.is_i8xx = 1,
 };
 
-const static struct intel_device_info intel_i85x_info = {
+static const struct intel_device_info intel_i85x_info = {
 	.is_i8xx = 1, .is_i85x = 1, .is_mobile = 1,
 	.cursor_needs_physical = 1,
 };
 
-const static struct intel_device_info intel_i865g_info = {
+static const struct intel_device_info intel_i865g_info = {
 	.is_i8xx = 1,
 };
 
-const static struct intel_device_info intel_i915g_info = {
+static const struct intel_device_info intel_i915g_info = {
 	.is_i915g = 1, .is_i9xx = 1, .cursor_needs_physical = 1,
 };
-const static struct intel_device_info intel_i915gm_info = {
+static const struct intel_device_info intel_i915gm_info = {
 	.is_i9xx = 1,  .is_mobile = 1,
 	.cursor_needs_physical = 1,
 };
-const static struct intel_device_info intel_i945g_info = {
+static const struct intel_device_info intel_i945g_info = {
 	.is_i9xx = 1, .has_hotplug = 1, .cursor_needs_physical = 1,
 };
-const static struct intel_device_info intel_i945gm_info = {
+static const struct intel_device_info intel_i945gm_info = {
 	.is_i945gm = 1, .is_i9xx = 1, .is_mobile = 1,
 	.has_hotplug = 1, .cursor_needs_physical = 1,
 };
 
-const static struct intel_device_info intel_i965g_info = {
+static const struct intel_device_info intel_i965g_info = {
 	.is_i965g = 1, .is_i9xx = 1, .has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_i965gm_info = {
+static const struct intel_device_info intel_i965gm_info = {
 	.is_i965g = 1, .is_mobile = 1, .is_i965gm = 1, .is_i9xx = 1,
 	.is_mobile = 1, .has_fbc = 1, .has_rc6 = 1,
 	.has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_g33_info = {
+static const struct intel_device_info intel_g33_info = {
 	.is_g33 = 1, .is_i9xx = 1, .need_gfx_hws = 1,
 	.has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_g45_info = {
+static const struct intel_device_info intel_g45_info = {
 	.is_i965g = 1, .is_g4x = 1, .is_i9xx = 1, .need_gfx_hws = 1,
 	.has_pipe_cxsr = 1,
 	.has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_gm45_info = {
+static const struct intel_device_info intel_gm45_info = {
 	.is_i965g = 1, .is_mobile = 1, .is_g4x = 1, .is_i9xx = 1,
 	.is_mobile = 1, .need_gfx_hws = 1, .has_fbc = 1, .has_rc6 = 1,
 	.has_pipe_cxsr = 1,
 	.has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_pineview_info = {
+static const struct intel_device_info intel_pineview_info = {
 	.is_g33 = 1, .is_pineview = 1, .is_mobile = 1, .is_i9xx = 1,
 	.need_gfx_hws = 1,
 	.has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_ironlake_d_info = {
+static const struct intel_device_info intel_ironlake_d_info = {
 	.is_ironlake = 1, .is_i965g = 1, .is_i9xx = 1, .need_gfx_hws = 1,
 	.has_pipe_cxsr = 1,
 	.has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_ironlake_m_info = {
+static const struct intel_device_info intel_ironlake_m_info = {
 	.is_ironlake = 1, .is_mobile = 1, .is_i965g = 1, .is_i9xx = 1,
 	.need_gfx_hws = 1, .has_rc6 = 1,
 	.has_hotplug = 1,
 };
 
-const static struct intel_device_info intel_sandybridge_d_info = {
+static const struct intel_device_info intel_sandybridge_d_info = {
 	.is_i965g = 1, .is_i9xx = 1, .need_gfx_hws = 1,
 	.has_hotplug = 1, .is_gen6 = 1,
 };
 
-const static struct intel_device_info intel_sandybridge_m_info = {
+static const struct intel_device_info intel_sandybridge_m_info = {
 	.is_i965g = 1, .is_mobile = 1, .is_i9xx = 1, .need_gfx_hws = 1,
 	.has_hotplug = 1, .is_gen6 = 1,
 };
 
-const static struct pci_device_id pciidlist[] = {
+static const struct pci_device_id pciidlist[] = {
 	INTEL_VGA_DEVICE(0x3577, &intel_i830_info),
 	INTEL_VGA_DEVICE(0x2562, &intel_845g_info),
 	INTEL_VGA_DEVICE(0x3582, &intel_i85x_info),
diff --git a/drivers/mfd/timberdale.c b/drivers/mfd/timberdale.c
index 7f478ec..8443e52 100644
--- a/drivers/mfd/timberdale.c
+++ b/drivers/mfd/timberdale.c
@@ -77,7 +77,7 @@ timberdale_ocores_platform_data = {
 	.num_devices = ARRAY_SIZE(timberdale_i2c_board_info)
 };
 
-const static __devinitconst struct resource timberdale_ocores_resources[] = {
+static const __devinitconst struct resource timberdale_ocores_resources[] = {
 	{
 		.start	= OCORESOFFSET,
 		.end	= OCORESEND,
@@ -126,7 +126,7 @@ static __devinitdata struct xspi_platform_data timberdale_xspi_platform_data = {
 	 */
 };
 
-const static __devinitconst struct resource timberdale_spi_resources[] = {
+static const __devinitconst struct resource timberdale_spi_resources[] = {
 	{
 		.start 	= SPIOFFSET,
 		.end	= SPIEND,
@@ -139,7 +139,7 @@ const static __devinitconst struct resource timberdale_spi_resources[] = {
 	},
 };
 
-const static __devinitconst struct resource timberdale_eth_resources[] = {
+static const __devinitconst struct resource timberdale_eth_resources[] = {
 	{
 		.start	= ETHOFFSET,
 		.end	= ETHEND,
@@ -159,7 +159,7 @@ static __devinitdata struct timbgpio_platform_data
 	.irq_base = 200,
 };
 
-const static __devinitconst struct resource timberdale_gpio_resources[] = {
+static const __devinitconst struct resource timberdale_gpio_resources[] = {
 	{
 		.start	= GPIOOFFSET,
 		.end	= GPIOEND,
@@ -172,7 +172,7 @@ const static __devinitconst struct resource timberdale_gpio_resources[] = {
 	},
 };
 
-const static __devinitconst struct resource timberdale_mlogicore_resources[] = {
+static const __devinitconst struct resource timberdale_mlogicore_resources[] = {
 	{
 		.start	= MLCOREOFFSET,
 		.end	= MLCOREEND,
@@ -190,7 +190,7 @@ const static __devinitconst struct resource timberdale_mlogicore_resources[] = {
 	},
 };
 
-const static __devinitconst struct resource timberdale_uart_resources[] = {
+static const __devinitconst struct resource timberdale_uart_resources[] = {
 	{
 		.start	= UARTOFFSET,
 		.end	= UARTEND,
@@ -203,7 +203,7 @@ const static __devinitconst struct resource timberdale_uart_resources[] = {
 	},
 };
 
-const static __devinitconst struct resource timberdale_uartlite_resources[] = {
+static const __devinitconst struct resource timberdale_uartlite_resources[] = {
 	{
 		.start	= UARTLITEOFFSET,
 		.end	= UARTLITEEND,
@@ -216,7 +216,7 @@ const static __devinitconst struct resource timberdale_uartlite_resources[] = {
 	},
 };
 
-const static __devinitconst struct resource timberdale_radio_resources[] = {
+static const __devinitconst struct resource timberdale_radio_resources[] = {
 	{
 		.start	= RDSOFFSET,
 		.end	= RDSEND,
@@ -250,7 +250,7 @@ static __devinitdata struct timb_radio_platform_data
 	}
 };
 
-const static __devinitconst struct resource timberdale_dma_resources[] = {
+static const __devinitconst struct resource timberdale_dma_resources[] = {
 	{
 		.start	= DMAOFFSET,
 		.end	= DMAEND,
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 049b652..47d1a4b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -3204,7 +3204,7 @@ void iwl_update_stats(struct iwl_priv *priv, bool is_tx, __le16 fc, u16 len)
 EXPORT_SYMBOL(iwl_update_stats);
 #endif
 
-const static char *get_csr_string(int cmd)
+static const char *get_csr_string(int cmd)
 {
 	switch (cmd) {
 		IWL_CMD(CSR_HW_IF_CONFIG_REG);
@@ -3275,7 +3275,7 @@ void iwl_dump_csr(struct iwl_priv *priv)
 }
 EXPORT_SYMBOL(iwl_dump_csr);
 
-const static char *get_fh_string(int cmd)
+static const char *get_fh_string(int cmd)
 {
 	switch (cmd) {
 		IWL_CMD(FH_RSCSR_CHNL0_STTS_WPTR_REG);
diff --git a/drivers/staging/hv/vmbus_drv.c b/drivers/staging/hv/vmbus_drv.c
index 3397ef0..ece5014 100644
--- a/drivers/staging/hv/vmbus_drv.c
+++ b/drivers/staging/hv/vmbus_drv.c
@@ -999,7 +999,7 @@ static void __exit vmbus_exit(void)
  * installed and/or configured.  We don't do anything else with the table, but
  * it needs to be present.
  */
-const static struct pci_device_id microsoft_hv_pci_table[] = {
+static const struct pci_device_id microsoft_hv_pci_table[] = {
 	{ PCI_DEVICE(0x1414, 0x5353) },	/* VGA compatible controller */
 	{ 0 }
 };
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 24561a5..4854943 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -40,7 +40,7 @@
 static void __wake_requests(struct ceph_mds_client *mdsc,
 			    struct list_head *head);
 
-const static struct ceph_connection_operations mds_con_ops;
+static const struct ceph_connection_operations mds_con_ops;
 
 
 /*
@@ -3031,7 +3031,7 @@ static int invalidate_authorizer(struct ceph_connection *con)
 	return ceph_monc_validate_auth(&mdsc->client->monc);
 }
 
-const static struct ceph_connection_operations mds_con_ops = {
+static const struct ceph_connection_operations mds_con_ops = {
 	.get = con_get,
 	.put = con_put,
 	.dispatch = dispatch,
diff --git a/fs/ceph/mon_client.c b/fs/ceph/mon_client.c
index 8fdc011..c5d3883 100644
--- a/fs/ceph/mon_client.c
+++ b/fs/ceph/mon_client.c
@@ -28,7 +28,7 @@
  * resend any outstanding requests.
  */
 
-const static struct ceph_connection_operations mon_con_ops;
+static const struct ceph_connection_operations mon_con_ops;
 
 static int __validate_auth(struct ceph_mon_client *monc);
 
@@ -826,7 +826,7 @@ out:
 	mutex_unlock(&monc->mutex);
 }
 
-const static struct ceph_connection_operations mon_con_ops = {
+static const struct ceph_connection_operations mon_con_ops = {
 	.get = ceph_con_get,
 	.put = ceph_con_put,
 	.dispatch = dispatch,
diff --git a/fs/ceph/osd_client.c b/fs/ceph/osd_client.c
index 3514f71..763fdb1 100644
--- a/fs/ceph/osd_client.c
+++ b/fs/ceph/osd_client.c
@@ -16,7 +16,7 @@
 #define OSD_OP_FRONT_LEN	4096
 #define OSD_OPREPLY_FRONT_LEN	512
 
-const static struct ceph_connection_operations osd_con_ops;
+static const struct ceph_connection_operations osd_con_ops;
 static int __kick_requests(struct ceph_osd_client *osdc,
 			  struct ceph_osd *kickosd);
 
@@ -1552,7 +1552,7 @@ static int invalidate_authorizer(struct ceph_connection *con)
 	return ceph_monc_validate_auth(&osdc->client->monc);
 }
 
-const static struct ceph_connection_operations osd_con_ops = {
+static const struct ceph_connection_operations osd_con_ops = {
 	.get = get_osd_con,
 	.put = put_osd_con,
 	.dispatch = dispatch,
diff --git a/sound/pci/hda/patch_realtek.c b/sound/pci/hda/patch_realtek.c
index 886d8e4..ae85771 100644
--- a/sound/pci/hda/patch_realtek.c
+++ b/sound/pci/hda/patch_realtek.c
@@ -14082,7 +14082,7 @@ enum {
 	ALC269_FIXUP_SONY_VAIO,
 };
 
-const static struct hda_verb alc269_sony_vaio_fixup_verbs[] = {
+static const struct hda_verb alc269_sony_vaio_fixup_verbs[] = {
 	{0x19, AC_VERB_SET_PIN_WIDGET_CONTROL, PIN_VREFGRD},
 	{}
 };
