From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH]: Fix sk_buff page offsets and lengths.
Date: Tue, 31 Jul 2007 18:00:55 +0400
Message-ID: <20070731140054.GA11442@2ka.mipt.ru>
References: <20070730.185028.26532012.davem@davemloft.net> <20070731102050.GB30330@2ka.mipt.ru> <20070731122329.GB11380@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, shemminger@linux-foundation.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58118 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756984AbXGaOBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 10:01:43 -0400
Content-Disposition: inline
In-Reply-To: <20070731122329.GB11380@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 31, 2007 at 01:23:29PM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> On Tue, Jul 31, 2007 at 02:20:51PM +0400, Evgeniy Polyakov wrote:
> > On Mon, Jul 30, 2007 at 06:50:28PM -0700, David Miller (davem@davemloft.net) wrote:
> > > 
> > > Stephen Rothwell pointed out to me that the skb_frag_struct
> > > is broken on platforms using 64K or larger page sizes, it
> > > even generates warnings when (for example) the myri10ge driver
> > > tries to assign PAGE_SIZE into frag->size.
> > > 
> > > I've thus increased page offset and size to __u32 in the patch below.
> > 
> > Maybe wrap it into 
> > #if PAGE_OFFSET > 12
> > #endif
> > 
> > or something like that?
> > 
> > I'm not sure actually why drivers would want to have list of 64k pages,
> > instead driver could call give_me_pages(size) instead of alloc_pages 
> > and per-arch allocator would return one page or set of pages. This is a
> > handwaving for now...
> 
> What about sendfile/splice on hugetlbfs?

offset in tcp_sendpage() ends up being poffset % PAGE_SIZE,
page is 
struct page *page = pages[poffset / PAGE_SIZE];

So, as far as I understand, it will split bigpage into PAGE_SIZEd
chunks.

-- 
	Evgeniy Polyakov
