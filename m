From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH net-next] vxge: make functions local and remove dead
 code
Date: Mon, 18 Oct 2010 15:28:23 -0500
Message-ID: <20101018202822.GC13623@exar.com>
References: <20101015102110.056690c6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45842 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757606Ab0JRU2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 16:28:34 -0400
Received: by yxm8 with SMTP id 8so732793yxm.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 13:28:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101015102110.056690c6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 10:21:10AM -0700, Stephen Hemminger wrote:
> Use results of make namespacecheck to make functions local and
> remove code that is not used.
> 
> Also rename initialize_ethtool_ops to vxge_initialize_ethtool_ops.
> 
> Compile tested only.

These all look sane.  I have a patchset coming out soon that has some
of these changes, and I was going to make the rest of the changes
below in the following series (per your earlier e-mail).  I would
prefer to release those before applying this patch, as it touches many
things.

Thanks,
Jon

> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
>  drivers/net/vxge/vxge-config.c  |  332 +++++++++++++++++++++++++++++-----------
>  drivers/net/vxge/vxge-config.h  |  227 ---------------------------
>  drivers/net/vxge/vxge-ethtool.c |    2
>  drivers/net/vxge/vxge-main.c    |   64 ++++---
>  drivers/net/vxge/vxge-main.h    |   59 -------
>  drivers/net/vxge/vxge-traffic.c |  101 +-----------
>  drivers/net/vxge/vxge-traffic.h |  134 ----------------
>  7 files changed, 304 insertions(+), 615 deletions(-)
> 
> --- a/drivers/net/vxge/vxge-config.c    2010-10-15 09:10:06.686399147 -0700
> +++ b/drivers/net/vxge/vxge-config.c    2010-10-15 10:15:51.420682586 -0700
> @@ -20,6 +20,179 @@
>  #include "vxge-traffic.h"
>  #include "vxge-config.h"
> 
> +static enum vxge_hw_status
> +__vxge_hw_fifo_create(
> +       struct __vxge_hw_vpath_handle *vpath_handle,
> +       struct vxge_hw_fifo_attr *attr);
> +
> +static enum vxge_hw_status
> +__vxge_hw_fifo_abort(
> +       struct __vxge_hw_fifo *fifoh);
> +
> +static enum vxge_hw_status
> +__vxge_hw_fifo_reset(
> +       struct __vxge_hw_fifo *ringh);
> +
> +static enum vxge_hw_status
> +__vxge_hw_fifo_delete(
> +       struct __vxge_hw_vpath_handle *vpath_handle);
> +
> +static struct __vxge_hw_blockpool_entry *
> +__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *hldev,
> +                       u32 size);
> +
> +static void
> +__vxge_hw_blockpool_block_free(struct __vxge_hw_device *hldev,
> +                       struct __vxge_hw_blockpool_entry *entry);
> +
> +static void vxge_hw_blockpool_block_add(struct __vxge_hw_device *devh,
> +                                       void *block_addr,
> +                                       u32 length,
> +                                       struct pci_dev *dma_h,
> +                                       struct pci_dev *acc_handle);
> +
> +static enum vxge_hw_status
> +__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
> +                       struct __vxge_hw_blockpool  *blockpool,
> +                       u32 pool_size,
> +                       u32 pool_max);
> +
> +static void
> +__vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool  *blockpool);
> +
> +static void *
> +__vxge_hw_blockpool_malloc(struct __vxge_hw_device *hldev,
> +                       u32 size,
> +                       struct vxge_hw_mempool_dma *dma_object);
> +
> +static void
> +__vxge_hw_blockpool_free(struct __vxge_hw_device *hldev,
> +                       void *memblock,
> +                       u32 size,
> +                       struct vxge_hw_mempool_dma *dma_object);
> +
> +
> +static struct __vxge_hw_channel*
> +__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
> +                       enum __vxge_hw_channel_type type, u32 length,
> +                       u32 per_dtr_space, void *userdata);
> +
> +static void
> +__vxge_hw_channel_free(
> +       struct __vxge_hw_channel *channel);
> +
> +static enum vxge_hw_status
> +__vxge_hw_channel_initialize(
> +       struct __vxge_hw_channel *channel);
> +
> +static enum vxge_hw_status
> +__vxge_hw_channel_reset(
> +       struct __vxge_hw_channel *channel);
> +
> +static enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp);
> +
> +static enum vxge_hw_status
> +__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config);
> +
> +static enum vxge_hw_status
> +__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config);
> +
> +static void
> +__vxge_hw_device_id_get(struct __vxge_hw_device *hldev);
> +
> +static void
> +__vxge_hw_device_host_info_get(struct __vxge_hw_device *hldev);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_card_info_get(
> +       u32 vp_id,
> +       struct vxge_hw_vpath_reg __iomem *vpath_reg,
> +       struct vxge_hw_device_hw_info *hw_info);
> +
> +static enum vxge_hw_status
> +__vxge_hw_device_initialize(struct __vxge_hw_device *hldev);
> +
> +static void
> +__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev);
> +
> +static enum vxge_hw_status
> +__vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev);
> +
> +static enum vxge_hw_status
> +__vxge_hw_device_register_poll(
> +       void __iomem    *reg,
> +       u64 mask, u32 max_millis);
> +
> +static inline enum vxge_hw_status
> +__vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
> +                         u64 mask, u32 max_millis)
> +{
> +       __vxge_hw_pio_mem_write32_lower((u32)vxge_bVALn(val64, 32, 32), addr);
> +       wmb();
> +
> +       __vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32), addr);
> +       wmb();
> +
> +       return  __vxge_hw_device_register_poll(addr, mask, max_millis);
> +}
> +
> +static struct vxge_hw_mempool*
> +__vxge_hw_mempool_create(struct __vxge_hw_device *devh, u32 memblock_size,
> +                        u32 item_size, u32 private_size, u32 items_initial,
> +                        u32 items_max, struct vxge_hw_mempool_cbs *mp_callback,
> +                        void *userdata);
> +static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_stats_get(struct __vxge_hw_virtualpath *vpath,
> +                         struct vxge_hw_vpath_stats_hw_info *hw_stats);
> +
> +static enum vxge_hw_status
> +vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vpath_handle);
> +
> +static enum vxge_hw_status
> +__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg);
> +
> +static u64
> +__vxge_hw_vpath_pci_func_mode_get(u32  vp_id,
> +                                 struct vxge_hw_vpath_reg __iomem *vpath_reg);
> +
> +static u32
> +__vxge_hw_vpath_func_id_get(u32 vp_id, struct vxge_hw_vpmgmt_reg __iomem *vpmgmt_reg);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_addr_get(u32 vp_id, struct vxge_hw_vpath_reg __iomem *vpath_reg,
> +                        u8 (macaddr)[ETH_ALEN], u8 (macaddr_mask)[ETH_ALEN]);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
> +
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_sw_reset(struct __vxge_hw_device *devh, u32 vp_id);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_fw_ver_get(u32 vp_id, struct vxge_hw_vpath_reg __iomem *vpath_reg,
> +                          struct vxge_hw_device_hw_info *hw_info);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_mac_configure(struct __vxge_hw_device *devh, u32 vp_id);
> +
> +static void
> +__vxge_hw_vp_terminate(struct __vxge_hw_device *devh, u32 vp_id);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_stats_access(struct __vxge_hw_virtualpath *vpath,
> +                            u32 operation, u32 offset, u64 *stat);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_xmac_tx_stats_get(struct __vxge_hw_virtualpath *vpath,
> +                                 struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats);
> +
> +static enum vxge_hw_status
> +__vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath *vpath,
> +                                 struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats);
> +
>  /*
>   * __vxge_hw_channel_allocate - Allocate memory for channel
>   * This function allocates required memory for the channel and various arrays
> @@ -190,7 +363,7 @@ __vxge_hw_device_pci_e_init(struct __vxg
>   * Will poll certain register for specified amount of time.
>   * Will poll until masked bit is not cleared.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
>  {
>         u64 val64;
> @@ -221,7 +394,7 @@ __vxge_hw_device_register_poll(void __io
>   * in progress
>   * This routine checks the vpath reset in progress register is turned zero
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog)
>  {
>         enum vxge_hw_status status;
> @@ -236,7 +409,7 @@ __vxge_hw_device_vpath_reset_in_prog_che
>   * This routine sets the swapper and reads the toc pointer and returns the
>   * memory mapped address of the toc
>   */
> -struct vxge_hw_toc_reg __iomem *
> +static struct vxge_hw_toc_reg __iomem *
>  __vxge_hw_device_toc_get(void __iomem *bar0)
>  {
>         u64 val64;
> @@ -779,7 +952,7 @@ exit:
>   * vxge_hw_device_xmac_aggr_stats_get - Get the Statistics on aggregate port
>   * Get the Statistics on aggregate port
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  vxge_hw_device_xmac_aggr_stats_get(struct __vxge_hw_device *hldev, u32 port,
>                                    struct vxge_hw_xmac_aggr_stats *aggr_stats)
>  {
> @@ -814,7 +987,7 @@ exit:
>   * vxge_hw_device_xmac_port_stats_get - Get the Statistics on a port
>   * Get the Statistics on port
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  vxge_hw_device_xmac_port_stats_get(struct __vxge_hw_device *hldev, u32 port,
>                                    struct vxge_hw_xmac_port_stats *port_stats)
>  {
> @@ -952,20 +1125,6 @@ u32 vxge_hw_device_trace_level_get(struc
>         return 0;
>  #endif
>  }
> -/*
> - * vxge_hw_device_debug_mask_get - Get the debug mask
> - * This routine returns the current debug mask set
> - */
> -u32 vxge_hw_device_debug_mask_get(struct __vxge_hw_device *hldev)
> -{
> -#if defined(VXGE_DEBUG_TRACE_MASK) || defined(VXGE_DEBUG_ERR_MASK)
> -       if (hldev == NULL)
> -               return 0;
> -       return hldev->debug_module_mask;
> -#else
> -       return 0;
> -#endif
> -}
> 
>  /*
>   * vxge_hw_getpause_data -Pause frame frame generation and reception.
> @@ -1090,7 +1249,7 @@ __vxge_hw_ring_block_next_pointer_set(u8
>   *             first block
>   * Returns the dma address of the first RxD block
>   */
> -u64 __vxge_hw_ring_first_block_address_get(struct __vxge_hw_ring *ring)
> +static u64 __vxge_hw_ring_first_block_address_get(struct __vxge_hw_ring *ring)
>  {
>         struct vxge_hw_mempool_dma *dma_object;
> 
> @@ -1252,7 +1411,7 @@ exit:
>   * This function creates Ring and initializes it.
>   *
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
>                       struct vxge_hw_ring_attr *attr)
>  {
> @@ -1363,7 +1522,7 @@ exit:
>   * __vxge_hw_ring_abort - Returns the RxD
>   * This function terminates the RxDs of ring
>   */
> -enum vxge_hw_status __vxge_hw_ring_abort(struct __vxge_hw_ring *ring)
> +static enum vxge_hw_status __vxge_hw_ring_abort(struct __vxge_hw_ring *ring)
>  {
>         void *rxdh;
>         struct __vxge_hw_channel *channel;
> @@ -1392,7 +1551,7 @@ enum vxge_hw_status __vxge_hw_ring_abort
>   * __vxge_hw_ring_reset - Resets the ring
>   * This function resets the ring during vpath reset operation
>   */
> -enum vxge_hw_status __vxge_hw_ring_reset(struct __vxge_hw_ring *ring)
> +static enum vxge_hw_status __vxge_hw_ring_reset(struct __vxge_hw_ring *ring)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
>         struct __vxge_hw_channel *channel;
> @@ -1419,7 +1578,7 @@ exit:
>   * __vxge_hw_ring_delete - Removes the ring
>   * This function freeup the memory pool and removes the ring
>   */
> -enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp)
> +static enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp)
>  {
>         struct __vxge_hw_ring *ring = vp->vpath->ringh;
> 
> @@ -1438,7 +1597,7 @@ enum vxge_hw_status __vxge_hw_ring_delet
>   * __vxge_hw_mempool_grow
>   * Will resize mempool up to %num_allocate value.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_mempool_grow(struct vxge_hw_mempool *mempool, u32 num_allocate,
>                        u32 *num_allocated)
>  {
> @@ -1527,7 +1686,7 @@ exit:
>   * with size enough to hold %items_initial number of items. Memory is
>   * DMA-able but client must map/unmap before interoperating with the device.
>   */
> -struct vxge_hw_mempool*
> +static struct vxge_hw_mempool*
>  __vxge_hw_mempool_create(
>         struct __vxge_hw_device *devh,
>         u32 memblock_size,
> @@ -1644,7 +1803,7 @@ exit:
>  /*
>   * vxge_hw_mempool_destroy
>   */
> -void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
> +static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
>  {
>         u32 i, j;
>         struct __vxge_hw_device *devh = mempool->devh;
> @@ -1700,7 +1859,7 @@ __vxge_hw_device_fifo_config_check(struc
>   * __vxge_hw_device_vpath_config_check - Check vpath configuration.
>   * Check the vpath configuration
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
>  {
>         enum vxge_hw_status status;
> @@ -1922,7 +2081,7 @@ vxge_hw_device_config_default_get(struct
>   * _hw_legacy_swapper_set - Set the swapper bits for the legacy secion.
>   * Set the swapper bits appropriately for the lagacy section.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg)
>  {
>         u64 val64;
> @@ -1977,7 +2136,7 @@ __vxge_hw_legacy_swapper_set(struct vxge
>   * __vxge_hw_vpath_swapper_set - Set the swapper bits for the vpath.
>   * Set the swapper bits appropriately for the vpath.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg)
>  {
>  #ifndef __BIG_ENDIAN
> @@ -1996,7 +2155,7 @@ __vxge_hw_vpath_swapper_set(struct vxge_
>   * __vxge_hw_kdfc_swapper_set - Set the swapper bits for the kdfc.
>   * Set the swapper bits appropriately for the vpath.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_kdfc_swapper_set(
>         struct vxge_hw_legacy_reg __iomem *legacy_reg,
>         struct vxge_hw_vpath_reg __iomem *vpath_reg)
> @@ -2021,28 +2180,6 @@ __vxge_hw_kdfc_swapper_set(
>  }
> 
>  /*
> - * vxge_hw_mgmt_device_config - Retrieve device configuration.
> - * Get device configuration. Permits to retrieve at run-time configuration
> - * values that were used to initialize and configure the device.
> - */
> -enum vxge_hw_status
> -vxge_hw_mgmt_device_config(struct __vxge_hw_device *hldev,
> -                          struct vxge_hw_device_config *dev_config, int size)
> -{
> -
> -       if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC))
> -               return VXGE_HW_ERR_INVALID_DEVICE;
> -
> -       if (size != sizeof(struct vxge_hw_device_config))
> -               return VXGE_HW_ERR_VERSION_CONFLICT;
> -
> -       memcpy(dev_config, &hldev->config,
> -               sizeof(struct vxge_hw_device_config));
> -
> -       return VXGE_HW_OK;
> -}
> -
> -/*
>   * vxge_hw_mgmt_reg_read - Read Titan register.
>   */
>  enum vxge_hw_status
> @@ -2438,7 +2575,7 @@ exit:
>   * __vxge_hw_fifo_abort - Returns the TxD
>   * This function terminates the TxDs of fifo
>   */
> -enum vxge_hw_status __vxge_hw_fifo_abort(struct __vxge_hw_fifo *fifo)
> +static enum vxge_hw_status __vxge_hw_fifo_abort(struct __vxge_hw_fifo *fifo)
>  {
>         void *txdlh;
> 
> @@ -2466,7 +2603,7 @@ enum vxge_hw_status __vxge_hw_fifo_abort
>   * __vxge_hw_fifo_reset - Resets the fifo
>   * This function resets the fifo during vpath reset operation
>   */
> -enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
> +static enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
> 
> @@ -2501,7 +2638,7 @@ enum vxge_hw_status __vxge_hw_fifo_delet
>   *                          in pci config space.
>   * Read from the vpath pci config space.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_pci_read(struct __vxge_hw_virtualpath *vpath,
>                          u32 phy_func_0, u32 offset, u32 *val)
>  {
> @@ -2542,7 +2679,7 @@ exit:
>   * __vxge_hw_vpath_func_id_get - Get the function id of the vpath.
>   * Returns the function number of the vpath.
>   */
> -u32
> +static u32
>  __vxge_hw_vpath_func_id_get(u32 vp_id,
>         struct vxge_hw_vpmgmt_reg __iomem *vpmgmt_reg)
>  {
> @@ -2573,7 +2710,7 @@ __vxge_hw_read_rts_ds(struct vxge_hw_vpa
>   * __vxge_hw_vpath_card_info_get - Get the serial numbers,
>   * part number and product description.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_card_info_get(
>         u32 vp_id,
>         struct vxge_hw_vpath_reg __iomem *vpath_reg,
> @@ -2695,7 +2832,7 @@ __vxge_hw_vpath_card_info_get(
>   * __vxge_hw_vpath_fw_ver_get - Get the fw version
>   * Returns FW Version
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_fw_ver_get(
>         u32 vp_id,
>         struct vxge_hw_vpath_reg __iomem *vpath_reg,
> @@ -2789,7 +2926,7 @@ exit:
>   * __vxge_hw_vpath_pci_func_mode_get - Get the pci mode
>   * Returns pci function mode
>   */
> -u64
> +static u64
>  __vxge_hw_vpath_pci_func_mode_get(
>         u32  vp_id,
>         struct vxge_hw_vpath_reg __iomem *vpath_reg)
> @@ -2995,7 +3132,7 @@ exit:
>   * __vxge_hw_vpath_addr_get - Get the hw address entry for this vpath
>   *               from MAC address table.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_addr_get(
>         u32 vp_id, struct vxge_hw_vpath_reg __iomem *vpath_reg,
>         u8 (macaddr)[ETH_ALEN], u8 (macaddr_mask)[ETH_ALEN])
> @@ -3347,7 +3484,7 @@ __vxge_hw_vpath_mgmt_read(
>   * This routine checks the vpath_rst_in_prog register to see if
>   * adapter completed the reset process for the vpath
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath)
>  {
>         enum vxge_hw_status status;
> @@ -3365,7 +3502,7 @@ __vxge_hw_vpath_reset_check(struct __vxg
>   * __vxge_hw_vpath_reset
>   * This routine resets the vpath on the device
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_reset(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         u64 val64;
> @@ -3383,7 +3520,7 @@ __vxge_hw_vpath_reset(struct __vxge_hw_d
>   * __vxge_hw_vpath_sw_reset
>   * This routine resets the vpath structures
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_sw_reset(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
> @@ -3408,7 +3545,7 @@ exit:
>   * This routine configures the prc registers of virtual path using the config
>   * passed
>   */
> -void
> +static void
>  __vxge_hw_vpath_prc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         u64 val64;
> @@ -3480,7 +3617,7 @@ __vxge_hw_vpath_prc_configure(struct __v
>   * This routine configures the kdfc registers of virtual path using the
>   * config passed
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_kdfc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         u64 val64;
> @@ -3553,7 +3690,7 @@ exit:
>   * __vxge_hw_vpath_mac_configure
>   * This routine configures the mac of virtual path using the config passed
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_mac_configure(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         u64 val64;
> @@ -3621,7 +3758,7 @@ __vxge_hw_vpath_mac_configure(struct __v
>   * This routine configures the tim registers of virtual path using the config
>   * passed
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         u64 val64;
> @@ -3897,7 +4034,7 @@ vxge_hw_vpath_tti_ci_set(struct __vxge_h
>   * This routine is the final phase of init which initializes the
>   * registers of the vpath using the configuration passed.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_initialize(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         u64 val64;
> @@ -3966,7 +4103,7 @@ exit:
>   * This routine is the initial phase of init which resets the vpath and
>   * initializes the software support structures.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vp_initialize(struct __vxge_hw_device *hldev, u32 vp_id,
>                         struct vxge_hw_vp_config *config)
>  {
> @@ -4022,7 +4159,7 @@ exit:
>   * __vxge_hw_vp_terminate - Terminate Virtual Path structure
>   * This routine closes all channels it opened and freeup memory
>   */
> -void
> +static void
>  __vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
>  {
>         struct __vxge_hw_virtualpath *vpath;
> @@ -4384,7 +4521,7 @@ vxge_hw_vpath_enable(struct __vxge_hw_vp
>   * Enable the DMA vpath statistics. The function is to be called to re-enable
>   * the adapter to update stats into the host memory
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vp)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
> @@ -4409,7 +4546,7 @@ exit:
>   * __vxge_hw_vpath_stats_access - Get the statistics from the given location
>   *                           and offset and perform an operation
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_stats_access(struct __vxge_hw_virtualpath *vpath,
>                              u32 operation, u32 offset, u64 *stat)
>  {
> @@ -4445,7 +4582,7 @@ vpath_stats_access_exit:
>  /*
>   * __vxge_hw_vpath_xmac_tx_stats_get - Get the TX Statistics of a vpath
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_xmac_tx_stats_get(
>         struct __vxge_hw_virtualpath *vpath,
>         struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats)
> @@ -4478,9 +4615,9 @@ exit:
>  /*
>   * __vxge_hw_vpath_xmac_rx_stats_get - Get the RX Statistics of a vpath
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath *vpath,
> -                       struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats)
> +                                 struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats)
>  {
>         u64 *val64;
>         enum vxge_hw_status status = VXGE_HW_OK;
> @@ -4509,9 +4646,9 @@ exit:
>  /*
>   * __vxge_hw_vpath_stats_get - Get the vpath hw statistics.
>   */
> -enum vxge_hw_status __vxge_hw_vpath_stats_get(
> -                       struct __vxge_hw_virtualpath *vpath,
> -                       struct vxge_hw_vpath_stats_hw_info *hw_stats)
> +static enum vxge_hw_status
> +__vxge_hw_vpath_stats_get(struct __vxge_hw_virtualpath *vpath,
> +                         struct vxge_hw_vpath_stats_hw_info *hw_stats)
>  {
>         u64 val64;
>         enum vxge_hw_status status = VXGE_HW_OK;
> @@ -4643,6 +4780,32 @@ exit:
>         return status;
>  }
> 
> +
> +static void vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh,
> +                                       unsigned long size)
> +{
> +       gfp_t flags;
> +       void *vaddr;
> +
> +       if (in_interrupt())
> +               flags = GFP_ATOMIC | GFP_DMA;
> +       else
> +               flags = GFP_KERNEL | GFP_DMA;
> +
> +       vaddr = kmalloc((size), flags);
> +
> +       vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
> +}
> +
> +static void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
> +                            struct pci_dev **p_dma_acch)
> +{
> +       unsigned long misaligned = *(unsigned long *)p_dma_acch;
> +       u8 *tmp = (u8 *)vaddr;
> +       tmp -= misaligned;
> +       kfree((void *)tmp);
> +}
> +
>  /*
>   * __vxge_hw_blockpool_create - Create block pool
>   */
> @@ -4845,12 +5008,11 @@ void __vxge_hw_blockpool_blocks_remove(s
>   * vxge_hw_blockpool_block_add - callback for vxge_os_dma_malloc_async
>   * Adds a block to block pool
>   */
> -void vxge_hw_blockpool_block_add(
> -                       struct __vxge_hw_device *devh,
> -                       void *block_addr,
> -                       u32 length,
> -                       struct pci_dev *dma_h,
> -                       struct pci_dev *acc_handle)
> +static void vxge_hw_blockpool_block_add(struct __vxge_hw_device *devh,
> +                                       void *block_addr,
> +                                       u32 length,
> +                                       struct pci_dev *dma_h,
> +                                       struct pci_dev *acc_handle)
>  {
>         struct __vxge_hw_blockpool  *blockpool;
>         struct __vxge_hw_blockpool_entry  *entry = NULL;
> --- a/drivers/net/vxge/vxge-config.h    2010-10-15 09:10:06.766402819 -0700
> +++ b/drivers/net/vxge/vxge-config.h    2010-10-15 10:14:19.925408165 -0700
> @@ -183,11 +183,6 @@ struct vxge_hw_device_version {
>         char    version[VXGE_HW_FW_STRLEN];
>  };
> 
> -u64
> -__vxge_hw_vpath_pci_func_mode_get(
> -       u32 vp_id,
> -       struct vxge_hw_vpath_reg __iomem *vpath_reg);
> -
>  /**
>   * struct vxge_hw_fifo_config - Configuration of fifo.
>   * @enable: Is this fifo to be commissioned
> @@ -1426,9 +1421,6 @@ struct vxge_hw_rth_hash_types {
>         u8 hash_type_ipv6ex_en;
>  };
> 
> -u32
> -vxge_hw_device_debug_mask_get(struct __vxge_hw_device *devh);
> -
>  void vxge_hw_device_debug_set(
>         struct __vxge_hw_device *devh,
>         enum vxge_debug_level level,
> @@ -1440,9 +1432,6 @@ vxge_hw_device_error_level_get(struct __
>  u32
>  vxge_hw_device_trace_level_get(struct __vxge_hw_device *devh);
> 
> -u32
> -vxge_hw_device_debug_mask_get(struct __vxge_hw_device *devh);
> -
>  /**
>   * vxge_hw_ring_rxd_size_get   - Get the size of ring descriptor.
>   * @buf_mode: Buffer mode (1, 3 or 5)
> @@ -1817,60 +1806,10 @@ struct vxge_hw_vpath_attr {
>         struct vxge_hw_fifo_attr        fifo_attr;
>  };
> 
> -enum vxge_hw_status
> -__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
> -                       struct __vxge_hw_blockpool  *blockpool,
> -                       u32 pool_size,
> -                       u32 pool_max);
> -
> -void
> -__vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool  *blockpool);
> -
> -struct __vxge_hw_blockpool_entry *
> -__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *hldev,
> -                       u32 size);
> -
> -void
> -__vxge_hw_blockpool_block_free(struct __vxge_hw_device *hldev,
> -                       struct __vxge_hw_blockpool_entry *entry);
> -
> -void *
> -__vxge_hw_blockpool_malloc(struct __vxge_hw_device *hldev,
> -                       u32 size,
> -                       struct vxge_hw_mempool_dma *dma_object);
> -
> -void
> -__vxge_hw_blockpool_free(struct __vxge_hw_device *hldev,
> -                       void *memblock,
> -                       u32 size,
> -                       struct vxge_hw_mempool_dma *dma_object);
> -
> -enum vxge_hw_status
> -__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config);
> -
> -enum vxge_hw_status
> -__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config);
> -
> -enum vxge_hw_status
> -vxge_hw_mgmt_device_config(struct __vxge_hw_device *devh,
> -               struct vxge_hw_device_config    *dev_config, int size);
> -
>  enum vxge_hw_status __devinit vxge_hw_device_hw_info_get(
>         void __iomem *bar0,
>         struct vxge_hw_device_hw_info *hw_info);
> 
> -enum vxge_hw_status
> -__vxge_hw_vpath_fw_ver_get(
> -       u32     vp_id,
> -       struct vxge_hw_vpath_reg __iomem *vpath_reg,
> -       struct vxge_hw_device_hw_info *hw_info);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_card_info_get(
> -       u32 vp_id,
> -       struct vxge_hw_vpath_reg __iomem *vpath_reg,
> -       struct vxge_hw_device_hw_info *hw_info);
> -
>  enum vxge_hw_status __devinit vxge_hw_device_config_default_get(
>         struct vxge_hw_device_config *device_config);
> 
> @@ -1954,38 +1893,6 @@ out:
>         return vaddr;
>  }
> 
> -extern void vxge_hw_blockpool_block_add(
> -                       struct __vxge_hw_device *devh,
> -                       void *block_addr,
> -                       u32 length,
> -                       struct pci_dev *dma_h,
> -                       struct pci_dev *acc_handle);
> -
> -static inline void vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh,
> -                                       unsigned long size)
> -{
> -       gfp_t flags;
> -       void *vaddr;
> -
> -       if (in_interrupt())
> -               flags = GFP_ATOMIC | GFP_DMA;
> -       else
> -               flags = GFP_KERNEL | GFP_DMA;
> -
> -       vaddr = kmalloc((size), flags);
> -
> -       vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
> -}
> -
> -static inline void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
> -                       struct pci_dev **p_dma_acch)
> -{
> -       unsigned long misaligned = *(unsigned long *)p_dma_acch;
> -       u8 *tmp = (u8 *)vaddr;
> -       tmp -= misaligned;
> -       kfree((void *)tmp);
> -}
> -
>  /*
>   * __vxge_hw_mempool_item_priv - will return pointer on per item private space
>   */
> @@ -2010,40 +1917,6 @@ __vxge_hw_mempool_item_priv(
>                             (*memblock_item_idx) * mempool->items_priv_size;
>  }
> 
> -enum vxge_hw_status
> -__vxge_hw_mempool_grow(
> -       struct vxge_hw_mempool *mempool,
> -       u32 num_allocate,
> -       u32 *num_allocated);
> -
> -struct vxge_hw_mempool*
> -__vxge_hw_mempool_create(
> -       struct __vxge_hw_device *devh,
> -       u32 memblock_size,
> -       u32 item_size,
> -       u32 private_size,
> -       u32 items_initial,
> -       u32 items_max,
> -       struct vxge_hw_mempool_cbs *mp_callback,
> -       void *userdata);
> -
> -struct __vxge_hw_channel*
> -__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
> -                       enum __vxge_hw_channel_type type, u32 length,
> -                       u32 per_dtr_space, void *userdata);
> -
> -void
> -__vxge_hw_channel_free(
> -       struct __vxge_hw_channel *channel);
> -
> -enum vxge_hw_status
> -__vxge_hw_channel_initialize(
> -       struct __vxge_hw_channel *channel);
> -
> -enum vxge_hw_status
> -__vxge_hw_channel_reset(
> -       struct __vxge_hw_channel *channel);
> -
>  /*
>   * __vxge_hw_fifo_txdl_priv - Return the max fragments allocated
>   * for the fifo.
> @@ -2065,9 +1938,6 @@ enum vxge_hw_status vxge_hw_vpath_open(
>         struct vxge_hw_vpath_attr *attr,
>         struct __vxge_hw_vpath_handle **vpath_handle);
> 
> -enum vxge_hw_status
> -__vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog);
> -
>  enum vxge_hw_status vxge_hw_vpath_close(
>         struct __vxge_hw_vpath_handle *vpath_handle);
> 
> @@ -2089,54 +1959,9 @@ enum vxge_hw_status vxge_hw_vpath_mtu_se
>         struct __vxge_hw_vpath_handle *vpath_handle,
>         u32 new_mtu);
> 
> -enum vxge_hw_status vxge_hw_vpath_stats_enable(
> -       struct __vxge_hw_vpath_handle *vpath_handle);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_stats_access(
> -       struct __vxge_hw_virtualpath    *vpath,
> -       u32                     operation,
> -       u32                     offset,
> -       u64                     *stat);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_xmac_tx_stats_get(
> -       struct __vxge_hw_virtualpath    *vpath,
> -       struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_xmac_rx_stats_get(
> -       struct __vxge_hw_virtualpath    *vpath,
> -       struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_stats_get(
> -       struct __vxge_hw_virtualpath *vpath,
> -       struct vxge_hw_vpath_stats_hw_info *hw_stats);
> -
>  void
>  vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp);
> 
> -enum vxge_hw_status
> -__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config);
> -
> -void
> -__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev);
> -
> -enum vxge_hw_status
> -__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg);
> -
> -enum vxge_hw_status
> -__vxge_hw_kdfc_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg,
> -       struct vxge_hw_vpath_reg __iomem *vpath_reg);
> -
> -enum vxge_hw_status
> -__vxge_hw_device_register_poll(
> -       void __iomem    *reg,
> -       u64 mask, u32 max_millis);
> 
>  #ifndef readq
>  static inline u64 readq(void __iomem *addr)
> @@ -2168,62 +1993,12 @@ static inline void __vxge_hw_pio_mem_wri
>         writel(val, addr);
>  }
> 
> -static inline enum vxge_hw_status
> -__vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
> -                         u64 mask, u32 max_millis)
> -{
> -       enum vxge_hw_status status = VXGE_HW_OK;
> -
> -       __vxge_hw_pio_mem_write32_lower((u32)vxge_bVALn(val64, 32, 32), addr);
> -       wmb();
> -       __vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32), addr);
> -       wmb();
> -
> -       status = __vxge_hw_device_register_poll(addr, mask, max_millis);
> -       return status;
> -}
> -
> -struct vxge_hw_toc_reg __iomem *
> -__vxge_hw_device_toc_get(void __iomem *bar0);
> -
> -enum vxge_hw_status
> -__vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev);
> -
> -void
> -__vxge_hw_device_id_get(struct __vxge_hw_device *hldev);
> -
> -void
> -__vxge_hw_device_host_info_get(struct __vxge_hw_device *hldev);
> -
>  enum vxge_hw_status
>  vxge_hw_device_flick_link_led(struct __vxge_hw_device *devh, u64 on_off);
> 
>  enum vxge_hw_status
> -__vxge_hw_device_initialize(struct __vxge_hw_device *hldev);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_pci_read(
> -       struct __vxge_hw_virtualpath    *vpath,
> -       u32                     phy_func_0,
> -       u32                     offset,
> -       u32                     *val);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_addr_get(
> -       u32 vp_id,
> -       struct vxge_hw_vpath_reg __iomem *vpath_reg,
> -       u8 (macaddr)[ETH_ALEN],
> -       u8 (macaddr_mask)[ETH_ALEN]);
> -
> -u32
> -__vxge_hw_vpath_func_id_get(
> -       u32 vp_id, struct vxge_hw_vpmgmt_reg __iomem *vpmgmt_reg);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
> -
> -enum vxge_hw_status
>  vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);
> +
>  /**
>   * vxge_debug
>   * @level: level of debug verbosity.
> --- a/drivers/net/vxge/vxge-main.c      2010-10-15 09:10:06.734401351 -0700
> +++ b/drivers/net/vxge/vxge-main.c      2010-10-15 10:13:44.000142249 -0700
> @@ -82,6 +82,16 @@ module_param_array(bw_percentage, uint,
> 
>  static struct vxge_drv_config *driver_config;
> 
> +static enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
> +                                            struct macInfo *mac);
> +static enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
> +                                            struct macInfo *mac);
> +static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac);
> +static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac);
> +static enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath);
> +static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath);
> +static enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
> +
>  static inline int is_vxge_card_up(struct vxgedev *vdev)
>  {
>         return test_bit(__VXGE_STATE_CARD_UP, &vdev->state);
> @@ -138,7 +148,7 @@ static inline void VXGE_COMPLETE_ALL_RX(
>   * This function is called during interrupt context to notify link up state
>   * change.
>   */
> -void
> +static void
>  vxge_callback_link_up(struct __vxge_hw_device *hldev)
>  {
>         struct net_device *dev = hldev->ndev;
> @@ -162,7 +172,7 @@ vxge_callback_link_up(struct __vxge_hw_d
>   * This function is called during interrupt context to notify link down state
>   * change.
>   */
> -void
> +static void
>  vxge_callback_link_down(struct __vxge_hw_device *hldev)
>  {
>         struct net_device *dev = hldev->ndev;
> @@ -354,7 +364,7 @@ static inline void vxge_post(int *dtr_cn
>   * If the interrupt is because of a received frame or if the receive ring
>   * contains fresh as yet un-processed frames, this function is called.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
>                  u8 t_code, void *userdata)
>  {
> @@ -531,7 +541,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *
>   * freed and frees all skbs whose data have already DMA'ed into the NICs
>   * internal memory.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
>                 enum vxge_hw_fifo_tcode t_code, void *userdata,
>                 struct sk_buff ***skb_ptr, int nr_skb, int *more)
> @@ -1246,7 +1256,7 @@ static int vxge_set_mac_addr(struct net_
>   *
>   * Enables the interrupts for the vpath
>  */
> -void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
> +static void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
>  {
>         struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
>         int msix_id = 0;
> @@ -1279,7 +1289,7 @@ void vxge_vpath_intr_enable(struct vxged
>   *
>   * Disables the interrupts for the vpath
>  */
> -void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
> +static void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
>  {
>         struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
>         int msix_id;
> @@ -1553,7 +1563,7 @@ out:
>   *
>   * driver may reset the chip on events of serr, eccerr, etc
>   */
> -int vxge_reset(struct vxgedev *vdev)
> +static int vxge_reset(struct vxgedev *vdev)
>  {
>         return do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
>  }
> @@ -1724,7 +1734,7 @@ static enum vxge_hw_status vxge_rth_conf
>         return status;
>  }
> 
> -int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
> +static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
>  {
>         struct vxge_mac_addrs *new_mac_entry;
>         u8 *mac_address = NULL;
> @@ -1757,7 +1767,8 @@ int vxge_mac_list_add(struct vxge_vpath
>  }
> 
>  /* Add a mac address to DA table */
> -enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
> +static enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
> +                                            struct macInfo *mac)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
>         struct vxge_vpath *vpath;
> @@ -1782,7 +1793,7 @@ enum vxge_hw_status vxge_add_mac_addr(st
>         return status;
>  }
> 
> -int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
> +static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
>  {
>         struct list_head *entry, *next;
>         u64 del_mac = 0;
> @@ -1807,7 +1818,8 @@ int vxge_mac_list_del(struct vxge_vpath
>         return FALSE;
>  }
>  /* delete a mac address from DA table */
> -enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
> +static enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
> +                                            struct macInfo *mac)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
>         struct vxge_vpath *vpath;
> @@ -1854,7 +1866,7 @@ static vxge_search_mac_addr_in_da_table(
>  }
> 
>  /* Store all vlan ids from the list to the vid table */
> -enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
> +static enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
>         struct vxgedev *vdev = vpath->vdev;
> @@ -1874,7 +1886,7 @@ enum vxge_hw_status vxge_restore_vpath_v
>  }
> 
>  /* Store all mac addresses from the list to the DA table */
> -enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
> +static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
>         struct macInfo mac_info;
> @@ -1916,7 +1928,7 @@ enum vxge_hw_status vxge_restore_vpath_m
>  }
> 
>  /* reset vpaths */
> -enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
> +static enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
>  {
>         enum vxge_hw_status status = VXGE_HW_OK;
>         struct vxge_vpath *vpath;
> @@ -1948,7 +1960,7 @@ enum vxge_hw_status vxge_reset_all_vpath
>  }
> 
>  /* close vpaths */
> -void vxge_close_vpaths(struct vxgedev *vdev, int index)
> +static void vxge_close_vpaths(struct vxgedev *vdev, int index)
>  {
>         struct vxge_vpath *vpath;
>         int i;
> @@ -1966,7 +1978,7 @@ void vxge_close_vpaths(struct vxgedev *v
>  }
> 
>  /* open vpaths */
> -int vxge_open_vpaths(struct vxgedev *vdev)
> +static int vxge_open_vpaths(struct vxgedev *vdev)
>  {
>         struct vxge_hw_vpath_attr attr;
>         enum vxge_hw_status status;
> @@ -2517,7 +2529,7 @@ static void vxge_poll_vp_lockup(unsigned
>   * Return value: '0' on success and an appropriate (-)ve integer as
>   * defined in errno.h file on failure.
>   */
> -int
> +static int
>  vxge_open(struct net_device *dev)
>  {
>         enum vxge_hw_status status;
> @@ -2721,7 +2733,7 @@ out0:
>  }
> 
>  /* Loop throught the mac address list and delete all the entries */
> -void vxge_free_mac_add_list(struct vxge_vpath *vpath)
> +static void vxge_free_mac_add_list(struct vxge_vpath *vpath)
>  {
> 
>         struct list_head *entry, *next;
> @@ -2745,7 +2757,7 @@ static void vxge_napi_del_all(struct vxg
>         }
>  }
> 
> -int do_vxge_close(struct net_device *dev, int do_io)
> +static int do_vxge_close(struct net_device *dev, int do_io)
>  {
>         enum vxge_hw_status status;
>         struct vxgedev *vdev;
> @@ -2856,7 +2868,7 @@ int do_vxge_close(struct net_device *dev
>   * Return value: '0' on success and an appropriate (-)ve integer as
>   * defined in errno.h file on failure.
>   */
> -int
> +static int
>  vxge_close(struct net_device *dev)
>  {
>         do_vxge_close(dev, 1);
> @@ -3113,10 +3125,10 @@ static const struct net_device_ops vxge_
>  #endif
>  };
> 
> -int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
> -                                  struct vxge_config *config,
> -                                  int high_dma, int no_of_vpath,
> -                                  struct vxgedev **vdev_out)
> +static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
> +                                         struct vxge_config *config,
> +                                         int high_dma, int no_of_vpath,
> +                                         struct vxgedev **vdev_out)
>  {
>         struct net_device *ndev;
>         enum vxge_hw_status status = VXGE_HW_OK;
> @@ -3164,7 +3176,7 @@ int __devinit vxge_device_register(struc
> 
>         ndev->watchdog_timeo = VXGE_LL_WATCH_DOG_TIMEOUT;
> 
> -       initialize_ethtool_ops(ndev);
> +       vxge_initialize_ethtool_ops(ndev);
> 
>         /* Allocate memory for vpath */
>         vdev->vpaths = kzalloc((sizeof(struct vxge_vpath)) *
> @@ -3249,7 +3261,7 @@ _out0:
>   *
>   * This function will unregister and free network device
>   */
> -void
> +static void
>  vxge_device_unregister(struct __vxge_hw_device *hldev)
>  {
>         struct vxgedev *vdev;
> --- a/drivers/net/vxge/vxge-main.h      2010-10-15 09:10:06.802404471 -0700
> +++ b/drivers/net/vxge/vxge-main.h      2010-10-15 10:13:51.232396166 -0700
> @@ -396,64 +396,7 @@ struct vxge_tx_priv {
>                 mod_timer(&timer, (jiffies + exp)); \
>         } while (0);
> 
> -int __devinit vxge_device_register(struct __vxge_hw_device *devh,
> -                                   struct vxge_config *config,
> -                                   int high_dma, int no_of_vpath,
> -                                   struct vxgedev **vdev);
> -
> -void vxge_device_unregister(struct __vxge_hw_device *devh);
> -
> -void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id);
> -
> -void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id);
> -
> -void vxge_callback_link_up(struct __vxge_hw_device *devh);
> -
> -void vxge_callback_link_down(struct __vxge_hw_device *devh);
> -
> -enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
> -       struct macInfo *mac);
> -
> -int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac);
> -
> -int vxge_reset(struct vxgedev *vdev);
> -
> -enum vxge_hw_status
> -vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
> -       u8 t_code, void *userdata);
> -
> -enum vxge_hw_status
> -vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
> -       enum vxge_hw_fifo_tcode t_code, void *userdata,
> -       struct sk_buff ***skb_ptr, int nr_skbs, int *more);
> -
> -int vxge_close(struct net_device *dev);
> -
> -int vxge_open(struct net_device *dev);
> -
> -void vxge_close_vpaths(struct vxgedev *vdev, int index);
> -
> -int vxge_open_vpaths(struct vxgedev *vdev);
> -
> -enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
> -
> -enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
> -       struct macInfo *mac);
> -
> -enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
> -       struct macInfo *mac);
> -
> -int vxge_mac_list_add(struct vxge_vpath *vpath,
> -       struct macInfo *mac);
> -
> -void vxge_free_mac_add_list(struct vxge_vpath *vpath);
> -
> -enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath);
> -
> -enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath);
> -
> -int do_vxge_close(struct net_device *dev, int do_io);
> -extern void initialize_ethtool_ops(struct net_device *ndev);
> +extern void vxge_initialize_ethtool_ops(struct net_device *ndev);
>  /**
>   * #define VXGE_DEBUG_INIT: debug for initialization functions
>   * #define VXGE_DEBUG_TX        : debug transmit related functions
> --- a/drivers/net/vxge/vxge-traffic.c   2010-10-15 09:10:06.750402084 -0700
> +++ b/drivers/net/vxge/vxge-traffic.c   2010-10-15 09:36:10.750557049 -0700
> @@ -17,6 +17,13 @@
>  #include "vxge-config.h"
>  #include "vxge-main.h"
> 
> +static enum vxge_hw_status
> +__vxge_hw_device_handle_error(struct __vxge_hw_device *hldev,
> +                             u32 vp_id, enum vxge_hw_event type);
> +static enum vxge_hw_status
> +__vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
> +                             u32 skip_alarms);
> +
>  /*
>   * vxge_hw_vpath_intr_enable - Enable vpath interrupts.
>   * @vp: Virtual Path handle.
> @@ -513,7 +520,7 @@ exit:
>   * Link up indication handler. The function is invoked by HW when
>   * Titan indicates that the link is up for programmable amount of time.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_device_handle_link_up_ind(struct __vxge_hw_device *hldev)
>  {
>         /*
> @@ -538,7 +545,7 @@ exit:
>   * Link down indication handler. The function is invoked by HW when
>   * Titan indicates that the link is down.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_device_handle_link_down_ind(struct __vxge_hw_device *hldev)
>  {
>         /*
> @@ -564,7 +571,7 @@ exit:
>   *
>   * Handle error.
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  __vxge_hw_device_handle_error(
>                 struct __vxge_hw_device *hldev,
>                 u32 vp_id,
> @@ -646,7 +653,7 @@ void vxge_hw_device_clear_tx_rx(struct _
>   * it swaps the reserve and free arrays.
>   *
>   */
> -enum vxge_hw_status
> +static enum vxge_hw_status
>  vxge_hw_channel_dtr_alloc(struct __vxge_hw_channel *channel, void **dtrh)
>  {
>         void **tmp_arr;
> @@ -692,7 +699,8 @@ _alloc_after_swap:
>   * Posts a dtr to work array.
>   *
>   */
> -void vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel, void *dtrh)
> +static void vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel,
> +                                    void *dtrh)
>  {
>         vxge_assert(channel->work_arr[channel->post_index] == NULL);
> 
> @@ -1658,37 +1666,6 @@ exit:
>  }
> 
>  /**
> - * vxge_hw_vpath_vid_get_next - Get the next vid entry for this vpath
> - *               from vlan id table.
> - * @vp: Vpath handle.
> - * @vid: Buffer to return vlan id
> - *
> - * Returns the next vlan id in the list for this vpath.
> - * see also: vxge_hw_vpath_vid_get
> - *
> - */
> -enum vxge_hw_status
> -vxge_hw_vpath_vid_get_next(struct __vxge_hw_vpath_handle *vp, u64 *vid)
> -{
> -       u64 data;
> -       enum vxge_hw_status status = VXGE_HW_OK;
> -
> -       if (vp == NULL) {
> -               status = VXGE_HW_ERR_INVALID_HANDLE;
> -               goto exit;
> -       }
> -
> -       status = __vxge_hw_vpath_rts_table_get(vp,
> -                       VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_LIST_NEXT_ENTRY,
> -                       VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_VID,
> -                       0, vid, &data);
> -
> -       *vid = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_VLAN_ID(*vid);
> -exit:
> -       return status;
> -}
> -
> -/**
>   * vxge_hw_vpath_vid_delete - Delete the vlan id entry for this vpath
>   *               to vlan id table.
>   * @vp: Vpath handle.
> @@ -1898,9 +1875,9 @@ exit:
>   * Process vpath alarms.
>   *
>   */
> -enum vxge_hw_status __vxge_hw_vpath_alarm_process(
> -                       struct __vxge_hw_virtualpath *vpath,
> -                       u32 skip_alarms)
> +static enum vxge_hw_status
> +__vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
> +                             u32 skip_alarms)
>  {
>         u64 val64;
>         u64 alarm_status;
> @@ -2265,36 +2242,6 @@ vxge_hw_vpath_msix_mask(struct __vxge_hw
>  }
> 
>  /**
> - * vxge_hw_vpath_msix_clear - Clear MSIX Vector.
> - * @vp: Virtual Path handle.
> - * @msix_id:  MSI ID
> - *
> - * The function clears the msix interrupt for the given msix_id
> - *
> - * Returns: 0,
> - * Otherwise, VXGE_HW_ERR_WRONG_IRQ if the msix index is out of range
> - * status.
> - * See also:
> - */
> -void
> -vxge_hw_vpath_msix_clear(struct __vxge_hw_vpath_handle *vp, int msix_id)
> -{
> -       struct __vxge_hw_device *hldev = vp->vpath->hldev;
> -       if (hldev->config.intr_mode ==
> -                       VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) {
> -               __vxge_hw_pio_mem_write32_upper(
> -                       (u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
> -                               &hldev->common_reg->
> -                                       clr_msix_one_shot_vec[msix_id%4]);
> -       } else {
> -               __vxge_hw_pio_mem_write32_upper(
> -                       (u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
> -                               &hldev->common_reg->
> -                                       clear_msix_mask_vect[msix_id%4]);
> -       }
> -}
> -
> -/**
>   * vxge_hw_vpath_msix_unmask - Unmask the MSIX Vector.
>   * @vp: Virtual Path handle.
>   * @msix_id:  MSI ID
> @@ -2316,22 +2263,6 @@ vxge_hw_vpath_msix_unmask(struct __vxge_
>  }
> 
>  /**
> - * vxge_hw_vpath_msix_mask_all - Mask all MSIX vectors for the vpath.
> - * @vp: Virtual Path handle.
> - *
> - * The function masks all msix interrupt for the given vpath
> - *
> - */
> -void
> -vxge_hw_vpath_msix_mask_all(struct __vxge_hw_vpath_handle *vp)
> -{
> -
> -       __vxge_hw_pio_mem_write32_upper(
> -               (u32)vxge_bVALn(vxge_mBIT(vp->vpath->vp_id), 0, 32),
> -               &vp->vpath->hldev->common_reg->set_msix_mask_all_vect);
> -}
> -
> -/**
>   * vxge_hw_vpath_inta_mask_tx_rx - Mask Tx and Rx interrupts.
>   * @vp: Virtual Path handle.
>   *
> --- a/drivers/net/vxge/vxge-traffic.h   2010-10-15 09:10:06.834405939 -0700
> +++ b/drivers/net/vxge/vxge-traffic.h   2010-10-15 10:14:43.870258247 -0700
> @@ -1749,14 +1749,6 @@ vxge_hw_mrpcim_stats_access(
>         u64 *stat);
> 
>  enum vxge_hw_status
> -vxge_hw_device_xmac_aggr_stats_get(struct __vxge_hw_device *devh, u32 port,
> -                                  struct vxge_hw_xmac_aggr_stats *aggr_stats);
> -
> -enum vxge_hw_status
> -vxge_hw_device_xmac_port_stats_get(struct __vxge_hw_device *devh, u32 port,
> -                                  struct vxge_hw_xmac_port_stats *port_stats);
> -
> -enum vxge_hw_status
>  vxge_hw_device_xmac_stats_get(struct __vxge_hw_device *devh,
>                               struct vxge_hw_xmac_stats *xmac_stats);
> 
> @@ -2117,49 +2109,10 @@ struct __vxge_hw_ring_rxd_priv {
>  #endif
>  };
> 
> -/* ========================= RING PRIVATE API ============================= */
> -u64
> -__vxge_hw_ring_first_block_address_get(
> -       struct __vxge_hw_ring *ringh);
> -
> -enum vxge_hw_status
> -__vxge_hw_ring_create(
> -       struct __vxge_hw_vpath_handle *vpath_handle,
> -       struct vxge_hw_ring_attr *attr);
> -
> -enum vxge_hw_status
> -__vxge_hw_ring_abort(
> -       struct __vxge_hw_ring *ringh);
> -
> -enum vxge_hw_status
> -__vxge_hw_ring_reset(
> -       struct __vxge_hw_ring *ringh);
> -
> -enum vxge_hw_status
> -__vxge_hw_ring_delete(
> -       struct __vxge_hw_vpath_handle *vpath_handle);
> -
>  /* ========================= FIFO PRIVATE API ============================= */
> 
>  struct vxge_hw_fifo_attr;
> 
> -enum vxge_hw_status
> -__vxge_hw_fifo_create(
> -       struct __vxge_hw_vpath_handle *vpath_handle,
> -       struct vxge_hw_fifo_attr *attr);
> -
> -enum vxge_hw_status
> -__vxge_hw_fifo_abort(
> -       struct __vxge_hw_fifo *fifoh);
> -
> -enum vxge_hw_status
> -__vxge_hw_fifo_reset(
> -       struct __vxge_hw_fifo *ringh);
> -
> -enum vxge_hw_status
> -__vxge_hw_fifo_delete(
> -       struct __vxge_hw_vpath_handle *vpath_handle);
> -
>  struct vxge_hw_mempool_cbs {
>         void (*item_func_alloc)(
>                         struct vxge_hw_mempool *mempoolh,
> @@ -2169,10 +2122,6 @@ struct vxge_hw_mempool_cbs {
>                         u32                     is_last);
>  };
> 
> -void
> -__vxge_hw_mempool_destroy(
> -       struct vxge_hw_mempool *mempool);
> -
>  #define VXGE_HW_VIRTUAL_PATH_HANDLE(vpath)                             \
>                 ((struct __vxge_hw_vpath_handle *)(vpath)->vpath_handles.next)
> 
> @@ -2195,61 +2144,10 @@ __vxge_hw_vpath_rts_table_set(
>         u64                     data2);
> 
>  enum vxge_hw_status
> -__vxge_hw_vpath_reset(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_sw_reset(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
>  __vxge_hw_vpath_enable(
>         struct __vxge_hw_device *devh,
>         u32                     vp_id);
> 
> -void
> -__vxge_hw_vpath_prc_configure(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_kdfc_configure(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_mac_configure(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_tim_configure(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_initialize(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
> -__vxge_hw_vp_initialize(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id,
> -       struct vxge_hw_vp_config        *config);
> -
> -void
> -__vxge_hw_vp_terminate(
> -       struct __vxge_hw_device *devh,
> -       u32                     vp_id);
> -
> -enum vxge_hw_status
> -__vxge_hw_vpath_alarm_process(
> -       struct __vxge_hw_virtualpath    *vpath,
> -       u32                     skip_alarms);
> -
>  void vxge_hw_device_intr_enable(
>         struct __vxge_hw_device *devh);
> 
> @@ -2321,11 +2219,6 @@ vxge_hw_vpath_vid_get(
>         u64                     *vid);
> 
>  enum vxge_hw_status
> -vxge_hw_vpath_vid_get_next(
> -       struct __vxge_hw_vpath_handle *vpath_handle,
> -       u64                     *vid);
> -
> -enum vxge_hw_status
>  vxge_hw_vpath_vid_delete(
>         struct __vxge_hw_vpath_handle *vpath_handle,
>         u64                     vid);
> @@ -2387,16 +2280,9 @@ vxge_hw_vpath_msix_mask(struct __vxge_hw
>  void vxge_hw_device_flush_io(struct __vxge_hw_device *devh);
> 
>  void
> -vxge_hw_vpath_msix_clear(struct __vxge_hw_vpath_handle *vpath_handle,
> -                        int msix_id);
> -
> -void
>  vxge_hw_vpath_msix_unmask(struct __vxge_hw_vpath_handle *vpath_handle,
>                           int msix_id);
> 
> -void
> -vxge_hw_vpath_msix_mask_all(struct __vxge_hw_vpath_handle *vpath_handle);
> -
>  enum vxge_hw_status vxge_hw_vpath_intr_enable(
>                                 struct __vxge_hw_vpath_handle *vpath_handle);
> 
> @@ -2415,12 +2301,6 @@ vxge_hw_channel_msix_mask(struct __vxge_
>  void
>  vxge_hw_channel_msix_unmask(struct __vxge_hw_channel *channelh, int msix_id);
> 
> -enum vxge_hw_status
> -vxge_hw_channel_dtr_alloc(struct __vxge_hw_channel *channel, void **dtrh);
> -
> -void
> -vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel, void *dtrh);
> -
>  void
>  vxge_hw_channel_dtr_try_complete(struct __vxge_hw_channel *channel,
>                                  void **dtrh);
> @@ -2436,18 +2316,4 @@ vxge_hw_channel_dtr_count(struct __vxge_
>  void
>  vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id);
> 
> -/* ========================== PRIVATE API ================================= */
> -
> -enum vxge_hw_status
> -__vxge_hw_device_handle_link_up_ind(struct __vxge_hw_device *hldev);
> -
> -enum vxge_hw_status
> -__vxge_hw_device_handle_link_down_ind(struct __vxge_hw_device *hldev);
> -
> -enum vxge_hw_status
> -__vxge_hw_device_handle_error(
> -               struct __vxge_hw_device *hldev,
> -               u32 vp_id,
> -               enum vxge_hw_event type);
> -
>  #endif
> --- a/drivers/net/vxge/vxge-ethtool.c   2010-10-15 09:10:06.718400615 -0700
> +++ b/drivers/net/vxge/vxge-ethtool.c   2010-10-15 10:13:39.927999492 -0700
> @@ -1142,7 +1142,7 @@ static const struct ethtool_ops vxge_eth
>         .get_ethtool_stats      = vxge_get_ethtool_stats,
>  };
> 
> -void initialize_ethtool_ops(struct net_device *ndev)
> +void vxge_initialize_ethtool_ops(struct net_device *ndev)
>  {
>         SET_ETHTOOL_OPS(ndev, &vxge_ethtool_ops);
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
