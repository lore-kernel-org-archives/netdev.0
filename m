From: "Dhananjay Phadke" <dhananjay@netxen.com>
Subject: Re: [2.6 patch] drivers/net/netxen/: cleanups
Date: Thu, 8 Nov 2007 10:55:04 -0800
Message-ID: <ab901500711081055j2a076b7br394c88c90e6e2830@mail.gmail.com>
References: <20071105170731.GP12045@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:49818 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760966AbXKHSzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 13:55:06 -0500
Received: by el-out-1112.google.com with SMTP id v27so101623ele
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2007 10:55:05 -0800 (PST)
In-Reply-To: <20071105170731.GP12045@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This looks good to me, I might chop off these #if 0 'ed functions in
my next round of patches.

Acked-by: Dhananjay Phadke <dhananjay@netxen.com>

On 11/5/07, Adrian Bunk <bunk@kernel.org> wrote:
> This patch contains the following cleanups:
> - static functions in .c files shouldn't be marked inline
> - make needlessly global code static
> - #if 0 unused code
>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
> ---
>
>  drivers/net/netxen/netxen_nic.h          |   14 ----
>  drivers/net/netxen/netxen_nic_hw.c       |   19 +++---
>  drivers/net/netxen/netxen_nic_hw.h       |    8 --
>  drivers/net/netxen/netxen_nic_init.c     |   70 ++++++++++++-----------
>  drivers/net/netxen/netxen_nic_isr.c      |    7 +-
>  drivers/net/netxen/netxen_nic_main.c     |    9 +-
>  drivers/net/netxen/netxen_nic_niu.c      |   26 +++++---
>  drivers/net/netxen/netxen_nic_phan_reg.h |    7 --
>  8 files changed, 76 insertions(+), 84 deletions(-)
>
> dbc7aeed37e41cd37a01cce259e5c0ab01f8dd88
> diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
> index fbc2553..ef9f986 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -1015,14 +1015,8 @@ int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter);
>  int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter);
>  int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter);
>  int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter);
> -int netxen_niu_xgbe_clear_phy_interrupts(struct netxen_adapter *adapter);
> -int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter);
>  void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter);
>  void netxen_nic_gbe_handle_phy_intr(struct netxen_adapter *adapter);
> -void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter, int port,
> -                                long enable);
> -void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter, int port,
> -                                 long enable);
>  int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
>                             __u32 * readval);
>  int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
> @@ -1045,7 +1039,6 @@ int netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
>                            int len);
>  void netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
>                                  unsigned long off, int data);
> -int netxen_nic_erase_pxe(struct netxen_adapter *adapter);
>
>  /* Functions from netxen_nic_init.c */
>  void netxen_free_adapter_offload(struct netxen_adapter *adapter);
> @@ -1064,15 +1057,10 @@ int netxen_flash_erase_secondary(struct netxen_adapter *adapter);
>  int netxen_flash_erase_primary(struct netxen_adapter *adapter);
>  void netxen_halt_pegs(struct netxen_adapter *adapter);
>
> -int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data);
>  int netxen_rom_se(struct netxen_adapter *adapter, int addr);
> -int netxen_do_rom_se(struct netxen_adapter *adapter, int addr);
>
>  /* Functions from netxen_nic_isr.c */
>  int netxen_nic_link_ok(struct netxen_adapter *adapter);
> -void netxen_nic_isr_other(struct netxen_adapter *adapter);
> -void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 link);
> -void netxen_handle_port_int(struct netxen_adapter *adapter, u32 enable);
>  void netxen_initialize_adapter_sw(struct netxen_adapter *adapter);
>  void netxen_initialize_adapter_hw(struct netxen_adapter *adapter);
>  void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
> @@ -1089,8 +1077,6 @@ int netxen_nic_tx_has_work(struct netxen_adapter *adapter);
>  void netxen_watchdog_task(struct work_struct *work);
>  void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx,
>                             u32 ringid);
> -void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, u32 ctx,
> -                                u32 ringid);
>  int netxen_process_cmd_ring(unsigned long data);
>  u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
>  void netxen_nic_set_multi(struct net_device *netdev);
> diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
> index 2c19b8d..b2c7861 100644
> --- a/drivers/net/netxen/netxen_nic_hw.c
> +++ b/drivers/net/netxen/netxen_nic_hw.c
> @@ -33,7 +33,6 @@
>
>  #include "netxen_nic.h"
>  #include "netxen_nic_hw.h"
> -#define DEFINE_GLOBAL_RECV_CRB
>  #include "netxen_nic_phan_reg.h"
>
>
> @@ -244,12 +243,15 @@ struct netxen_recv_crb recv_crb_registers[] = {
>         },
>  };
>
> -u64 ctx_addr_sig_regs[][3] = {
> +static u64 ctx_addr_sig_regs[][3] = {
>         {NETXEN_NIC_REG(0x188), NETXEN_NIC_REG(0x18c), NETXEN_NIC_REG(0x1c0)},
>         {NETXEN_NIC_REG(0x190), NETXEN_NIC_REG(0x194), NETXEN_NIC_REG(0x1c4)},
>         {NETXEN_NIC_REG(0x198), NETXEN_NIC_REG(0x19c), NETXEN_NIC_REG(0x1c8)},
>         {NETXEN_NIC_REG(0x1a0), NETXEN_NIC_REG(0x1a4), NETXEN_NIC_REG(0x1cc)}
>  };
> +#define CRB_CTX_ADDR_REG_LO(FUNC_ID)           (ctx_addr_sig_regs[FUNC_ID][0])
> +#define CRB_CTX_ADDR_REG_HI(FUNC_ID)           (ctx_addr_sig_regs[FUNC_ID][2])
> +#define CRB_CTX_SIGNATURE_REG(FUNC_ID)         (ctx_addr_sig_regs[FUNC_ID][1])
>
>
>  /*  PCI Windowing for DDR regions.  */
> @@ -279,8 +281,8 @@ u64 ctx_addr_sig_regs[][3] = {
>
>  #define NETXEN_NIC_WINDOW_MARGIN 0x100000
>
> -unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
> -                                       unsigned long long addr);
> +static unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
> +                                              unsigned long long addr);
>  void netxen_free_hw_resources(struct netxen_adapter *adapter);
>
>  int netxen_nic_set_mac(struct net_device *netdev, void *p)
> @@ -886,11 +888,10 @@ void netxen_nic_read_w0(struct netxen_adapter *adapter, u32 index, u32 * value)
>         netxen_nic_pci_change_crbwindow(adapter, 1);
>  }
>
> -int netxen_pci_set_window_warning_count = 0;
> +static int netxen_pci_set_window_warning_count = 0;
>
> -unsigned long
> -netxen_nic_pci_set_window(struct netxen_adapter *adapter,
> -                         unsigned long long addr)
> +static  unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
> +                                               unsigned long long addr)
>  {
>         static int ddr_mn_window = -1;
>         static int qdr_sn_window = -1;
> @@ -952,6 +953,7 @@ netxen_nic_pci_set_window(struct netxen_adapter *adapter,
>         return addr;
>  }
>
> +#if 0
>  int
>  netxen_nic_erase_pxe(struct netxen_adapter *adapter)
>  {
> @@ -962,6 +964,7 @@ netxen_nic_erase_pxe(struct netxen_adapter *adapter)
>         }
>         return 0;
>  }
> +#endif  /*  0  */
>
>  int netxen_nic_get_board_info(struct netxen_adapter *adapter)
>  {
> diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
> index 245bf13..197e1fc 100644
> --- a/drivers/net/netxen/netxen_nic_hw.h
> +++ b/drivers/net/netxen/netxen_nic_hw.h
> @@ -520,15 +520,11 @@ int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
>  int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
>                                        netxen_niu_prom_mode_t mode);
>
> -/* get/set the MAC address for a given MAC */
> -int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
> -                          netxen_ethernet_macaddr_t * addr);
> +/* set the MAC address for a given MAC */
>  int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
>                            netxen_ethernet_macaddr_t addr);
>
> -/* XG versons */
> -int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
> -                             netxen_ethernet_macaddr_t * addr);
> +/* XG version */
>  int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
>                               netxen_ethernet_macaddr_t addr);
>
> diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
> index 3758926..8667e8f 100644
> --- a/drivers/net/netxen/netxen_nic_init.c
> +++ b/drivers/net/netxen/netxen_nic_init.c
> @@ -54,13 +54,17 @@ static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
>
>  #define NETXEN_NIC_XDMA_RESET 0x8000ff
>
> -static inline void
> -netxen_nic_locked_write_reg(struct netxen_adapter *adapter,
> -                           unsigned long off, int *data)
> +static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
> +                                       uint32_t ctx, uint32_t ringid);
> +
> +#if 0
> +static void netxen_nic_locked_write_reg(struct netxen_adapter *adapter,
> +                                       unsigned long off, int *data)
>  {
>         void __iomem *addr = pci_base_offset(adapter, off);
>         writel(*data, addr);
>  }
> +#endif  /*  0  */
>
>  static void crb_addr_transform_setup(void)
>  {
> @@ -255,7 +259,7 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
>   * netxen_decode_crb_addr(0 - utility to translate from internal Phantom CRB
>   * address to external PCI CRB address.
>   */
> -u32 netxen_decode_crb_addr(u32 addr)
> +static u32 netxen_decode_crb_addr(u32 addr)
>  {
>         int i;
>         u32 base_addr, offset, pci_base;
> @@ -282,7 +286,7 @@ static long rom_max_timeout = 100;
>  static long rom_lock_timeout = 10000;
>  static long rom_write_timeout = 700;
>
> -static inline int rom_lock(struct netxen_adapter *adapter)
> +static int rom_lock(struct netxen_adapter *adapter)
>  {
>         int iter;
>         u32 done = 0;
> @@ -312,7 +316,7 @@ static inline int rom_lock(struct netxen_adapter *adapter)
>         return 0;
>  }
>
> -int netxen_wait_rom_done(struct netxen_adapter *adapter)
> +static int netxen_wait_rom_done(struct netxen_adapter *adapter)
>  {
>         long timeout = 0;
>         long done = 0;
> @@ -329,7 +333,7 @@ int netxen_wait_rom_done(struct netxen_adapter *adapter)
>         return 0;
>  }
>
> -static inline int netxen_rom_wren(struct netxen_adapter *adapter)
> +static int netxen_rom_wren(struct netxen_adapter *adapter)
>  {
>         /* Set write enable latch in ROM status register */
>         netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
> @@ -341,15 +345,15 @@ static inline int netxen_rom_wren(struct netxen_adapter *adapter)
>         return 0;
>  }
>
> -static inline unsigned int netxen_rdcrbreg(struct netxen_adapter *adapter,
> -                                          unsigned int addr)
> +static unsigned int netxen_rdcrbreg(struct netxen_adapter *adapter,
> +                                   unsigned int addr)
>  {
>         unsigned int data = 0xdeaddead;
>         data = netxen_nic_reg_read(adapter, addr);
>         return data;
>  }
>
> -static inline int netxen_do_rom_rdsr(struct netxen_adapter *adapter)
> +static int netxen_do_rom_rdsr(struct netxen_adapter *adapter)
>  {
>         netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE,
>                              M25P_INSTR_RDSR);
> @@ -359,7 +363,7 @@ static inline int netxen_do_rom_rdsr(struct netxen_adapter *adapter)
>         return netxen_rdcrbreg(adapter, NETXEN_ROMUSB_ROM_RDATA);
>  }
>
> -static inline void netxen_rom_unlock(struct netxen_adapter *adapter)
> +static void netxen_rom_unlock(struct netxen_adapter *adapter)
>  {
>         u32 val;
>
> @@ -368,7 +372,7 @@ static inline void netxen_rom_unlock(struct netxen_adapter *adapter)
>
>  }
>
> -int netxen_rom_wip_poll(struct netxen_adapter *adapter)
> +static int netxen_rom_wip_poll(struct netxen_adapter *adapter)
>  {
>         long timeout = 0;
>         long wip = 1;
> @@ -385,8 +389,8 @@ int netxen_rom_wip_poll(struct netxen_adapter *adapter)
>         return 0;
>  }
>
> -static inline int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
> -                                   int data)
> +static int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
> +                            int data)
>  {
>         if (netxen_rom_wren(adapter)) {
>                 return -1;
> @@ -404,8 +408,8 @@ static inline int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
>         return netxen_rom_wip_poll(adapter);
>  }
>
> -static inline int
> -do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
> +static int do_rom_fast_read(struct netxen_adapter *adapter,
> +                           int addr, int *valp)
>  {
>         cond_resched();
>
> @@ -427,9 +431,8 @@ do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
>         return 0;
>  }
>
> -static inline int
> -do_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
> -                       u8 *bytes, size_t size)
> +static int do_rom_fast_read_words(struct netxen_adapter *adapter, int addr,
> +                                 u8 *bytes, size_t size)
>  {
>         int addridx;
>         int ret = 0;
> @@ -473,6 +476,7 @@ int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
>         return ret;
>  }
>
> +#if 0
>  int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data)
>  {
>         int ret = 0;
> @@ -484,9 +488,10 @@ int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data)
>         netxen_rom_unlock(adapter);
>         return ret;
>  }
> +#endif  /*  0  */
>
> -static inline int do_rom_fast_write_words(struct netxen_adapter *adapter,
> -                                               int addr, u8 *bytes, size_t size)
> +static int do_rom_fast_write_words(struct netxen_adapter *adapter,
> +                                  int addr, u8 *bytes, size_t size)
>  {
>         int addridx = addr;
>         int ret = 0;
> @@ -548,7 +553,7 @@ int netxen_rom_fast_write_words(struct netxen_adapter *adapter, int addr,
>         return ret;
>  }
>
> -int netxen_rom_wrsr(struct netxen_adapter *adapter, int data)
> +static int netxen_rom_wrsr(struct netxen_adapter *adapter, int data)
>  {
>         int ret;
>
> @@ -567,7 +572,7 @@ int netxen_rom_wrsr(struct netxen_adapter *adapter, int data)
>         return netxen_rom_wip_poll(adapter);
>  }
>
> -int netxen_rom_rdsr(struct netxen_adapter *adapter)
> +static int netxen_rom_rdsr(struct netxen_adapter *adapter)
>  {
>         int ret;
>
> @@ -632,7 +637,7 @@ out_kfree:
>         return ret;
>  }
>
> -int netxen_do_rom_se(struct netxen_adapter *adapter, int addr)
> +static int netxen_do_rom_se(struct netxen_adapter *adapter, int addr)
>  {
>         netxen_rom_wren(adapter);
>         netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
> @@ -646,7 +651,7 @@ int netxen_do_rom_se(struct netxen_adapter *adapter, int addr)
>         return netxen_rom_wip_poll(adapter);
>  }
>
> -void check_erased_flash(struct netxen_adapter *adapter, int addr)
> +static void check_erased_flash(struct netxen_adapter *adapter, int addr)
>  {
>         int i;
>         int val;
> @@ -682,8 +687,8 @@ int netxen_rom_se(struct netxen_adapter *adapter, int addr)
>         return ret;
>  }
>
> -int
> -netxen_flash_erase_sections(struct netxen_adapter *adapter, int start, int end)
> +static int netxen_flash_erase_sections(struct netxen_adapter *adapter,
> +                                      int start, int end)
>  {
>         int ret = FLASH_SUCCESS;
>         int i;
> @@ -990,7 +995,7 @@ int netxen_nic_rx_has_work(struct netxen_adapter *adapter)
>         return 0;
>  }
>
> -static inline int netxen_nic_check_temp(struct netxen_adapter *adapter)
> +static int netxen_nic_check_temp(struct netxen_adapter *adapter)
>  {
>         struct net_device *netdev = adapter->netdev;
>         uint32_t temp, temp_state, temp_val;
> @@ -1064,9 +1069,8 @@ void netxen_watchdog_task(struct work_struct *work)
>   * and if the number of receives exceeds RX_BUFFERS_REFILL, then we
>   * invoke the routine to send more rx buffers to the Phantom...
>   */
> -void
> -netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
> -                  struct status_desc *desc)
> +static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
> +                              struct status_desc *desc)
>  {
>         struct pci_dev *pdev = adapter->pdev;
>         struct net_device *netdev = adapter->netdev;
> @@ -1460,8 +1464,8 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
>         }
>  }
>
> -void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ctx,
> -                                uint32_t ringid)
> +static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
> +                                       uint32_t ctx, uint32_t ringid)
>  {
>         struct pci_dev *pdev = adapter->ahw.pdev;
>         struct sk_buff *skb;
> diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
> index b2de6b6..0a261de 100644
> --- a/drivers/net/netxen/netxen_nic_isr.c
> +++ b/drivers/net/netxen/netxen_nic_isr.c
> @@ -66,7 +66,8 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
>         return stats;
>  }
>
> -void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 link)
> +static void netxen_indicate_link_status(struct netxen_adapter *adapter,
> +                                       u32 link)
>  {
>         struct net_device *netdev = adapter->netdev;
>
> @@ -76,6 +77,7 @@ void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 link)
>                 netif_carrier_off(netdev);
>  }
>
> +#if 0
>  void netxen_handle_port_int(struct netxen_adapter *adapter, u32 enable)
>  {
>         __u32 int_src;
> @@ -134,8 +136,9 @@ void netxen_handle_port_int(struct netxen_adapter *adapter, u32 enable)
>         if (adapter->enable_phy_interrupts)
>                 adapter->enable_phy_interrupts(adapter);
>  }
> +#endif  /*  0  */
>
> -void netxen_nic_isr_other(struct netxen_adapter *adapter)
> +static void netxen_nic_isr_other(struct netxen_adapter *adapter)
>  {
>         int portno = adapter->portnum;
>         u32 val, linkup, qg_linksup;
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index a80f0cd..d0d1f05 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -89,8 +89,8 @@ MODULE_DEVICE_TABLE(pci, netxen_pci_tbl);
>  struct workqueue_struct *netxen_workq;
>  static void netxen_watchdog(unsigned long);
>
> -static inline void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
> -                                                       uint32_t crb_producer)
> +static void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
> +                                          uint32_t crb_producer)
>  {
>         switch (adapter->portnum) {
>                 case 0:
> @@ -118,8 +118,8 @@ static inline void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter
>         }
>  }
>
> -static inline void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
> -                                                       u32 crb_consumer)
> +static void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
> +                                          u32 crb_consumer)
>  {
>         switch (adapter->portnum) {
>                 case 0:
> @@ -148,7 +148,6 @@ static inline void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter
>  }
>
>  #define        ADAPTER_LIST_SIZE 12
> -int netxen_cards_found;
>
>  static void netxen_nic_disable_int(struct netxen_adapter *adapter)
>  {
> diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
> index 5b9e1b3..94e096c 100644
> --- a/drivers/net/netxen/netxen_nic_niu.c
> +++ b/drivers/net/netxen/netxen_nic_niu.c
> @@ -40,7 +40,7 @@
>
>  static long phy_lock_timeout = 100000000;
>
> -static inline int phy_lock(struct netxen_adapter *adapter)
> +static int phy_lock(struct netxen_adapter *adapter)
>  {
>         int i;
>         int done = 0, timeout = 0;
> @@ -68,7 +68,7 @@ static inline int phy_lock(struct netxen_adapter *adapter)
>         return 0;
>  }
>
> -static inline int phy_unlock(struct netxen_adapter *adapter)
> +static int phy_unlock(struct netxen_adapter *adapter)
>  {
>         readl(pci_base_offset(adapter, NETXEN_PCIE_REG(PCIE_SEM3_UNLOCK)));
>
> @@ -300,13 +300,15 @@ int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter)
>         return result;
>  }
>
> +#if 0
>  int netxen_niu_xgbe_clear_phy_interrupts(struct netxen_adapter *adapter)
>  {
>         netxen_crb_writelit_adapter(adapter, NETXEN_NIU_ACTIVE_INT, -1);
>         return 0;
>  }
> +#endif  /*  0  */
>
> -int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter)
> +static int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter)
>  {
>         int result = 0;
>         if (0 !=
> @@ -322,8 +324,8 @@ int netxen_niu_gbe_clear_phy_interrupts(struct netxen_adapter *adapter)
>   * netxen_niu_gbe_set_mii_mode- Set 10/100 Mbit Mode for GbE MAC
>   *
>   */
> -void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
> -                                int port, long enable)
> +static void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
> +                                       int port, long enable)
>  {
>         netxen_crb_writelit_adapter(adapter, NETXEN_NIU_MODE, 0x2);
>         netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
> @@ -360,8 +362,8 @@ void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
>  /*
>   * netxen_niu_gbe_set_gmii_mode- Set GbE Mode for GbE MAC
>   */
> -void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
> -                                 int port, long enable)
> +static void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
> +                                        int port, long enable)
>  {
>         netxen_crb_writelit_adapter(adapter, NETXEN_NIU_MODE, 0x2);
>         netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
> @@ -464,6 +466,7 @@ int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
>         return 0;
>  }
>
> +#if 0
>  /*
>   * netxen_niu_gbe_handle_phy_interrupt - Handles GbE PHY interrupts
>   * @param enable 0 means don't enable the port
> @@ -559,13 +562,14 @@ int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
>         }
>         return result;
>  }
> +#endif  /*  0  */
>
>  /*
>   * Return the current station MAC address.
>   * Note that the passed-in value must already be in network byte order.
>   */
> -int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
> -                          netxen_ethernet_macaddr_t * addr)
> +static int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
> +                                 netxen_ethernet_macaddr_t * addr)
>  {
>         u32 stationhigh;
>         u32 stationlow;
> @@ -636,6 +640,7 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
>         return 0;
>  }
>
> +#if 0
>  /* Enable a GbE interface */
>  int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
>                                int port, netxen_niu_gbe_ifmode_t mode)
> @@ -713,6 +718,7 @@ int netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
>                 return -EIO;
>         return 0;
>  }
> +#endif  /*  0  */
>
>  /* Disable a GbE interface */
>  int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
> @@ -853,6 +859,7 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
>         return 0;
>  }
>
> +#if 0
>  /*
>   * Return the current station MAC address.
>   * Note that the passed-in value must already be in network byte order.
> @@ -883,6 +890,7 @@ int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter,
>
>         return 0;
>  }
> +#endif  /*  0  */
>
>  int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
>                                        netxen_niu_prom_mode_t mode)
> diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
> index 10fe6fa..a6c28de 100644
> --- a/drivers/net/netxen/netxen_nic_phan_reg.h
> +++ b/drivers/net/netxen/netxen_nic_phan_reg.h
> @@ -165,14 +165,7 @@ struct netxen_recv_crb {
>         u32 crb_status_ring_size;
>  };
>
> -#if defined(DEFINE_GLOBAL_RECV_CRB)
> -#else
>  extern struct netxen_recv_crb recv_crb_registers[];
> -extern u64 ctx_addr_sig_regs[][3];
> -#endif                         /* DEFINE_GLOBAL_RECEIVE_CRB */
> -#define CRB_CTX_ADDR_REG_LO(FUNC_ID)           (ctx_addr_sig_regs[FUNC_ID][0])
> -#define CRB_CTX_ADDR_REG_HI(FUNC_ID)           (ctx_addr_sig_regs[FUNC_ID][2])
> -#define CRB_CTX_SIGNATURE_REG(FUNC_ID)         (ctx_addr_sig_regs[FUNC_ID][1])
>
>  /*
>   * Temperature control.
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
