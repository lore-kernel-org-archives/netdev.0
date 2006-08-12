From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: Kernel patches enabling better POSIX AIO (Was Re: [3/4] kevent: AIO, aio_sendfile)
Date: Sat, 12 Aug 2006 15:28:02 -0400
Message-ID: <20060812192802.GO32572@devserv.devel.redhat.com>
References: <1153982954.3887.9.camel@frecb000686> <44C8DB80.6030007@us.ibm.com> <44C9029A.4090705@oracle.com> <1154024943.29920.3.camel@dyn9047017100.beaverton.ibm.com> <44C90987.1040200@redhat.com> <1154034164.29920.22.camel@dyn9047017100.beaverton.ibm.com> <1154091500.13577.14.camel@frecb000686> <44DCDE73.9030901@redhat.com> <20060812182928.GA1989@in.ibm.com> <44DE27AB.7040507@redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: suparna@in.ibm.com, sebastien.dugue@bull.net,
	Badari Pulavarty <pbadari@us.ibm.com>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-aio@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51169 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964942AbWHLT2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 15:28:25 -0400
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <44DE27AB.7040507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 12:10:35PM -0700, Ulrich Drepper wrote:
> > I am wondering about that too. IIRC, the IO_NOTIFY_* constants are not
> > part of the ABI, but only internal to the kernel implementation. I think
> > Zach had suggested inferring THREAD_ID notification if the pid specified
> > is not zero. But, I don't see why ->sigev_notify couldn't used directly
> > (just like the POSIX timers code does) thus doing away with the 
> > new constants altogether. Sebestian/Laurent, do you recall?
> 
> I suggest to model the implementation after the timer code which does
> exactly what we need.

Yeah, and if at all possible we want to use just one helper thread for
SIGEV_THREAD notification of timers/aio/etc., so it really should behave the
same as timer thread notification.

	Jakub
