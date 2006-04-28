From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 21:55:39 +0400
Message-ID: <20060428175538.GA13898@2ka.mipt.ru>
References: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com> <20060428101833.2f0d6ae8@localhost.localdomain> <20060428172932.GB16916@2ka.mipt.ru> <20060428104118.6a056a59@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Caitlin Bestler <caitlinb@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60908 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751426AbWD1SAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 14:00:08 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060428104118.6a056a59@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 10:41:18AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> On Fri, 28 Apr 2006 21:29:32 +0400
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > On Fri, Apr 28, 2006 at 10:18:33AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> > > Please just use existing AIO interface.  We don't need another
> > > interface. The number of interfaces increases the exposed bug
> > > surface geometrically.  Which means for each new interface, it
> > > means testing and fixing bugs in every possible usage.
> > 
> > Networking AIO? Like [1] :)
> > That would be really good.
> > 
> > 1. http://tservice.net.ru/~s0mbre/old/?section=projects&item=naio
> > 
> 
> The existing infrastructure is there in the syscall layer, it just
> isn't really AIO for sockets. That naio project has two problems, first
> they require driver changes, and he is doing it on the stupidest
> of hardware, optimizing a 8139too is foolish.

No, it does not. You confuse it with receiving zero-copy support which
allows to DMA data directly into VFS cache [1].
NAIO works for any kind of hardware and was tested with e1000 and showed
noticeble win in both CPU usage and network performance.

> Second, introducing
> kevents, seems unnecessary and hasn't been accepted in the mainline.

kevent was never sent to lkml@ although it showed over 40% win over epoll for
test web server. Sending it to lkml@ is just jumping into ... not into
technical world, so I posted it first here, but without much attention
though.

> The existing linux AIO model seems sufficient:
> 	http://lse.sourceforge.net/io/aio.html
> 
> There is work to put true Posix AIO on top of this.

There are a lot of discussions about combining AIO with epoll and 
combine them into something similar to kevent which allows to monitor
level and edge triggered events, to create proper state machine for AIO
compeltions. kevent [2] does exactly that. AIO works not as state
machine, but it's repeated-check design is more like postponing work
from one context to special thread.

1. receiving zero-copy support 
http://tservice.net.ru/~s0mbre/old/?section=projects&item=recv_zero_copy

2. kevent system
http://tservice.net.ru/~s0mbre/old/?section=projects&item=kevent

-- 
	Evgeniy Polyakov
