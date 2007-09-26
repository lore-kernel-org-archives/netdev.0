From: FUJITA Tomonori <tomof@acm.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Wed, 26 Sep 2007 17:57:55 +0900
Message-ID: <20070925133624H.tomof@acm.org>
References: <20070908120036.GB8478@infradead.org>
	<20070909061551G.tomof@acm.org>
	<46F8C935.8050907@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomof@acm.org, open-iscsi@googlegroups.com, hch@infradead.org,
	jeff@garzik.org, davem@davemloft.net, mchristi@redhat.com,
	netdev@vger.kernel.org, anilgv@broadcom.com, talm@broadcom.com,
	lusinsky@broadcom.com, uri@broadcom.com,
	fujita.tomonori@lab.ntt.co.jp
To: hare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo10.iij4u.or.jp ([210.138.174.78]:39663 "EHLO mo10.iij4u.or.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbXIZI6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 04:58:33 -0400
In-Reply-To: <46F8C935.8050907@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Sep 2007 10:39:17 +0200
Hannes Reinecke <hare@suse.de> wrote:

> Hi Tomo,
> 
> FUJITA Tomonori wrote:
> > On Sat, 8 Sep 2007 13:00:36 +0100
> > Christoph Hellwig <hch@infradead.org> wrote:
> > 
> >> On Sat, Sep 08, 2007 at 07:32:27AM -0400, Jeff Garzik wrote:
> >>> FUJITA Tomonori wrote:
> >>>> Yeah, iommu code ignores the lld limitations (the problem is that the
> >>>> lld limitations are in request_queue and iommu code can't access to
> >>>> request_queue). There is no way to tell iommu code about the lld
> >>>> limitations.
> >>>
> >>> This fact very much wants fixing.
> >>
> >> Absolutely.  Unfortunately everyone wastes their time on creating workarounds
> >> instead of fixing the underlying problem.
> > 
> > Any ideas on how to fix this?
> > 
> > I chatted to Jens and James on this last week.
> > 
> > - we could just copies the lld limitations to device structure. it's
> > hacky but device structure already has hacky stuff.
> > 
> > - we could just link device structure to request_queue structure so
> > that iommu code can see request_queue structure.
> > 
> > - we could remove the lld limitations in request_queue strucutre and
> > have a new strucutre (something like struct io_restrictions). then
> > somehow we could link the new structure with request_queue and device
> > strucutres.
> > 
> I'd prefer the latter. These struct io_restrictions could then be used
> by dm (which has it's own version right now) to merge queue capabilities.

Yeah, we could nicely handle lld's restrictions (especially with
stacking devices). But iommu code needs only max_segment_size and
seg_boundary_mask, right? If so, the first simple approach to add two
values to device structure is not so bad, I think.
