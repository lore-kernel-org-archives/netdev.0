From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Tue, 7 Sep 2010 12:21:44 +0900
Message-ID: <20100907122012O.fujita.tomonori@lab.ntt.co.jp>
References: <4C7D0E7A.5060309@dsn.okisemi.com>
	<20100903112248Q.fujita.tomonori@lab.ntt.co.jp>
	<001a01cb4e2a$5f870bf0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, shemminger@vyatta.com,
	sam@ravnborg.org, joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	mbizon@freebox.fr, kristoffer@gaisler.com, ralf@linux-mips.org,
	john.linn@xilinx.com, randy.dunlap@oracle.com, davem@davemloft.net,
	meego-dev@meego.com, qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	margie.foster@intel.com, okada533@dsn.okisemi.com,
	morinaga526@dsn.okisemi.com, shimizu394@dsn.okisemi.com
To: masa-korg@dsn.okisemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:52834 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751584Ab0IGDWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 23:22:40 -0400
In-Reply-To: <001a01cb4e2a$5f870bf0$66f8800a@maildom.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Sep 2010 10:13:22 +0900
"Masayuki Ohtake" <masa-korg@dsn.okisemi.com> wrote:

> > Probably, this trick doesn't work because zero could be a valid DMA
> > address on some architctures.
> >
> 
> The flag which shows mapped will be added.
> And it is used instead of "if (buffer_info->dma) ".

Sounds fine. That's what other drivers do.


> > > + /*-- Set Buffer infomation --*/
> > > + buffer_info->length = skb->len;
> > > + buffer_info->dma =
> > > +     pci_map_single(adapter->pdev, skb->data, buffer_info->length,
> > > +    PCI_DMA_TODEVICE);
> >
> > Needs to handle mapping failure (dma_mapping_errro)?
> 
> Error process will be added.

Nice.


> > Can you use dma_map_* API instead of pci_map_*? Please read:
> >
> 
> This DMA of device is not standard.  Personal use of Gigabit Ethernet device.
> So, I guess that I do not need to use DMA-API.

Sorry, I'm not sure what you mean. If a driver does DMA, it must use
the DMA API. Your driver already uses the DMA API (pci_dma_*),
however, pci_map_* API is obsolete so please use dma_map_* API
instead.

Thanks,
