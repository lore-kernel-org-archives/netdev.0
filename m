From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same
 port
Date: Thu, 17 Jan 2013 06:27:41 -0800
Message-ID: <1358432861.29723.11.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B710E@saturn3.aculab.com>
	 <CA+mtBx-DRiSg4z5OUvp4=pJxZ=Ki4pt-vz716ubsJx1PHnD7Nw@mail.gmail.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7112@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, netdev@markandruth.co.uk
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:38633 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab3AQO1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 09:27:44 -0500
Received: by mail-pb0-f49.google.com with SMTP id un15so1428714pbc.8
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 06:27:44 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7112@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 09:53 +0000, David Laight wrote:
> > We had considered solving this within accept.  The problem is that
> > there's no way to indicate how much work a thread should do via
> > accept.  For instance, an event loop usually would look like:
> > 
> > while (1) {
> >     fd = accept();
> >     process(fd);
> > }
> > 
> > With multiple threads, the number of accepted sockets in a particular
> > thread is non-deterministic...
> 
> If your loop looks like that then each thread is only processing
> a single socket and won't call accept() again until it is idle.
> 
> OTOH if each thread is processing multiple requests using
> poll/select (or similar) at the top of the loop then a single
> thread is likely to pick up a large number of connections.
> 
> Given that both poll and select are inefficient with very large
> numbers of fds (every call is usually o(n) [1]), the kernel will
> support some kind of event mechanism, maybe tweaking that to
> signal the waiters in turn would also work - and be more general.
> 
> It might also be possible to do something on the user side of
> sockets to generate additional fd with their own queue?
> (IMHO some of the SCTP stuff should have been done that way).

I hope you dont really believe Tom was going to explain how
a typical server is built around the accept() thing.

Linux has epoll() mechanism, so the poll()/select() O(n) behavior
are not relevant for modern applications.
