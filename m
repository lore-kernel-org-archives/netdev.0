From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Wed, 8 Sep 2010 22:52:47 +0900
Message-ID: <003901cb4f5d$bf977c80$66f8800a@maildom.okisemi.com>
References: <4C81019E.1010808@dsn.okisemi.com> <4C8123D6.8020001@suse.cz>
Cc: "Randy Dunlap" <randy.dunlap@oracle.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"ML netdev" <netdev@vger.kernel.org>,
	"MeeGo" <meego-dev@meego.com>, "Maxime Bizon" <mbizon@freebox.fr>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"John Linn" <john.linn@xilinx.com>,
	"Joe Perches" <joe@perches.com>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "Jiri Slaby" <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:28247 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750847Ab0IHN5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 09:57:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri

I have some questions.
Please see out inline comments.

Thanks, Ohtake

----- Original Message ----- 
From: "Jiri Slaby" <jslaby@suse.cz>
To: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Cc: "Randy Dunlap" <randy.dunlap@oracle.com>; "Ralf Baechle" <ralf@linux-mips.org>; "ML netdev"
<netdev@vger.kernel.org>; "MeeGo" <meego-dev@meego.com>; "Maxime Bizon" <mbizon@freebox.fr>; "LKML"
<linux-kernel@vger.kernel.org>; "Kristoffer Glembo" <kristoffer@gaisler.com>; "John Linn" <john.linn@xilinx.com>; "Joe
Perches" <joe@perches.com>; "Greg Rose" <gregory.v.rose@intel.com>; "David S. Miller" <davem@davemloft.net>; "Wang, Yong
Y" <yong.y.wang@intel.com>; "Wang, Qi" <qi.wang@intel.com>; "Toshiharu Okada" <okada533@dsn.okisemi.com>; "Tomoya
Morinaga" <morinaga526@dsn.okisemi.com>; "Takahiro Shimizu" <shimizu394@dsn.okisemi.com>; "Intel OTC"
<joel.clark@intel.com>; "Foster, Margie" <margie.foster@intel.com>; "Andrew" <andrew.chih.howe.khor@intel.com>
Sent: Saturday, September 04, 2010 1:35 AM
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH


> Hi, I wrote few comments below.
>
> On 09/03/2010 04:09 PM, Masayuki Ohtake wrote:
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -2004,7 +2004,6 @@ menuconfig NETDEV_1000
> >    If you say N, all options in this submenu will be skipped and disabled.
> >
> >  if NETDEV_1000
> > -
> >  config ACENIC
> >  tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
> >  depends on PCI
>
> This hunk is unwanted, I think.

[masa]
This will be deleted.


>
> > --- /dev/null
> > +++ b/drivers/net/pch_gbe/pch_gbe.h
> > @@ -0,0 +1,683 @@
> ...
> > +/**
> > + * pch_gbe_regs_mac_adr - Structure holding values of mac address registers
> > + * @high Denotes the 1st to 4th byte from the initial of MAC address
> > + * @low Denotes the 5th to 6th byte from the initial of MAC address
> > + */
> > +struct pch_gbe_regs_mac_adr {
> > + u32 high;
> > + u32 low;
> > +};
> > +/**
> > + * pch_udc_regs - Structure holding values of MAC registers
> > + */
> > +struct pch_gbe_regs {
> > + u32 INT_ST;
> > + u32 INT_EN;
> > + u32 MODE;
> > + u32 RESET;
> > + u32 TCPIP_ACC;
> > + u32 EX_LIST;
> > + u32 INT_ST_HOLD;
> > + u32 PHY_INT_CTRL;
> > + u32 MAC_RX_EN;
> > + u32 RX_FCTRL;
> > + u32 PAUSE_REQ;
> > + u32 RX_MODE;
> > + u32 TX_MODE;
> > + u32 RX_FIFO_ST;
> > + u32 TX_FIFO_ST;
> > + u32 TX_FID;
> > + u32 TX_RESULT;
> > + u32 PAUSE_PKT1;
> > + u32 PAUSE_PKT2;
> > + u32 PAUSE_PKT3;
> > + u32 PAUSE_PKT4;
> > + u32 PAUSE_PKT5;
> > + u32 reserve[2];
> > + struct pch_gbe_regs_mac_adr mac_adr[16];
> > + u32 ADDR_MASK;
> > + u32 MIIM;
> > + u32 reserve2;
> > + u32 RGMII_ST;
> > + u32 RGMII_CTRL;
> > + u32 reserve3[3];
> > + u32 DMA_CTRL;
> > + u32 reserve4[3];
> > + u32 RX_DSC_BASE;
> > + u32 RX_DSC_SIZE;
> > + u32 RX_DSC_HW_P;
> > + u32 RX_DSC_HW_P_HLD;
> > + u32 RX_DSC_SW_P;
> > + u32 reserve5[3];
> > + u32 TX_DSC_BASE;
> > + u32 TX_DSC_SIZE;
> > + u32 TX_DSC_HW_P;
> > + u32 TX_DSC_HW_P_HLD;
> > + u32 TX_DSC_SW_P;
> > + u32 reserve6[3];
> > + u32 RX_DMA_ST;
> > + u32 TX_DMA_ST;
> > + u32 reserve7[2];
> > + u32 WOL_ST;
> > + u32 WOL_CTRL;
> > + u32 WOL_ADDR_MASK;
> > +};
>
> Shouldn't that be packed? As it is full of u32, probably not, but
> consider this comment when thinking about all structures you have here.

[masa]
packed?
I am sorry, I can not understand.
Please let me know details.

>
> > +/* Device Driver infomation */
> > +#define DRV_STRING      "PCH Network Driver"
> > +#define DRV_EXT         "-NAPI"
> > +#define DRV_VERSION     "0.95"DRV_EXT
> > +#define DRV_DESCRIPTION \
> > + "OKI semiconductor sample Linux driver for PCH Gigabit ethernet"
> > +#define DRV_COPYRIGHT   "Copyright(c) 2010 OKI semiconductor"
>
> Why you need these defines?

[masa]
This will be deleted.

>
> > +struct pch_gbe_hw {
> > + void *back;
> > +
> > + struct pch_gbe_regs  __iomem *reg;
> > + spinlock_t miim_lock;
> > +
> > + const struct pch_gbe_functions *func;
> > + struct pch_gbe_mac_info mac;
> > + struct pch_gbe_phy_info phy;
> > + struct pch_gbe_bus_info bus;
> > +
> > + u16 vendor_id;
> > + u16 device_id;
> > + u16 subsystem_vendor_id;
> > + u16 subsystem_device_id;
> > + u8 revision_id;
>
> What you need these IDs for?

[masa]
This will be deleted.


>
> > +};
> > +
> > +/**
> > + * struct pch_gbe_rx_desc - Receive Descriptor
> > + * @buffer_addr: RX Frame Buffer Address
> > + * @tcp_ip_status: TCP/IP Accelerator Status
> > + * @rx_words_eob: RX word count and Byte position
> > + * @gbec_status: GMAC Status
> > + * @dma_status: DMA Status
> > + * @reserved1: Reserved
> > + * @reserved2: Reserved
> > + */
> > +struct pch_gbe_rx_desc {
> > + u32 buffer_addr;
> > + u32 tcp_ip_status;
> > + u16 rx_words_eob;
> > + u16 gbec_status;
> > + u8 dma_status;
> > + u8 reserved1;
> > + u16 reserved2;
> > +};
> > +
> > +/**
> > + * struct pch_gbe_tx_desc - Transmit Descriptor
> > + * @buffer_addr: TX Frame Buffer Address
> > + * @length: Data buffer length
> > + * @reserved1: Reserved
> > + * @tx_words_eob: TX word count and Byte position
> > + * @tx_frame_ctrl: TX Frame Control
> > + * @dma_status: DMA Status
> > + * @reserved2: Reserved
> > + * @gbec_status: GMAC Status
> > + */
> > +struct pch_gbe_tx_desc {
> > + u32 buffer_addr;
> > + u16 length;
> > + u16 reserved1;
> > + u16 tx_words_eob;
> > + u16 tx_frame_ctrl;
> > + u8 dma_status;
> > + u8 reserved2;
> > + u16 gbec_status;
> > +};
>
> packed?

[masa]
Ditto


>
> > +struct pch_gbe_adapter {
> > + spinlock_t stats_lock;
> > + spinlock_t tx_queue_lock;
>
> unitialized

[masa]
This will be modified.

>
> > + spinlock_t int_en_lock;
>
> unused


[masa]
This will be deleted.

>
> > + spinlock_t ethtool_lock;
> > + atomic_t irq_sem;
> > + struct net_device *netdev;
> > + struct pci_dev *pdev;
> > + struct net_device_stats net_stats;
> > + struct net_device *polling_netdev;
> > + struct napi_struct napi;
> > + struct pch_gbe_hw hw;
> > + struct pch_gbe_hw_stats stats;
> > + struct work_struct reset_task;
> > + struct mii_if_info mii;
> > + struct timer_list watchdog_timer;
> > + u32 wake_up_evt;
> > + u32 *config_space;
> > + struct timer_list blink_timer;
>
> unused

[masa]
This will be deleted.

>
> > + unsigned long led_status;
> > + struct pch_gbe_tx_ring *tx_ring;
> > + struct pch_gbe_rx_ring *rx_ring;
> > + unsigned long rx_buffer_len;
> > + unsigned long tx_queue_len;
> > + bool rx_csum;
> > + bool tx_csum;
> > + bool have_msi;
> > +};
> > +
> > +/**
> > + * enum pch_gbe_state_t - Driver Status
> > + * @__PCH_GBE_TESTING: Testing
> > + * @__PCH_GBE_RESETTING: Reseting
> > + */
> > +enum pch_gbe_state_t {
> > + __PCH_GBE_TESTING,
> > + __PCH_GBE_RESETTING,
> > +};
>
> Why _t? It's not a typedef.

[masa]
This will be deleted.

>
> > --- /dev/null
> > +++ b/drivers/net/pch_gbe/pch_gbe_api.c
> > @@ -0,0 +1,246 @@
> ...
> > +/**
> > + * pch_gbe_hal_setup_init_funcs - Initializes function pointers
> > + * @hw: Pointer to the HW structure
> > + * Returns
> > + * 0: Successfully
> > + * ENOSYS: Function is not registered
> > + */
> > +inline s32 pch_gbe_hal_setup_init_funcs(struct pch_gbe_hw *hw)
> > +{
> > + if (!hw->reg) {
> > + pr_err("ERROR: Registers not mapped\n");
>
> No pr_fmt in this file, this line is helpless. Reconsider using dev_*
> and netdev_* (dev_err, netdev_err and alike) printing wherever possible.

[masa]
This will be modified pch_gbe.h.
"#define pr_fmt(fmt) KBUILD_MODNAME ": " tmt" is added

>
> > + return -ENOSYS;
> > + }
> > + pch_gbe_plat_init_function_pointers(hw);
> > + return 0;
> > +}
> > +
> > +/**
> > + * pch_gbe_hal_get_bus_info - Obtain bus information for adapter
> > + * @hw: Pointer to the HW structure
> > + */
> > +inline void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw)
> > +{
> > + if (!hw->func->get_bus_info)
> > + pr_err("ERROR: configuration\n");
>
> Ditto. And on some more places too.
>
> > --- /dev/null
> > +++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> > @@ -0,0 +1,620 @@
> ...
> > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > +#include <linux/pci.h>
> > +#include <linux/ethtool.h>
> > +
> > +#include "pch_gbe.h"
> > +#include "pch_gbe_api.h"
> > +
> > +#define FUNC_ENTER() pr_devel("ethtool: %s enter\n", __func__)
> > +#define FUNC_EXIT() pr_devel("ethtool: %s exit\n", __func__)
>
> Why you need these when you have kprobes (or whatever the name for
> function entry/exit instrumentation is)?

[masa]
This will be deleted.

>
> > +/**
> > + * pch_gbe_get_wol - Report whether Wake-on-Lan is enabled
> > + * @netdev: Network interface device structure
> > + * @wol:    Wake-on-Lan information
> > + */
> > +static void pch_gbe_get_wol(struct net_device *netdev,
> > + struct ethtool_wolinfo *wol)
> > +{
> > + struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> > +
> > + FUNC_ENTER();
> > +
> > + wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
> > + wol->wolopts = 0;
> > +
> > + if ((adapter->wake_up_evt & PCH_GBE_WLC_IND))
> > + wol->wolopts |= WAKE_UCAST;
> > + if ((adapter->wake_up_evt & PCH_GBE_WLC_MLT))
> > + wol->wolopts |= WAKE_MCAST;
> > + if ((adapter->wake_up_evt & PCH_GBE_WLC_BR))
> > + wol->wolopts |= WAKE_BCAST;
> > + if ((adapter->wake_up_evt & PCH_GBE_WLC_MP))
> > + wol->wolopts |= WAKE_MAGIC;
> > + return;
>
> no need to return here.

[masa]
This will be deleted

>
> > +}
> ...
> > +/**
> > + * pch_gbe_set_ringparam - Set ring sizes
> > + * @netdev:  Network interface device structure
> > + * @ring:    Ring param structure
> > + * Returns
> > + * 0: Successful.
> > + * Negative value: Failed.
> > + */
> > +static int pch_gbe_set_ringparam(struct net_device *netdev,
> > + struct ethtool_ringparam *ring)
> > +{
> > + struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> > + struct pch_gbe_tx_ring *txdr, *tx_old;
> > + struct pch_gbe_rx_ring *rxdr, *rx_old;
> > + int tx_ring_size, rx_ring_size;
> > + int err = 0;
> > + unsigned long flags;
> > +
> > + FUNC_ENTER();
> > + if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
> > + return -EINVAL;
> > + tx_ring_size = (int)sizeof(struct pch_gbe_tx_ring);
> > + rx_ring_size = (int)sizeof(struct pch_gbe_rx_ring);
> > +
> > + spin_lock_irqsave(&adapter->ethtool_lock, flags);
> > + if ((netif_running(adapter->netdev)))
> > + pch_gbe_down(adapter);
> > + tx_old = adapter->tx_ring;
> > + rx_old = adapter->rx_ring;
> > +
> > + txdr = kzalloc(tx_ring_size, GFP_KERNEL);
>
> This is deadlocable. You are calling sleeping allocation inside spinlock.

[masa]
This will be modified
Since spin lock is deleted, this issue is lost.

>
> > + if (!txdr) {
> > + err = -ENOMEM;
> > + goto err_alloc_tx;
> > + }
> > + rxdr = kzalloc(rx_ring_size, GFP_KERNEL);
> > + if (!rxdr) {
> > + err = -ENOMEM;
> > + goto err_alloc_rx;
> > + }
> > + adapter->tx_ring = txdr;
> > + adapter->rx_ring = rxdr;
> > +
> > + rxdr->count = max(ring->rx_pending, (u32) PCH_GBE_MIN_RXD);
> > + rxdr->count = min(rxdr->count, (u32) PCH_GBE_MAX_RXD);
>
> clamp()
> And why you need the cast?

[masa]
Since warning appears at the time of a make.


>
> > + rxdr->count = roundup(rxdr->count, PCH_GBE_RX_DESC_MULTIPLE);
> > +
> > + txdr->count = max(ring->tx_pending, (u32) PCH_GBE_MIN_TXD);
> > + txdr->count = min(txdr->count, (u32) PCH_GBE_MAX_TXD);
> > + txdr->count = roundup(txdr->count, PCH_GBE_TX_DESC_MULTIPLE);
> > +
> > + if ((netif_running(adapter->netdev))) {
> > + /* Try to get new resources before deleting old */
> > + err = pch_gbe_setup_rx_resources(adapter, adapter->rx_ring);
>
> There is vmalloc inside. You really haven't tried sleep-inside-atomic
> debug option, have you?
>
> In fact you alloc there (at most) PCH_GBE_MAX_TXD*sizeof(struct
> pch_gbe_rx_desc) = 4096*16=65k=order 16 of continuous (DMAable) space in
> the atomic context. This is likely to fail early.

[masa]
Since spin lock is deleted, this issue is lost.


>
> > + if (err)
> > + goto err_setup_rx;
> > + err = pch_gbe_setup_tx_resources(adapter, adapter->tx_ring);
> > + if (err)
> > + goto err_setup_tx;
> > + /* save the new, restore the old in order to free it,
> > + * then restore the new back again */
> > + adapter->rx_ring = rx_old;
> > + adapter->tx_ring = tx_old;
> > + pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
> > + pch_gbe_free_tx_resources(adapter, adapter->tx_ring);
> > + kfree(tx_old);
> > + kfree(rx_old);
> > + adapter->rx_ring = rxdr;
> > + adapter->tx_ring = txdr;
>
> Why this shuffling? Isn't enough to free *x_old and set adapter->*x_ring?

[masa]
This will be modified


>
> > + err = pch_gbe_up(adapter);
>
> Well pch_gbe_up may sleep (via pch_gbe_request_irq via pci_enable_msi
> and request_irq) and you call it here and on other places from inside an
> atomic context.

[masa]
Since spin lock is deleted, this issue is lost.

>
> > + }
> > + spin_unlock_irqrestore(&adapter->ethtool_lock, flags);
> > + return err;
> > +
> > +err_setup_tx:
> > + pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
> > +err_setup_rx:
> > + adapter->rx_ring = rx_old;
> > + adapter->tx_ring = tx_old;
> > + kfree(rxdr);
> > +err_alloc_rx:
> > + kfree(txdr);
> > +err_alloc_tx:
> > + if (netif_running(adapter->netdev))
> > + pch_gbe_up(adapter);
> > + spin_unlock_irqrestore(&adapter->ethtool_lock, flags);
> > + return err;
> > +}
> ...
> > --- /dev/null
> > +++ b/drivers/net/pch_gbe/pch_gbe_main.c
> > @@ -0,0 +1,2547 @@
> ...
> > +#define PCI_DEVICE_ID_INTEL_IOH1_GBE    (u16)(0x8802) /* Pci device ID */
>
> Why the cast?

[masa]
This will be deleted.

>
> > +void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
> > +{
> > + u32 mar_low, mar_high, adrmask;
> > +
> > + FUNC_ENTER();
> > + pr_debug("index : 0x%x\n", index);
> > +
> > + /*
> > + * HW expects these in little endian so we reverse the byte order
> > + * from network order (big endian) to little endian
> > + */
> > + mar_high = ((u32) addr[0] | ((u32) addr[1] << 8) |
> > +    ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
> > + mar_low = ((u32) addr[4] | ((u32) addr[5] << 8));
> > + /* Stop the MAC Address of index. */
> > + adrmask = ioread32(&hw->reg->ADDR_MASK);
> > + iowrite32((adrmask | (0x0001 << index)), &hw->reg->ADDR_MASK);
> > + /* wait busy */
> > + while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
> > + cpu_relax();
>
> There should be probably some time limit. Nobody trusts hardware.

[masa]
How should it modify?


>
> > +static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter)
> > +{
> > + int size;
> > +
> > + FUNC_ENTER();
> > + size = (int)sizeof(struct pch_gbe_tx_ring);
> > + adapter->tx_ring = kmalloc(size, GFP_KERNEL);
> > + if (!adapter->tx_ring)
> > + return -ENOMEM;
> > + memset(adapter->tx_ring, 0, size);
>
> kzalloc()

[masa]
This will be modified.

>
> > +
> > + size = (int)sizeof(struct pch_gbe_rx_ring);
> > + adapter->rx_ring = kmalloc(size, GFP_KERNEL);
> > + if (!adapter->rx_ring) {
> > + kfree(adapter->tx_ring);
> > + return -ENOMEM;
> > + }
> > + memset(adapter->rx_ring, 0, size);
>
> Ditto.
>
> > + size = (int)sizeof(struct net_device);
>
> Unused?

[masa]
This will be deleted.

>
> > + return 0;
> > +}
> ...
> > +static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter)
> > +{
> > + struct net_device *netdev = adapter->netdev;
> > +
> > + FUNC_ENTER();
> > + free_irq(adapter->pdev->irq, netdev);
> > + if (adapter->have_msi) {
> > + pci_disable_msi(adapter->pdev);
> > + pr_debug("call pci_disable_msi\n");
> > + }
> > +}
> > +
> > +/**
> > + * pch_gbe_irq_disable - Mask off interrupt generation on the NIC
> > + * @adapter:  Board private structure
> > + */
> > +static void pch_gbe_irq_disable(struct pch_gbe_adapter *adapter)
> > +{
> > + struct pch_gbe_hw *hw = &adapter->hw;
> > +
> > + FUNC_ENTER();
> > + atomic_inc(&adapter->irq_sem);
> > + iowrite32(0, &hw->reg->INT_EN);
>
> You should flush posted writes here.

[masa]
This will be modified

Reading of a register is added after iowrite.
OK?

>
> > + synchronize_irq(adapter->pdev->irq);
> > +
> > + pr_debug("INT_EN reg : 0x%08x\n", ioread32(&hw->reg->INT_EN));
> > +}
> ...
> > +static void
> > +pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
> > + struct pch_gbe_rx_ring *rx_ring, int cleaned_count)
> > +{
> > + struct net_device *netdev = adapter->netdev;
> > + struct pci_dev *pdev = adapter->pdev;
> > + struct pch_gbe_hw *hw = &adapter->hw;
> > + struct pch_gbe_rx_desc *rx_desc;
> > + struct pch_gbe_buffer *buffer_info;
> > + struct sk_buff *skb;
> > + unsigned int i;
> > + unsigned int bufsz;
> ...
> > + if (likely(rx_ring->next_to_use != i)) {
> > + rx_ring->next_to_use = i;
> > + if (unlikely(i-- == 0))
> > + i = (rx_ring->count - 1);
> > + wmb();
>
> Document the barrier.

[masa]
Document will be added.

>
> > + iowrite32(rx_ring->dma +
> > +   (int)sizeof(struct pch_gbe_rx_desc) * i,
> > +   &hw->reg->RX_DSC_SW_P);
> > + }
> > + return;
> > +}
> ...
> > +static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
> > +{
> > + struct pch_gbe_hw *hw = &adapter->hw;
> > + struct net_device *netdev = adapter->netdev;
> > + struct pci_dev *pdev = adapter->pdev;
> > +
> > + FUNC_ENTER();
> > + /* PCI config space info */
> > + hw->vendor_id = pdev->vendor;
> > + hw->device_id = pdev->device;
> > + hw->subsystem_vendor_id = pdev->subsystem_vendor;
> > + hw->subsystem_device_id = pdev->subsystem_device;
> > +
> > + pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
>
> pdev->revision?

[masa]
This will be deleted

>
> > +static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
> > +{
> > + struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> > + struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
> > + unsigned long flags;
> > +
> > + FUNC_ENTER();
> > + if (unlikely(skb->len <= 0)) {
> > + dev_kfree_skb_any(skb);
> > + pr_debug("Return : OK  skb len : %d\n", skb->len);
> > + return NETDEV_TX_OK;
> > + }
> > + if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
> > + pr_err("Transfer length Error: skb len: %d > max: %d\n",
> > +        skb->len, adapter->hw.mac.max_frame_size);
> > + dev_kfree_skb_any(skb);
> > + adapter->stats.tx_length_errors++;
> > + return NETDEV_TX_BUSY;
>
> Not nice. ndev layer will reuse the freed skb now.

[masa]
How should it modify?

>
> > + }
> ...
> > +static int pch_gbe_suspend(struct pci_dev *pdev, pm_message_t state)
> > +{
> > + struct net_device *netdev = pci_get_drvdata(pdev);
> > + struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> > + struct pch_gbe_hw *hw = &adapter->hw;
> > + u32 wufc = adapter->wake_up_evt;
> > + int retval = 0;
> > +
> > + FUNC_ENTER();
> > + netif_device_detach(netdev);
> > + if (netif_running(netdev))
> > + pch_gbe_down(adapter);
> > +#ifdef CONFIG_PM
> > + /* Implement our own version of pci_save_state(pdev) because pci-
> > + * express adapters have 256-byte config spaces. */
> > + retval = pci_save_state(pdev);
>
> But PCIe saves all caps, why you need this?

[masa]
I can not understand.
Please let me know details.


>
> > +static int pch_gbe_probe(struct pci_dev *pdev,
> > +   const struct pci_device_id *pci_id)
> > +{
> > + struct net_device *netdev;
> > + struct pch_gbe_adapter *adapter;
> > + unsigned long mmio_start;
> > + unsigned long mmio_len;
> > + int ret;
> > +
> > + FUNC_ENTER();
> > + ret = pci_enable_device(pdev);
> > + if (ret)
> > + return ret;
> > +
> > + if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
> > + && !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> > + ;
> > + } else {
>
> You should invert the logic. And use pci_ variants.

[masa]
This will be modified like
if (dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
 || dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {

What is pci_ variants?


>
> > + ret = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
> > + if (ret) {
> > + ret = dma_set_coherent_mask(&pdev->dev,
> > +     DMA_BIT_MASK(32));
> > + if (ret) {
> > + pr_err("ERR: No usable DMA configuration, aborting\n");
> > + goto err_disable_device;
> > + }
> > + }
> > + }
> > + ret = pci_request_regions(pdev, KBUILD_MODNAME);
> > + if (ret) {
> > + pr_err("ERR: Can't reserve PCI I/O and memory resources\n");
>
> Here (and below) you should use dev_err instead.

[masa]
This will be modified

>
> > + goto err_disable_device;
> > + }
> > + pci_set_master(pdev);
> > +
> > + netdev = alloc_etherdev((int)sizeof(struct pch_gbe_adapter));
> > + if (!netdev) {
> > + ret = -ENOMEM;
> > + pr_err("ERR: Can't allocate and set up an Ethernet device\n");
> > + goto err_release_pci;
> > + }
> > + SET_NETDEV_DEV(netdev, &pdev->dev);
> > +
> > + pci_set_drvdata(pdev, netdev);
> > + adapter = netdev_priv(netdev);
> > + adapter->netdev = netdev;
> > + adapter->pdev = pdev;
> > + adapter->hw.back = adapter;
> > + mmio_start = pci_resource_start(pdev, PCH_GBE_PCI_BAR);
> > + mmio_len = pci_resource_len(pdev, PCH_GBE_PCI_BAR);
> > + adapter->hw.reg = ioremap_nocache(mmio_start, mmio_len);
>
> pci_ioremap_bar()
>
> Anyway you should not use ioread/iowrite* on an ioremapped space. It is
> intended for iomapped space (pci_iomap) and is slower.

[masa]
This will be modified like
pci_iomap(pdev, PCH_GBE_PCI_BAR, 0) is used.

>
> > + if (!adapter->hw.reg) {
> > + ret = -EIO;
> > + pr_err("Can't ioremap\n");
> > + goto err_free_netdev;
> > + }
> > +
> > + netdev->netdev_ops = &pch_gbe_netdev_ops;
> > + netdev->watchdog_timeo = PCH_GBE_WATCHDOG_PERIOD;
> > + netif_napi_add(netdev, &adapter->napi,
> > +        pch_gbe_napi_poll, PCH_GBE_RX_WEIGHT);
> > + netdev->mem_start = mmio_start;
> > + netdev->mem_end = mmio_start + mmio_len;
> > + netdev->features = NETIF_F_HW_CSUM;
> > + pch_gbe_set_ethtool_ops(netdev);
> > +
> > + pch_gbe_mac_reset_hw(&adapter->hw);
> > +
> > + /* setup the private structure */
> > + ret = pch_gbe_sw_init(adapter);
> > + if (ret)
> > + goto err_iounmap;
> > +
> > + /* Initialize PHY */
> > + ret = pch_gbe_init_phy(adapter);
> > + if (ret) {
> > + pr_err("PHY initialize error\n");
> > + goto err_free_adapter;
> > + }
> > + pch_gbe_hal_get_bus_info(&adapter->hw);
> > +
> > + /* Read the MAC address. and store to the private data */
> > + ret = pch_gbe_hal_read_mac_addr(&adapter->hw);
> > + if (ret) {
> > + pr_err("MAC address Read Error\n");
> > + goto err_free_adapter;
> > + }
> > +
> > + memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
> > + if (!is_valid_ether_addr(netdev->dev_addr)) {
> > + pr_err("Invalid MAC Address\n");
> > + ret = -EIO;
> > + goto err_free_adapter;
> > + }
> > +
> > + init_timer(&adapter->watchdog_timer);
> > + adapter->watchdog_timer.function = &pch_gbe_watchdog;
> > + adapter->watchdog_timer.data = (unsigned long)adapter;
>
> setup_timer()

[masa]
This will be modified
setup_timer() is used.

>
> > +static int __init pch_gbe_init_module(void)
> > +{
> > + int ret;
> > + pr_info("%s - version %s\n", DRV_STRING, DRV_VERSION);
>
> You don't want to do that. Boot log is polluted enough already.

[masa]
This will be deleted

>
> > + ret = pci_register_driver(&pch_gbe_pcidev);
> > + if (copybreak != PCH_GBE_COPYBREAK_DEFAULT) {
> > + if (copybreak == 0) {
> > + pr_info("copybreak disabled\n");
> > + } else {
> > + pr_info("copybreak enabled for packets <= %u bytes\n",
> > + copybreak);
> > + }
> > + }
> > + return ret;
> > +}
> > +
> > +static void __exit pch_gbe_exit_module(void)
> > +{
> > + FUNC_ENTER();
> > + pci_unregister_driver(&pch_gbe_pcidev);
> > +
> > + pr_info("%s - unregister\n", DRV_STRING);
>
> Get rid of that, please.

[masa]
This will be deleted

>
> > --- /dev/null
> > +++ b/drivers/net/pch_gbe/pch_gbe_param.c
> > @@ -0,0 +1,507 @@
> ...
> > +static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
> > +{
> > + struct pch_gbe_hw *hw = &adapter->hw;
> > + int speed, dplx;
> > +
> > + { /* Speed */
> > + struct pch_gbe_opt_list speed_list[] = {
> > + {0, "" },
> > + {SPEED_10, ""},
> > + {SPEED_100, ""},
> > + {SPEED_1000, ""} };
>
> Is there a reason why these are not static const?

[masa]
This will be modified

>
> > +
> > + struct pch_gbe_option opt = {
> > + .type = list_option,
> > + .name = "Speed",
> > + .err  = "parameter ignored",
> > + .def  = 0,
> > + .arg  = { .l = { .nr = (int)ARRAY_SIZE(speed_list),
> > + .p = speed_list } }
> > + };
> > + speed = Speed;
> > + pch_gbe_validate_option(&speed, &opt, adapter);
> > + }
>
> regards,
> -- 
> js
> suse labs
>


