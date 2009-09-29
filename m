From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver:
	vmxnet3
Date: Tue, 29 Sep 2009 13:56:09 -0700
Message-ID: <89E2752CFA8EC044846EB849981913410173DCD9E6@EXCH-MBX-4.vmware.com>
References: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
 <20090929085333.GC3958@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Greg Kroah-Hartman <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:33910 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751351AbZI2U4H convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 16:56:07 -0400
In-Reply-To: <20090929085333.GC3958@sequoia.sous-sol.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris,

Thanks for the review.

Bhavesh responded to some queries. I will attempt the answer the rest.
I am working on rebasing the code to v2.6.32-rc1. Will send out a patch
with the changes you suggested after that.


->Shreyas

> -----Original Message-----
> From: Chris Wright [mailto:chrisw@sous-sol.org]
> Sent: Tuesday, September 29, 2009 1:54 AM
> To: Shreyas Bhatewara
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Stephen
> Hemminger; David S. Miller; Jeff Garzik; Anthony Liguori; Chris Wright;
> Greg Kroah-Hartman; Andrew Morton; virtualization; pv-
> drivers@vmware.com
> Subject: Re: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC
> driver: vmxnet3
>
>
> >         Wake-on-LAN, PCI Power Management D0-D3 states
> >         PXE-ROM for boot support
> >
>
> Whole thing appears to be space indented, and is fairly noisy w/
> printk.

The code written is tab indented. Is there a specific line / function
which you find space indented ? If not, may be my email client did not
preserve the tabs while sending. I will take care while posting next patch.

Some of the printks are debug only. Others have been marked as INFO or ERR
appropriately. I will remove a few.


> Also, heavy use of BUG_ON() (counted 51 of them), are you sure that
> none
> of them can be triggered by guest or remote (esp. the ones that happen
> in interrupt context)?  Some initial thoughts below.
>

Like you said below, I will remove the user input dependent ones.


> > + * the file called "COPYING".
> > + *
> > + * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
> > + *
> > + */
> > +
> > +/* upt1_defs.h
> > + *
> > + *      Definitions for Uniform Pass Through.
> > + */
>
> Most of the source files have this format (some include -- after file
> name).  Could just keep it all w/in the same comment block.  Since you
> went to the trouble of saying what the file does, something a tad more
> descriptive would be welcome.
>

Yes, I will merge the two blocks and elaborate on the description.

> > +
> > +#ifndef _UPT1_DEFS_H
> > +#define _UPT1_DEFS_H
> > +
> > +#define UPT1_MAX_TX_QUEUES  64
> > +#define UPT1_MAX_RX_QUEUES  64
>
> This is different than the 16/8 described above (and seemingly all moot
> since it becomes a single queue device).
>
> > +
> > +/* interrupt moderation level */
> > +#define UPT1_IML_NONE     0 /* no interrupt moderation */
> > +#define UPT1_IML_HIGHEST  7 /* least intr generated */
> > +#define UPT1_IML_ADAPTIVE 8 /* adpative intr moderation */
>
> enum?  also only appears to support adaptive mode?
> > +
> > +/*
> > + * QueueDescPA must be 128 bytes aligned. It points to an array of
> > + * Vmxnet3_TxQueueDesc followed by an array of Vmxnet3_RxQueueDesc.
> > + * The number of Vmxnet3_TxQueueDesc/Vmxnet3_RxQueueDesc are
> specified by
> > + * Vmxnet3_MiscConf.numTxQueues/numRxQueues, respectively.
> > + */
> > +#define VMXNET3_QUEUE_DESC_ALIGN  128
>
> Lot of inconsistent spacing between types and names in the structure
> def'ns

Okay, I will try to make it uniform.

>
> > +struct Vmxnet3_MiscConf {
> > +       struct Vmxnet3_DriverInfo driverInfo;
> > +       uint64_t             uptFeatures;
> > +       uint64_t             ddPA;         /* driver data PA */
> > +       uint64_t             queueDescPA;  /* queue descriptor table
> PA */
> > +       uint32_t             ddLen;        /* driver data len */
> > +       uint32_t             queueDescLen; /* queue desc. table len
> in bytes */
> > +       uint32_t             mtu;
> > +       uint16_t             maxNumRxSG;
> > +       uint8_t              numTxQueues;
> > +       uint8_t              numRxQueues;
> > +       uint32_t             reserved[4];
> > +};
>
> should this be packed (or others that are shared w/ device)?  i assume
> you've already done 32 vs 64 here
>
> > +struct Vmxnet3_TxQueueConf {
> > +       uint64_t    txRingBasePA;
> > +       uint64_t    dataRingBasePA;
> > +       uint64_t    compRingBasePA;
> > +       uint64_t    ddPA;         /* driver data */
> > +       uint64_t    reserved;
> > +       uint32_t    txRingSize;   /* # of tx desc */
> > +       uint32_t    dataRingSize; /* # of data desc */
> > +       uint32_t    compRingSize; /* # of comp desc */
> > +       uint32_t    ddLen;        /* size of driver data */
> > +       uint8_t     intrIdx;
> > +       uint8_t     _pad[7];
> > +};
> > +
> > +
> > +struct Vmxnet3_RxQueueConf {
> > +       uint64_t    rxRingBasePA[2];
> > +       uint64_t    compRingBasePA;
> > +       uint64_t    ddPA;            /* driver data */
> > +       uint64_t    reserved;
> > +       uint32_t    rxRingSize[2];   /* # of rx desc */
> > +       uint32_t    compRingSize;    /* # of rx comp desc */
> > +       uint32_t    ddLen;           /* size of driver data */
> > +       uint8_t     intrIdx;
> > +       uint8_t     _pad[7];
> > +};
> > +
> > +enum vmxnet3_intr_mask_mode {
> > +       VMXNET3_IMM_AUTO   = 0,
> > +       VMXNET3_IMM_ACTIVE = 1,
> > +       VMXNET3_IMM_LAZY   = 2
> > +};
> > +
> > +enum vmxnet3_intr_type {
> > +       VMXNET3_IT_AUTO = 0,
> > +       VMXNET3_IT_INTX = 1,
> > +       VMXNET3_IT_MSI  = 2,
> > +       VMXNET3_IT_MSIX = 3
> > +};
> > +
> > +#define VMXNET3_MAX_TX_QUEUES  8
> > +#define VMXNET3_MAX_RX_QUEUES  16
>
> different to UPT, I must've missed some layering here

There are the right ones, I will remove the other definitions.

>
> > +/* addition 1 for events */
> > +#define VMXNET3_MAX_INTRS      25
> > +
> > +
> <snip>
>
> > --- /dev/null
> > +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> > @@ -0,0 +1,2608 @@
> > +/*
> > + * Linux driver for VMware's vmxnet3 ethernet NIC.
> <snip>
> > +/*
> > + * vmxnet3_drv.c --
> > + *
> > + *      Linux driver for VMware's vmxnet3 NIC
> > + */
>
> Not useful
>
> > +static void
> > +vmxnet3_enable_intr(struct vmxnet3_adapter *adapter, unsigned
> intr_idx)
> > +{
> > +       VMXNET3_WRITE_BAR0_REG(adapter, VMXNET3_REG_IMR + intr_idx *
> 8, 0);
>
>       writel(0, adapter->hw_addr0 + VMXNET3_REG_IMR + intr_idx * 8)
>
> seems just as clear to me.

The intention is to differentiate bar0 and bar1 writes. hw_addr0/1
doesn't seem to convey that instantly.

>
> > +vmxnet3_enable_all_intrs(struct vmxnet3_adapter *adapter)
> > +{
> > +       int i;
> > +
> > +       for (i = 0; i < adapter->intr.num_intrs; i++)
> > +               vmxnet3_enable_intr(adapter, i);
> > +}
> > +
> > +static void
> > +vmxnet3_disable_all_intrs(struct vmxnet3_adapter *adapter)
> > +{
> > +       int i;
> > +
> > +       for (i = 0; i < adapter->intr.num_intrs; i++)
> > +               vmxnet3_disable_intr(adapter, i);
> > +}
>
> only ever num_intrs=1, so there's some plan to bump this up and make
> these wrappers useful?
>
> > +static void
> > +vmxnet3_ack_events(struct vmxnet3_adapter *adapter, u32 events)
> > +{
> > +       VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_ECR, events);
> > +}
> > +
> > +
> > +static bool
> > +vmxnet3_tq_stopped(struct vmxnet3_tx_queue *tq, struct
> vmxnet3_adapter *adapter)
> > +{
> > +       return netif_queue_stopped(adapter->netdev);
> > +}
> > +
> > +
> > +static void
> > +vmxnet3_tq_start(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter
> *adapter)
> > +{
> > +       tq->stopped = false;
>
> is tq->stopped used besides just toggling back and forth?

It is used in ethtool ops.

>
> > +       netif_start_queue(adapter->netdev);
> > +}
>
> > +static void
> > +vmxnet3_process_events(struct vmxnet3_adapter *adapter)
>
> Should be trivial to break out to it's own MSI-X vector, basically set
> up to do that already.
>
> > +{
> > +       u32 events = adapter->shared->ecr;
> > +       if (!events)
> > +               return;
> > +
> > +       vmxnet3_ack_events(adapter, events);
> > +
> > +       /* Check if link state has changed */
> > +       if (events & VMXNET3_ECR_LINK)
> > +               vmxnet3_check_link(adapter);
> > +
> > +       /* Check if there is an error on xmit/recv queues */
> > +       if (events & (VMXNET3_ECR_TQERR | VMXNET3_ECR_RQERR)) {
> > +               VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
> > +                                      VMXNET3_CMD_GET_QUEUE_STATUS);
> > +
> > +               if (adapter->tqd_start->status.stopped) {
> > +                       printk(KERN_ERR "%s: tq error 0x%x\n",
> > +                              adapter->netdev->name,
> > +                              adapter->tqd_start->status.error);
> > +               }
> > +               if (adapter->rqd_start->status.stopped) {
> > +                       printk(KERN_ERR "%s: rq error 0x%x\n",
> > +                              adapter->netdev->name,
> > +                              adapter->rqd_start->status.error);
> > +               }
> > +
> > +               schedule_work(&adapter->work);
> > +       }
> > +}
> <snip>
>
> > +
> > +       tq->buf_info = kcalloc(sizeof(tq->buf_info[0]), tq-
> >tx_ring.size,
> > +                              GFP_KERNEL);
>
> kcalloc args look backwards
>
> <snip>
> > +static int
> > +vmxnet3_alloc_pci_resources(struct vmxnet3_adapter *adapter, bool
> *dma64)
> > +{
> > +       int err;
> > +       unsigned long mmio_start, mmio_len;
> > +       struct pci_dev *pdev = adapter->pdev;
> > +
> > +       err = pci_enable_device(pdev);
>
> looks ioport free, can be pci_enable_device_mem()...

Yes, will do that.

>
> > +       if (err) {
> > +               printk(KERN_ERR "Failed to enable adapter %s: error
> %d\n",
> > +                      pci_name(pdev), err);
> > +               return err;
> > +       }
> > +
> > +       if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) == 0) {
> > +               if (pci_set_consistent_dma_mask(pdev,
> DMA_BIT_MASK(64)) != 0) {
> > +                       printk(KERN_ERR "pci_set_consistent_dma_mask
> failed "
> > +                              "for adapter %s\n", pci_name(pdev));
> > +                       err = -EIO;
> > +                       goto err_set_mask;
> > +               }
> > +               *dma64 = true;
> > +       } else {
> > +               if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) {
> > +                       printk(KERN_ERR "pci_set_dma_mask failed for
> adapter "
> > +                              "%s\n",  pci_name(pdev));
> > +                       err = -EIO;
> > +                       goto err_set_mask;
> > +               }
> > +               *dma64 = false;
> > +       }
> > +
> > +       err = pci_request_regions(pdev, vmxnet3_driver_name);
>
> ...pci_request_selected_regions()

Okay.

>
> > +       if (err) {
> > +               printk(KERN_ERR "Failed to request region for adapter
> %s: "
> > +                      "error %d\n", pci_name(pdev), err);
> > +               goto err_set_mask;
> > +       }
> > +
> > +       pci_set_master(pdev);
> > +
> > +       mmio_start = pci_resource_start(pdev, 0);
> > +       mmio_len = pci_resource_len(pdev, 0);
> > +       adapter->hw_addr0 = ioremap(mmio_start, mmio_len);
> > +       if (!adapter->hw_addr0) {
> > +               printk(KERN_ERR "Failed to map bar0 for adapter
> %s\n",
> > +                      pci_name(pdev));
> > +               err = -EIO;
> > +               goto err_ioremap;
> > +       }
> > +
> > +       mmio_start = pci_resource_start(pdev, 1);
> > +       mmio_len = pci_resource_len(pdev, 1);
> > +       adapter->hw_addr1 = ioremap(mmio_start, mmio_len);
> > +       if (!adapter->hw_addr1) {
> > +               printk(KERN_ERR "Failed to map bar1 for adapter
> %s\n",
> > +                      pci_name(pdev));
> > +               err = -EIO;
> > +               goto err_bar1;
> > +       }
> > +       return 0;
> > +
> > +err_bar1:
> > +       iounmap(adapter->hw_addr0);
> > +err_ioremap:
> > +       pci_release_regions(pdev);
>
> ...and pci_release_selected_regions()
>
> > +err_set_mask:
> > +       pci_disable_device(pdev);
> > +       return err;
> > +}
> > +
>
> <snip>
> > +vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool
> dma64)
> > +{
> > +       struct net_device *netdev = adapter->netdev;
> > +
> > +       netdev->features = NETIF_F_SG |
> > +               NETIF_F_HW_CSUM |
> > +               NETIF_F_HW_VLAN_TX |
> > +               NETIF_F_HW_VLAN_RX |
> > +               NETIF_F_HW_VLAN_FILTER |
> > +               NETIF_F_TSO |
> > +               NETIF_F_TSO6;
> > +
> > +       printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6");
> > +
> > +       adapter->rxcsum = true;
> > +       adapter->jumbo_frame = true;
> > +
> > +       if (!disable_lro) {
> > +               adapter->lro = true;
> > +               printk(" lro");
> > +       }
>
> Plan to switch to GRO?
>
> > +       if (dma64) {
> > +               netdev->features |= NETIF_F_HIGHDMA;
> > +               printk(" highDMA");
> > +       }
> > +
> > +       netdev->vlan_features = netdev->features;
> > +       printk("\n");
> > +}
> > +
> > +static int __devinit
> > +vmxnet3_probe_device(struct pci_dev *pdev,
> > +                    const struct pci_device_id *id)
> > +{
> > +       static const struct net_device_ops vmxnet3_netdev_ops = {
> > +               .ndo_open  = vmxnet3_open,
> > +               .ndo_stop  = vmxnet3_close,
> > +               .ndo_start_xmit = vmxnet3_xmit_frame,
> > +               .ndo_set_mac_address = vmxnet3_set_mac_addr,
> > +               .ndo_change_mtu = vmxnet3_change_mtu,
> > +               .ndo_get_stats = vmxnet3_get_stats,
> > +               .ndo_tx_timeout = vmxnet3_tx_timeout,
> > +               .ndo_set_multicast_list = vmxnet3_set_mc,
> > +               .ndo_vlan_rx_register = vmxnet3_vlan_rx_register,
> > +               .ndo_vlan_rx_add_vid = vmxnet3_vlan_rx_add_vid,
> > +               .ndo_vlan_rx_kill_vid = vmxnet3_vlan_rx_kill_vid,
> > +#   ifdef CONFIG_NET_POLL_CONTROLLER
> > +               .ndo_poll_controller = vmxnet3_netpoll,
> > +#   endif
>
> #ifdef
> #endif
>
> is more typical style here
>
> > +       };
> > +       int err;
> > +       bool dma64 = false; /* stupid gcc */
> > +       u32 ver;
> > +       struct net_device *netdev;
> > +       struct vmxnet3_adapter *adapter;
> > +       u8  mac[ETH_ALEN];
>
> extra space between type and name
>
> > +
> > +       netdev = alloc_etherdev(sizeof(struct vmxnet3_adapter));
> > +       if (!netdev) {
> > +               printk(KERN_ERR "Failed to alloc ethernet device for
> adapter "
> > +                       "%s\n", pci_name(pdev));
> > +               return -ENOMEM;
> > +       }
> > +
> > +       pci_set_drvdata(pdev, netdev);
> > +       adapter = netdev_priv(netdev);
> > +       adapter->netdev = netdev;
> > +       adapter->pdev = pdev;
> > +
> > +       adapter->shared = pci_alloc_consistent(adapter->pdev,
> > +                         sizeof(struct Vmxnet3_DriverShared),
> > +                         &adapter->shared_pa);
> > +       if (!adapter->shared) {
> > +               printk(KERN_ERR "Failed to allocate memory for %s\n",
> > +                       pci_name(pdev));
> > +               err = -ENOMEM;
> > +               goto err_alloc_shared;
> > +       }
> > +
> > +       adapter->tqd_start  = pci_alloc_consistent(adapter->pdev,
>
> extra space before =
>
> > diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> > new file mode 100644
> > index 0000000..490577f
> > --- /dev/null
> > +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> > +#include "vmxnet3_int.h"
> > +
> > +struct vmxnet3_stat_desc {
> > +       char desc[ETH_GSTRING_LEN];
> > +       int  offset;
> > +};
> > +
> > +
> > +static u32
> > +vmxnet3_get_rx_csum(struct net_device *netdev)
> > +{
> > +       struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> > +       return adapter->rxcsum;
> > +}
> > +
> > +
> > +static int
> > +vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
> > +{
> > +       struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> > +
> > +       if (adapter->rxcsum != val) {
> > +               adapter->rxcsum = val;
> > +               if (netif_running(netdev)) {
> > +                       if (val)
> > +                               adapter->shared-
> >devRead.misc.uptFeatures |=
> > +
> UPT1_F_RXCSUM;
> > +                       else
> > +                               adapter->shared-
> >devRead.misc.uptFeatures &=
> > +
> ~UPT1_F_RXCSUM;
> > +
> > +                       VMXNET3_WRITE_BAR1_REG(adapter,
> VMXNET3_REG_CMD,
> > +
> VMXNET3_CMD_UPDATE_FEATURE);
> > +               }
> > +       }
> > +       return 0;
> > +}
> > +
> > +
> > +static u32
> > +vmxnet3_get_tx_csum(struct net_device *netdev)
> > +{
> > +       return (netdev->features & NETIF_F_HW_CSUM) != 0;
> > +}
>
> Not needed
>
> > +static int
> > +vmxnet3_set_tx_csum(struct net_device *netdev, u32 val)
> > +{
> > +       if (val)
> > +               netdev->features |= NETIF_F_HW_CSUM;
> > +       else
> > +               netdev->features &= ~NETIF_F_HW_CSUM;
> > +
> > +       return 0;
> > +}
>
> This is just ethtool_op_set_tx_hw_csum()
>
> > +static int
> > +vmxnet3_set_sg(struct net_device *netdev, u32 val)
> > +{
> > +       ethtool_op_set_sg(netdev, val);
> > +       return 0;
> > +}
>
> Useless wrapper
>
> > +static int
> > +vmxnet3_set_tso(struct net_device *netdev, u32 val)
> > +{
> > +       ethtool_op_set_tso(netdev, val);
> > +       return 0;
> > +}
>
> Useless wrapper
>

I will remove the unwanted wrappers functions, spaces and get back with a patch.

