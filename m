From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] kevent: core files.
Date: Sat, 24 Jun 2006 00:54:02 +0400
Message-ID: <20060623205401.GB26168@2ka.mipt.ru>
References: <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru> <20060623.131940.48806210.davem@davemloft.net> <20060623203114.GD14126@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:11660 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751900AbWFWUyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 16:54:07 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060623203114.GD14126@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 04:31:14PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> may well be the way to go.  What I do not agree is that we need new 
> syscalls at this point.  I'm perfectly willing to accept proof that change 
> is needed if we do a proper comparision between any new syscall API and the 
> use of the existing syscall API, but the pain of introducing a new API is 
> sufficiently large that I think it is worth looking at the numbers.

New syscall is just an interface. Originally kevent (and it still can)
use char device and it's ioctl method.
It is perfectly possible to create wrappers for posix aio_* calls,
although I do not see why it is needed.
No need to concentrate on end-users interface at this point - it can be
changed at any time since design allows it, we should think about
overall design and if it is ok, move forward in implementation.

Btw, new API adds only one syscall for userspace kevent processing (and
three for send/recv/sendfile for network AIO).

According to numbers: kevent compared to epoll resulted in the
folllowing numbers:
kevent: more than 2600 requests per second (trivial web server)
epoll: about 1600-1800 requests.
Number of errors for 3k bursts of connections with 30K connections total
in 10seconds:
kevent: about 2k errors.
epoll: upto 15k errors.

More detailed results can be found on project's homepage at:
tservice.net.ru/~s0mbre/old/?section=projects&item=kevent

> 		-ben

-- 
	Evgeniy Polyakov
