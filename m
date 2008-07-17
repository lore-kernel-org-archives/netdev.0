From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Thu, 17 Jul 2008 21:41:56 +0400
Message-ID: <20080717174150.GA24002@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com> <20080717142132.GA11702@2ka.mipt.ru> <200807171747.27775.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:50961 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756077AbYGQRmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 13:42:16 -0400
Content-Disposition: inline
In-Reply-To: <200807171747.27775.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2008 at 05:47:27PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> > Existing behaviour was selected to be able to have a progress if socket
> > does not have enough data to fill the pipe. With your change if socket
> > is not opened with non-blocking mode reading will block not matter if
> > SPLICE_F_NONBLOCK is set or not. 
> 
> I am probably missing some usecases here, but usually if you want to use 
> non-blocking I/O you need to use special approach anyway (e.g. code the 
> poll/epoll/select bits) so then you could open the socket with O_NONBLOCK.

It depends. Splice clearly states that it tries to be nonblocking with
given flag being set, and its reading will be non-blocking indeed.

> > This is a quite serious break of the 
> > overall idea behind SPLICE_F_NONBLOCK.
> >
> 
> I don't know... the man page explicitly says that even when you use 
> SPLICE_F_NONBLOCK splice may block because of the underlying fd blocking.

Yes, but reading from the network will not.

> But more importantly, how can we solve the deadlock issue described in the 
> patch? Do we need all of the complications of async I/O for such a simple and 
> common usecase?

I'm not sure I understand how it can deadlock, please explain it in more
details.

-- 
	Evgeniy Polyakov
