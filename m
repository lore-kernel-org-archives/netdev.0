From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take36 10/10] kevent: Kevent based generic AIO.
Date: Mon, 12 Feb 2007 16:24:21 +0300
Message-ID: <20070212132421.GA7578@2ka.mipt.ru>
References: <11712796493850@2ka.mipt.ru> <1171279650540@2ka.mipt.ru> <p733b5bh6bp.fsf@bingen.suse.de> <20070212131257.565f8066@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andi Kleen <ak@suse.de>, David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Alan <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070212131257.565f8066@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 12, 2007 at 01:12:57PM +0000, Alan (alan@lxorguk.ukuu.org.uk) wrote:
> > I'm sure others would want them then for their favourite system call combo
> > too. If they were really useful it might make more sense to have a batch() 
> > system call that works for arbitary calls, but I'm not convinced yet
> > it's even needed. It would be certainly ugly.
> 
> batch() would possibly make a lot of sense in terms of the fibril/thread
> based removal for the need for all the AIO stuff, just to provide a
> natural way to group and order sequences of synchronous operations into
> asynchronous groups.
> 
> I am extremely sceptical about the need for aio_sendfile_path since with
> sendfile/sendpath hacking around there didn't seem to be much gain.
> 
> I'm even more sceptical of the header buffer stuff as while other OS's do
> that as a hack to make TCP packetising work we simply fixed the root
> problem with TCP_CORK

Well, that does not matter that much - that syscall is an example of how
kevent AIO state machine works - it trivially allows to have async
open/send/sendfile/close like aio_senfile_path.

I would remove header too (it was not there in the first release, added
on request), but the whole idea of async open/send/close seems natural 
for web-like workloads, when user should not even care about proper state 
machine.

Having batch() mode would be good too - with kevent state machine it is
quite trivially: 
req = kaio_add_call(NULL, first_call)
kaio_append_call(req, second_call);
kaio_append_call(req, third_call);
...
kaio_schedule_req(req);

Yes, state machine handling requires additional code, but when it ends
up in faster processing implementation complexities deserve its price.

> Alan

-- 
	Evgeniy Polyakov
