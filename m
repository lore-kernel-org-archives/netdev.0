From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 11:13:56 +0100
Message-ID: <20060726101356.GA8443@infradead.org>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru> <20060726100013.GA7126@infradead.org> <20060726100848.GA2715@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:2961 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932086AbWGZKN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 06:13:57 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060726100848.GA2715@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 02:08:49PM +0400, Evgeniy Polyakov wrote:
> On Wed, Jul 26, 2006 at 11:00:13AM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> > >  struct address_space_operations ext2_aops = {
> > > +	.get_block		= ext2_get_block,
> > 
> > No way in hell.  For whatever you do please provide a interface at
> > the readpage/writepage/sendfile/etc abstraction layer.  get_block is
> > nothing that can be exposed to the common code.
> 
> Compare this with sync read methods - all they do is exactly the same
> operations with low-level blocks, which are combined into nice exported
> function, so there is _no_ readpage layer - it calls only one function
> which works with blocks.

No.  The abtraction layer there is ->readpage(s).  _A_ common implementation
works with a get_block callback from the filesystem, but there are various
others.  We've been there before, up to mid-2.3.x we had a get_block inode
operation and we got rid of it because it is the wrong abstraction.

> So it is not a technical problem, but political one.

It's a technical problem, and it's called get you abstractions right.  And
ontop of that a political one and that's called get your abstraction coherent.
If you managed to argue all of us into accept that get_block is the right
abstraction (and as I mentioned above that's technically not true) you'd
still have the burden to update everything to use the same abstraction.
