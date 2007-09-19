From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT events get missed for TCP sockets
Date: Wed, 19 Sep 2007 16:50:17 -0700 (PDT)
Message-ID: <331107.71046.qm@web53704.mail.re2.yahoo.com>
References: <Pine.LNX.4.64.0709191552171.2989@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: tomer_iisc@yahoo.com, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Davide Libenzi <davidel@xmailserver.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53704.mail.re2.yahoo.com ([206.190.37.25]:36624 "HELO
	web53704.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751042AbXISXuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:50:18 -0400
In-Reply-To: <Pine.LNX.4.64.0709191552171.2989@alien.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Davide Libenzi <davidel@xmailserver.org> wrote:

> On Wed, 19 Sep 2007, David Miller wrote:
> 
> > From: Nagendra Tomar <tomer_iisc@yahoo.com>
> > Date: Wed, 19 Sep 2007 15:37:09 -0700 (PDT)
> > 
> > > With the SOCK_NOSPACE check in tcp_check_space(), this epoll_wait call will 
> > > not return, even when the incoming acks free the buffers.
> > >         Note that this patch assumes that the SOCK_NOSPACE check in
> > > tcp_check_space is a trivial optimization which can be safely removed.
> > 
> > I already replied to your patch posting explaining that whatever is
> > not setting SOCK_NOSPACE should be fixed instead.
> > 
> > Please address that, thanks.
> 
> You're not planning of putting the notion of a SOCK_NOSPACE bit inside a 
> completely device-unaware interface like epoll, I hope?
> 

Definitely not ! 

The point is that the "tcp write space available" 
wakeup does not get called if SOCK_NOSPACE bit is not set. This was
fine when the wakeup was merely a wakeup (since SOCK_NOSPACE bit 
indicated that someone really cared abt the wakeup). Now after the
introduction of callback'ed wakeups, we might have some work to
do inside the callback even if there is nobody interested in the wakeup
at that point of time. 

In this particular case the ep_poll_callback is not getting called and
hence the socket fd is not getting added to the ready list.

Thanx,
Tomar




      ___________________________________________________________
Yahoo! Answers - Got a question? Someone out there knows the answer. Try it
now.
http://uk.answers.yahoo.com/
