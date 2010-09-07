From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Tue, 7 Sep 2010 10:13:22 +0900
Message-ID: <001a01cb4e2a$5f870bf0$66f8800a@maildom.okisemi.com>
References: <4C763A67.5040107@dsn.okisemi.com><4C7D0E7A.5060309@dsn.okisemi.com> <20100903112248Q.fujita.tomonori@lab.ntt.co.jp>
Cc: <shemminger@vyatta.com>, <sam@ravnborg.org>, <joe@perches.com>,
	"ML linux-kernel" <linux-kernel@vger.kernel.org>,
	"ML netdev" <netdev@vger.kernel.org>, <gregory.v.rose@intel.com>,
	<mbizon@freebox.fr>, <kristoffer@gaisler.com>,
	<ralf@linux-mips.org>, <john.linn@xilinx.com>,
	<randy.dunlap@oracle.com>, <davem@davemloft.net>,
	<meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	<andrew.chih.howe.khor@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"okada" <okada533@dsn.okisemi.com>,
	"Morinaga" <morinaga526@dsn.okisemi.com>,
	"shimizu" <shimizu394@dsn.okisemi.com>
To: "FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:23320 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752770Ab0IGBRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:17:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fujita

Thank you for your comments.

> > + if (buffer_info->dma) {
> > + pci_unmap_single(adapter->pdev, buffer_info->dma,
> > + buffer_info->length, PCI_DMA_FROMDEVICE);
> > + buffer_info->dma = 0;
>
> Probably, this trick doesn't work because zero could be a valid DMA
> address on some architctures.
>

The flag which shows mapped will be added.
And it is used instead of "if (buffer_info->dma) ".


> > + /*-- Set Buffer infomation --*/
> > + buffer_info->length = skb->len;
> > + buffer_info->dma =
> > +     pci_map_single(adapter->pdev, skb->data, buffer_info->length,
> > +    PCI_DMA_TODEVICE);
>
> Needs to handle mapping failure (dma_mapping_errro)?

Error process will be added.


> Can you use dma_map_* API instead of pci_map_*? Please read:
>

This DMA of device is not standard.  Personal use of Gigabit Ethernet device.
So, I guess that I do not need to use DMA-API.

Thanks, Ohtake
----- Original Message ----- 
From: "FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
To: <masa-korg@dsn.okisemi.com>
Cc: <shemminger@vyatta.com>; <sam@ravnborg.org>; <joe@perches.com>; <linux-kernel@vger.kernel.org>;
<netdev@vger.kernel.org>; <gregory.v.rose@intel.com>; <mbizon@freebox.fr>; <kristoffer@gaisler.com>;
<ralf@linux-mips.org>; <john.linn@xilinx.com>; <randy.dunlap@oracle.com>; <davem@davemloft.net>; <meego-dev@meego.com>;
<qi.wang@intel.com>; <yong.y.wang@intel.com>; <andrew.chih.howe.khor@intel.com>; <joel.clark@intel.com>;
<margie.foster@intel.com>; <okada533@dsn.okisemi.com>; <morinaga526@dsn.okisemi.com>; <shimizu394@dsn.okisemi.com>
Sent: Friday, September 03, 2010 11:23 AM
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH


> On Tue, 31 Aug 2010 23:15:22 +0900
> Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:
>
> > Gigabit Ethernet driver of Topcliff PCH
> > Patch created against 2.6.35
> >
> > Topcliff PCH is the platform controller hub that is going to be used in
> > Intel's upcoming general embedded platform. All IO peripherals in
> > Topcliff PCH are actually devices sitting on AMBA bus.
> > Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to
> > access system devices connected to Gigabit Ethernet.
> >
> > Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> > ---
> >  drivers/net/Kconfig                   |   10 +
> >  drivers/net/Makefile                  |    1 +
> >  drivers/net/pch_gbe/Makefile          |    4 +
> >  drivers/net/pch_gbe/pch_gbe.h         |  683 +++++++++
> >  drivers/net/pch_gbe/pch_gbe_api.c     |  246 ++++
> >  drivers/net/pch_gbe/pch_gbe_api.h     |   34 +
> >  drivers/net/pch_gbe/pch_gbe_ethtool.c |  618 ++++++++
> >  drivers/net/pch_gbe/pch_gbe_main.c    | 2591 +++++++++++++++++++++++++++++++++
> >  drivers/net/pch_gbe/pch_gbe_param.c   |  519 +++++++
> >  drivers/net/pch_gbe/pch_gbe_phy.c     |  276 ++++
> >  drivers/net/pch_gbe/pch_gbe_phy.h     |   35 +
> >  11 files changed, 5017 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/net/pch_gbe/Makefile
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe.h
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe_api.c
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe_api.h
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe_ethtool.c
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe_main.c
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe_param.c
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe_phy.c
> >  create mode 100644 drivers/net/pch_gbe/pch_gbe_phy.h
>
> (snip)
>
> > +/**
> > + * pch_gbe_unmap_and_free_rx_resource - Unmap and free rx socket buffer
> > + * @adapter:      Board private structure
> > + * @buffer_info:  Buffer information structure
> > + */
> > +static void pch_gbe_unmap_and_free_rx_resource(
> > + struct pch_gbe_adapter *adapter,
> > + struct pch_gbe_buffer *buffer_info)
> > +{
> > + if (buffer_info->dma) {
> > + pci_unmap_single(adapter->pdev, buffer_info->dma,
> > + buffer_info->length, PCI_DMA_FROMDEVICE);
> > + buffer_info->dma = 0;
>
> Probably, this trick doesn't work because zero could be a valid DMA
> address on some architctures.
>
>
> > + /*-- Set Buffer infomation --*/
> > + buffer_info->length = skb->len;
> > + buffer_info->dma =
> > +     pci_map_single(adapter->pdev, skb->data, buffer_info->length,
> > +    PCI_DMA_TODEVICE);
>
> Needs to handle mapping failure (dma_mapping_errro)?
>
> I found the same problems in other places.
>
>
> Can you use dma_map_* API instead of pci_map_*? Please read:
>
> Documentation/DMA-API.txt
> Documentation/DMA-API-HOWTO.txt
>
>
> Thanks,
>




