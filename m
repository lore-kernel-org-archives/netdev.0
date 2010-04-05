From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 2/2] benet: fix the misusage of zero dma address
Date: Mon, 5 Apr 2010 17:38:40 +0900
Message-ID: <20100405173724G.fujita.tomonori@lab.ntt.co.jp>
References: <20100405071059.GA32671@serverengines.com>
	<20100405163942P.fujita.tomonori@lab.ntt.co.jp>
	<20100405082202.GB32671@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:47724 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab0DEIip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 04:38:45 -0400
In-Reply-To: <20100405082202.GB32671@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Apr 2010 13:52:02 +0530
Sathya Perla <sathyap@serverengines.com> wrote:

> On 05/04/10 16:40 +0900, FUJITA Tomonori wrote:
> > > > +		wrb->frag_len = 0;
> > > Why does wrb->frag_len need to be reset here?
> > > In the TX path, it is set to the proper value for data wrbs and zero
> > > for dummy and hdr wrbs.
> > 
> > I guess that I misunderstood why unmap_tx_frag() checks a dma address.
> > The checking is necessary to avoid calling pci_unamp_* API for dummy
> > hdr wrbs?
> Yes.
> > 
> > Anyway, if wrb->frag_len doesn't need to be reset here, the following
> > patch is ok?
> Yes. Thanks.
> 
> Acked-by: Sathya Perla <sathyap@serverengines.com>

Thanks!

Can I also get your ack on "[PATCH 1/2] benet: use the dma state API
instead of the pci equivalents"?

http://patchwork.ozlabs.org/patch/49265/


The reason why I want to replace the PCI DMA state API is:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Note that I use DEFINE_DMA_UNMAP_ADDR for bus in struct
be_rx_page_info because dma_unmap_addr and DEFINE_DMA_UNMAP_ADDR are
supposed to be used together.
