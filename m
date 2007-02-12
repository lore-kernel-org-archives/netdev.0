From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take36 10/10] kevent: Kevent based generic AIO.
Date: Mon, 12 Feb 2007 15:19:40 +0300
Message-ID: <20070212121940.GA31252@2ka.mipt.ru>
References: <11712796493850@2ka.mipt.ru> <1171279650540@2ka.mipt.ru> <p733b5bh6bp.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38175 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964880AbXBLMWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 07:22:39 -0500
Content-Disposition: inline
In-Reply-To: <p733b5bh6bp.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 12, 2007 at 02:08:10PM +0100, Andi Kleen (ak@suse.de) wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> > 
> > aio_sendfile_path() is essentially aio_sendfile(), except that it takes
> > source filename as parameter, has a pointer to private header
> > and its size (which allows to send header and file's content in one syscall
> > instead of three (open, send, sendfile) and returns opened file descriptor.
> 
> Are you sure this is a useful optimization? Do you have numbers vs open+aio_sendfile+close? 
> 
> Compared to the cost of sending a complete file three system calls should be quite in the noise. 
> And Linux system calls are not that expensive (few hundred cycles normally) 
> 
> Adding such compound system calls would be a worrying precedent because
> I'm sure others would want them then for their favourite system call combo
> too. If they were really useful it might make more sense to have a batch() 
> system call that works for arbitary calls, but I'm not convinced yet
> it's even needed. It would be certainly ugly.

Yes, that call ends up about 10MB/sec faster for 100 1mb file transfers
over 1gbit network (78 MB/s vs 66-72 MB/s over 1 Gb network, sendfile sending server 
is one-way AMD Athlong 64 3500+), but indeed, it can be the case that async IO sending 
was main speed factor.

I added header by request from Suparna Bhattacharya - my main position
is the same about syscall overhead, but I do not that care.

> -Andi

-- 
	Evgeniy Polyakov
