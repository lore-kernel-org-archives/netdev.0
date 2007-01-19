From: Suparna Bhattacharya <suparna@in.ibm.com>
Subject: Re: [take33 10/10] kevent: Kevent based AIO (aio_sendfile()/aio_sendfile_path()).
Date: Fri, 19 Jan 2007 11:57:00 +0530
Message-ID: <20070119062700.GA14705@in.ibm.com>
References: <11690154353959@2ka.mipt.ru> <11690154352501@2ka.mipt.ru> <20070117135142.GA24866@in.ibm.com> <20070117143950.GA19434@2ka.mipt.ru>
Reply-To: suparna@in.ibm.com
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20070117143950.GA19434@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 05:39:51PM +0300, Evgeniy Polyakov wrote:
> On Wed, Jan 17, 2007 at 07:21:42PM +0530, Suparna Bhattacharya (suparna@in.ibm.com) wrote:
> >
> > Since you are implementing new APIs here, have you considered doing an
> > aio_sendfilev to be able to send a header with the data ?
> 
> It is doable, but why people do not like corking?
> With Linux less than microsecond syscall overhead it is better and more
> flexible solution, doesn't it?

That is what I used to think as well. However ...

The problem as I understand it now is not about bunching data together, but
of ensuring some sort of atomicity between the header and the data, when
there can be multiple outstanding aio requests on the same socket - i.e
ensuring strict ordering without other data coming in between, when data
to be sent is not already in cache, and in the meantime another sendfile
or aio write requests comes in for the same socket. Without having to lock
the socket when reading data from disk.

There are alternate ways to address this, aio_sendfilev is one of the options
I have heard people requesting.

Regards
Suparna

> 
> I'm not saying - 'no, there will not be any *v variants', just getting
> more info.
> 
> > Regards
> > Suparna
> 
> --
> 	Evgeniy Polyakov

-- 
Suparna Bhattacharya (suparna@in.ibm.com)
Linux Technology Center
IBM Software Lab, India

