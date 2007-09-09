From: FUJITA Tomonori <tomof@acm.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Mon, 10 Sep 2007 00:05:20 +0900
Message-ID: <20070909061551G.tomof@acm.org>
References: <20070908084127G.tomof@acm.org>
	<46E2884B.2070107@garzik.org>
	<20070908120036.GB8478@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, tomof@acm.org, open-iscsi@googlegroups.com,
	davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, fujita.tomonori@lab.ntt.co.jp
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo11.iij4u.or.jp ([210.138.174.79]:45275 "EHLO mo11.iij4u.or.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756723AbXIIPF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Sep 2007 11:05:59 -0400
In-Reply-To: <20070908120036.GB8478@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 8 Sep 2007 13:00:36 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Sep 08, 2007 at 07:32:27AM -0400, Jeff Garzik wrote:
> > FUJITA Tomonori wrote:
> > >Yeah, iommu code ignores the lld limitations (the problem is that the
> > >lld limitations are in request_queue and iommu code can't access to
> > >request_queue). There is no way to tell iommu code about the lld
> > >limitations.
> > 
> > 
> > This fact very much wants fixing.
> 
> 
> Absolutely.  Unfortunately everyone wastes their time on creating workarounds
> instead of fixing the underlying problem.

Any ideas on how to fix this?

I chatted to Jens and James on this last week.

- we could just copies the lld limitations to device structure. it's
hacky but device structure already has hacky stuff.

- we could just link device structure to request_queue structure so
that iommu code can see request_queue structure.

- we could remove the lld limitations in request_queue strucutre and
have a new strucutre (something like struct io_restrictions). then
somehow we could link the new structure with request_queue and device
strucutres.
