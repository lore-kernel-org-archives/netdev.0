From: FUJITA Tomonori <tomof@acm.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Thu, 27 Sep 2007 17:46:06 +0900
Message-ID: <20070926083804F.tomof@acm.org>
References: <46FB6087.10306@garzik.org>
	<1190880779.6158.0.camel@pasglop>
	<46FB6837.7040308@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, tomof@acm.org, hare@suse.de,
	open-iscsi@googlegroups.com, hch@infradead.org,
	davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, fujita.tomonori@lab.ntt.co.jp,
	jens.axboe@oracle.com, James.Bottomley@SteelEye.com,
	linux-scsi@vger.kernel.org
To: jeff@garzik.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <46FB6837.7040308@garzik.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC'ed Jens, James, and linux-scsi again.

On Thu, 27 Sep 2007 04:22:15 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Benjamin Herrenschmidt wrote:
> > On Thu, 2007-09-27 at 03:49 -0400, Jeff Garzik wrote:
> >> Benjamin Herrenschmidt wrote:
> >>> On Thu, 2007-09-27 at 03:31 -0400, Jeff Garzik wrote:
> >>>> A key problem I was hoping would be solved with your work here was
> >>>> the 
> >>>> elimination of that post dma_map_sg() split.
> >>>>
> >>>> If I understood James and Ben correctly, one of the key problems was 
> >>>> always in communicating libata's segment boundary needs to the IOMMU
> >>>> layers?
> >>> Yup. If we can put some constraint in struct device that the dma mapping
> >>> code can then look at ... we also need to ensure that what's passed in
> >>> for DMA'ing already matches those constraints as well since no-iommu
> >>> platforms will basically just keep the dma table as-is.
> >> That's a good point...  no-iommu platforms would need to be updated to 
> >> do the split for me.  I suppose we can steal that code from swiotlb or 
> >> somewhere.
> > 
> > Doing the split means being able to grow the sglist... which the dma_*
> > calls can't do at least not in their current form.
> 
> IMO one straightforward approach is for the struct scatterlist owner to 
> provide a table large enough to accomodate the possible splits (perhaps 
> along with communicate that table's max size to the IOMMU/dma layers).

As I said in another mail, the block layer and scsi-ml work properly,
I think. So there is no need to split sg lists for no-iommu platforms.

We need to fix only iommu code merge sglists (already done) for the
segment size restriction but we need to fix all iommu code and swiotlb
for the segment boundary restriction. Splitting sg list might be
useful for the case that iommu can't find a proper boundary memory
area. But I think that it rarely happens (and there are few llds has
the boundary restriction).
