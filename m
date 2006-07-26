From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 14:08:49 +0400
Message-ID: <20060726100848.GA2715@2ka.mipt.ru>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru> <20060726100013.GA7126@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56514 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751198AbWGZKJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 06:09:28 -0400
To: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20060726100013.GA7126@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 11:00:13AM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> >  struct address_space_operations ext2_aops = {
> > +	.get_block		= ext2_get_block,
> 
> No way in hell.  For whatever you do please provide a interface at
> the readpage/writepage/sendfile/etc abstraction layer.  get_block is
> nothing that can be exposed to the common code.

Compare this with sync read methods - all they do is exactly the same
operations with low-level blocks, which are combined into nice exported
function, so there is _no_ readpage layer - it calls only one function
which works with blocks.

I would create the same, i.e. async_readpage(), which called kevent's
functions and processed low-level blocks, just like sync code does, but
that requires kevent to be deep part of the FS tree.

So I prefer to have
kevent/some_function_which_works_with_blocks_and_kevents() 

instead of
fs/some_function_which_works_with_block_and_kevents()
kevent/call_that_function_like_all_readpage_callbacks_do().

So it is not a technical problem, but political one.
-- 
	Evgeniy Polyakov
