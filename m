From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] tun: stop tx queue when limit is hit
Date: Mon, 21 Jul 2014 11:19:13 +0200
Message-ID: <20140721091913.GD21375@breakpoint.cc>
References: <1405882285-3072-1-git-send-email-fw@strlen.de>
 <20140720.223313.1589952322700027038.davem@davemloft.net>
 <20140721065419.GB21375@breakpoint.cc>
 <20140721083106.GC21375@breakpoint.cc>
 <1405932999.10255.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mst@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52914 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752245AbaGUJTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 05:19:17 -0400
Content-Disposition: inline
In-Reply-To: <1405932999.10255.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-07-21 at 10:31 +0200, Florian Westphal wrote:
> > Michael, do you think we could restore the 'stop queue' default
> > behaviour?
> > 
> > Looking at your changelog, the only concern seems to be the
> > 'packets never consumed'/'receiver is stuck forever' case.
> > 
> > What about reverting 5d097109257c03a7184, and then adding some
> > type of tun watchdog that will zap the rcv queue + tx queue wakeup?
> > 
> > That should be quite noisy if we combine it with the WARN_ON
> > you usually get when (physical) NIC driver detect stalled tx unit.
> > 
> > What do you think?
> 
> Note that this patch had the ability to choose the behavior (drop or
> back pressure)
> 
>  http://patchwork.ozlabs.org/patch/338951/ ?

Eric, many thanks for this pointer.  In fact, the related discussions
in v2 of the patchset (http://patchwork.ozlabs.org/patch/338803/)
also answers my questions above.

[ the concern is with applications that can get stuck just because
  packet they sent is queued forever ]

I need to think about this some more, but in any case Michael outlined
a possible solution (limit queue delay) in the thread above.

Thanks,
Florian
