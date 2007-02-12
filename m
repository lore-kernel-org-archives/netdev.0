From: Andi Kleen <ak@suse.de>
Subject: Re: [take36 10/10] kevent: Kevent based generic AIO.
Date: 12 Feb 2007 14:08:10 +0100
Message-ID: <p733b5bh6bp.fsf@bingen.suse.de>
References: <11712796493850@2ka.mipt.ru> <1171279650540@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1171279650540@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> 
> aio_sendfile_path() is essentially aio_sendfile(), except that it takes
> source filename as parameter, has a pointer to private header
> and its size (which allows to send header and file's content in one syscall
> instead of three (open, send, sendfile) and returns opened file descriptor.

Are you sure this is a useful optimization? Do you have numbers vs open+aio_sendfile+close? 

Compared to the cost of sending a complete file three system calls should be quite in the noise. 
And Linux system calls are not that expensive (few hundred cycles normally) 

Adding such compound system calls would be a worrying precedent because
I'm sure others would want them then for their favourite system call combo
too. If they were really useful it might make more sense to have a batch() 
system call that works for arbitary calls, but I'm not convinced yet
it's even needed. It would be certainly ugly.

-Andi
