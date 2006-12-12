From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take26-resend1 7/8] kevent: Signal notifications.
Date: Tue, 12 Dec 2006 08:45:28 +0300
Message-ID: <20061212054526.GD14420@2ka.mipt.ru>
References: <116584861971@2ka.mipt.ru> <11658486191971@2ka.mipt.ru> <3f250c710612110832i337470cyc1fe0805a8aba2e6@mail.gmail.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55392 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751187AbWLLFqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 00:46:06 -0500
To: Mauricio Lin <mauriciolin@gmail.com>
Content-Disposition: inline
In-Reply-To: <3f250c710612110832i337470cyc1fe0805a8aba2e6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 11, 2006 at 12:32:55PM -0400, Mauricio Lin (mauriciolin@gmail.com) wrote:
> Hi Evgeniy,

Hi Mauricio.

> I have used kobject_uevent() to notify userspace about some events.
> For instance, when memory comsumption reaches a predefined watermark,
> a signal is sent to userspace to allow applications to free resources.
> But I am not sure if kobject_uevent() is the more appropriate way for
> that since if I have many different levels of notifications (using
> kobject_uevent()) from kernel space to user space, so how the
> application could know or differentiate from which level of kernel
> notification the signal was sent from?
> 
> The application should perform a specific task according to different
> type of received notification. So I do not know if the current kernel
> provides something like that. Do you know any current kernel (2.6.19)
> implementation for that?
> 
> After reading about your Kevent implementation, I guess that your
> patches are able to do what I need, right? Will it be included in the
> mainline kernel? Do you have examples about how can I use your socket
> and/or signal notifications to establish kernel and user space
> communication?

I do not know if it will be included or not, but would like to hear an
opinion of people added to Cc: list on that point.

I have a lot of examples from trivial applications to real-world web
server patched with kevent support. Although some applications might not
compile with the latest kevent sources due to interface parameters
changes, it is easily fixable looking into other examples.

According to your task - yes, it can be done through kevent - you need
to create own kevent subsystem if you plan to use something special,
register it with kevent and start commiting events.
But it is easier to use different notification mechanisms for that task:
I suggest using netlink based connector, gennetlink or kobject_uevent,
although the latter is not the best choice definitely, and create own
protocol embedded into that transports.

> BR,
> 
> Mauricio Lin.

-- 
	Evgeniy Polyakov
