From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Thu, 27 Sep 2007 03:31:55 -0400
Message-ID: <46FB5C6B.3020506@garzik.org>
References: <20070908120036.GB8478@infradead.org>	<20070909061551G.tomof@acm.org>	<46F8C935.8050907@suse.de> <20070925133624H.tomof@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hare@suse.de, open-iscsi@googlegroups.com, hch@infradead.org,
	davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, fujita.tomonori@lab.ntt.co.jp,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: FUJITA Tomonori <tomof@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36922 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493AbXI0HcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 03:32:03 -0400
In-Reply-To: <20070925133624H.tomof@acm.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FUJITA Tomonori wrote:
> Yeah, we could nicely handle lld's restrictions (especially with
> stacking devices). But iommu code needs only max_segment_size and
> seg_boundary_mask, right? If so, the first simple approach to add two
> values to device structure is not so bad, I think.

(replying to slightly older email in the thread)
(added benh, since we've discussed this issue in the past)

dumb question, what happened to seg_boundary_mask?

If you look at drivers/ata/libata-core.c:ata_fill_sg(), you will note 
that we split s/g segments after DMA-mapping.  Looking at libata LLDD's, 
you will also note judicious use of ATA_DMA_BOUNDARY (0xffff).

It was drilled into my head by James and benh that I cannot rely on the 
DMA boundary + block/scsi + dma_map_sg() to ensure that my S/G segments 
never cross a 64K boundary, a legacy IDE requirement.  Thus the 
additional code in ata_fill_sg() to split S/G segments straddling 64K, 
in addition to setting dma boundary to 0xffff.

A key problem I was hoping would be solved with your work here was the 
elimination of that post dma_map_sg() split.

If I understood James and Ben correctly, one of the key problems was 
always in communicating libata's segment boundary needs to the IOMMU layers?

	Jeff


