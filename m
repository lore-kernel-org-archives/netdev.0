From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Tue, 7 Sep 2010 13:06:15 +0900
Message-ID: <000401cb4e42$0c7b5b10$66f8800a@maildom.okisemi.com>
References: <4C7D0E7A.5060309@dsn.okisemi.com><20100903112248Q.fujita.tomonori@lab.ntt.co.jp><001a01cb4e2a$5f870bf0$66f8800a@maildom.okisemi.com> <20100907122012O.fujita.tomonori@lab.ntt.co.jp>
Cc: <fujita.tomonori@lab.ntt.co.jp>, <shemminger@vyatta.com>,
	<sam@ravnborg.org>, <joe@perches.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<gregory.v.rose@intel.com>, <mbizon@freebox.fr>,
	<kristoffer@gaisler.com>, <ralf@linux-mips.org>,
	<john.linn@xilinx.com>, <randy.dunlap@oracle.com>,
	<davem@davemloft.net>, <meego-dev@meego.com>, <qi.wang@intel.com>,
	<yong.y.wang@intel.com>, <andrew.chih.howe.khor@intel.com>,
	<joel.clark@intel.com>, <margie.foster@intel.com>,
	<okada533@dsn.okisemi.com>, <morinaga526@dsn.okisemi.com>,
	<shimizu394@dsn.okisemi.com>
To: "FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fujita

> > This DMA of device is not standard.  Personal use of Gigabit Ethernet device.
> > So, I guess that I do not need to use DMA-API.
>
> Sorry, I'm not sure what you mean. If a driver does DMA, it must use
> the DMA API. Your driver already uses the DMA API (pci_dma_*),
> however, pci_map_* API is obsolete so please use dma_map_* API
> instead.

Thank you for the explanation.
I understood and use dma_map_* .

Thanks Ohtake
----- Original Message ----- 
From: "FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
To: <masa-korg@dsn.okisemi.com>
Cc: <fujita.tomonori@lab.ntt.co.jp>; <shemminger@vyatta.com>; <sam@ravnborg.org>; <joe@perches.com>;
<linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>; <gregory.v.rose@intel.com>; <mbizon@freebox.fr>;
<kristoffer@gaisler.com>; <ralf@linux-mips.org>; <john.linn@xilinx.com>; <randy.dunlap@oracle.com>;
<davem@davemloft.net>; <meego-dev@meego.com>; <qi.wang@intel.com>; <yong.y.wang@intel.com>;
<andrew.chih.howe.khor@intel.com>; <joel.clark@intel.com>; <margie.foster@intel.com>; <okada533@dsn.okisemi.com>;
<morinaga526@dsn.okisemi.com>; <shimizu394@dsn.okisemi.com>
Sent: Tuesday, September 07, 2010 12:21 PM
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH


> On Tue, 7 Sep 2010 10:13:22 +0900
> "Masayuki Ohtake" <masa-korg@dsn.okisemi.com> wrote:
>
> > > Probably, this trick doesn't work because zero could be a valid DMA
> > > address on some architctures.
> > >
> >
> > The flag which shows mapped will be added.
> > And it is used instead of "if (buffer_info->dma) ".
>
> Sounds fine. That's what other drivers do.
>
>
> > > > + /*-- Set Buffer infomation --*/
> > > > + buffer_info->length = skb->len;
> > > > + buffer_info->dma =
> > > > +     pci_map_single(adapter->pdev, skb->data, buffer_info->length,
> > > > +    PCI_DMA_TODEVICE);
> > >
> > > Needs to handle mapping failure (dma_mapping_errro)?
> >
> > Error process will be added.
>
> Nice.
>
>
> > > Can you use dma_map_* API instead of pci_map_*? Please read:
> > >
> >
> > This DMA of device is not standard.  Personal use of Gigabit Ethernet device.
> > So, I guess that I do not need to use DMA-API.
>
> Sorry, I'm not sure what you mean. If a driver does DMA, it must use
> the DMA API. Your driver already uses the DMA API (pci_dma_*),
> however, pci_map_* API is obsolete so please use dma_map_* API
> instead.
>
> Thanks,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
