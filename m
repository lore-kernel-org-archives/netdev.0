From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Thu, 27 Sep 2007 04:22:15 -0400
Message-ID: <46FB6837.7040308@garzik.org>
References: <20070908120036.GB8478@infradead.org>	 <20070909061551G.tomof@acm.org>	<46F8C935.8050907@suse.de>	 <20070925133624H.tomof@acm.org>  <46FB5C6B.3020506@garzik.org>	 <1190878682.30275.9.camel@pasglop>  <46FB6087.10306@garzik.org> <1190880779.6158.0.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: FUJITA Tomonori <tomof@acm.org>, hare@suse.de,
	open-iscsi@googlegroups.com, hch@infradead.org,
	davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, fujita.tomonori@lab.ntt.co.jp
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48354 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbXI0IWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 04:22:23 -0400
In-Reply-To: <1190880779.6158.0.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> On Thu, 2007-09-27 at 03:49 -0400, Jeff Garzik wrote:
>> Benjamin Herrenschmidt wrote:
>>> On Thu, 2007-09-27 at 03:31 -0400, Jeff Garzik wrote:
>>>> A key problem I was hoping would be solved with your work here was
>>>> the 
>>>> elimination of that post dma_map_sg() split.
>>>>
>>>> If I understood James and Ben correctly, one of the key problems was 
>>>> always in communicating libata's segment boundary needs to the IOMMU
>>>> layers?
>>> Yup. If we can put some constraint in struct device that the dma mapping
>>> code can then look at ... we also need to ensure that what's passed in
>>> for DMA'ing already matches those constraints as well since no-iommu
>>> platforms will basically just keep the dma table as-is.
>> That's a good point...  no-iommu platforms would need to be updated to 
>> do the split for me.  I suppose we can steal that code from swiotlb or 
>> somewhere.
> 
> Doing the split means being able to grow the sglist... which the dma_*
> calls can't do at least not in their current form.

IMO one straightforward approach is for the struct scatterlist owner to 
provide a table large enough to accomodate the possible splits (perhaps 
along with communicate that table's max size to the IOMMU/dma layers).

	Jeff


