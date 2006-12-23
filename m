From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take29 0/8] kevent: Generic event handling mechanism.
Date: Sat, 23 Dec 2006 20:10:26 +0300
Message-ID: <20061223171026.GA17343@2ka.mipt.ru>
References: <3154985aa0591036@2ka.mipt.ru> <11668927001365@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37324 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606AbWLWRLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Dec 2006 12:11:38 -0500
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <11668927001365@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 23, 2006 at 07:51:40PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> 
> Generic event handling mechanism.
> 
> Kevent is a generic subsytem which allows to handle event notifications.
> It supports both level and edge triggered events. It is similar to
> poll/epoll in some cases, but it is more scalable, it is faster and
> allows to work with essentially eny kind of events.
> 
> Events are provided into kernel through control syscall and can be read
> back through ring buffer or using usual syscalls.
> Kevent update (i.e. readiness switching) happens directly from internals
> of the appropriate state machine of the underlying subsytem (like
> network, filesystem, timer or any other).
> 
> Homepage:
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=kevent
> 
> Documentation page:
> http://linux-net.osdl.org/index.php/Kevent
> 
> Consider for inclusion.
> 
> New benchmark, which can be a hoax though, can be found at 
> http://tservice.net.ru/~s0mbre/blog/2006/11/30#2006_11_30
> where kevent on amd64 with 1gb of ram can handle more than 7200 events per 
> second with 8000 requests concurrency with 'ab' benchmark and lighttpd.
> Although I tought it should not be published due to possible errors,
> I decided to send it for review.
> 
> With this release I start 3 days resending timeout - i.e. each third day I 
> will send either new version (if something new was requested and agreed to 
> be implemented) or resending with back counter started from three. 
> When back counter hits zero after three resending I consider there is no 
> interest in subsystem and I will stop further sending.
> First one will be sent about Jan 10.
> 
> Thanks for understanding and your time.
> 
> Changes from 'take28' patchset:
>  * optimized af_unix to use socket notifications
>  * changed ALWAYS_QUEUE behaviour with poll/select notifications - previously
>  	kevent was not queued into poll wait queue when ALWAYS_QUEUE flag
> 	is set
>  * added KEVENT_POLL_POLLRDHUP definition into ukevent.h header
>  * libevent-1.2 patch (Jamal, your request is completed, so I'm waiting two weeks
>  	before starting final countdown :)
> 	All regression tests passed successfully except test_evbuffer(), which
> 	crashes on my amd64 linux 2.6 test machine for all types of notifications,
> 	probably it is fixed in libevent-1.2a version, I did not check.
> 	Patch and README can be found at project homepage.

P.S. all kernel kevent options must be turned on (namely kevent_poll,
kevent_socket and kevent_pipe).
I did not hack 'configure' to check for supported notification types.

-- 
	Evgeniy Polyakov
