From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
Date: Thu, 24 May 2012 19:32:09 +0200
Message-ID: <1337880729.2388.23.camel@localhost>
References: <1337864467.13491.15.camel@localhost>
	 <201205241529.37684.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, netdev <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab2EXRcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 13:32:18 -0400
In-Reply-To: <201205241529.37684.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-24 at 15:20 +0200, Hans Schillstrom wrote:
> Hi Jesper
> We are also working with this issue right now,
> 
[..] 
> > [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
> > 
> > TCP SYN handling is on the slow path via tcp_v4_rcv(), and is
> > performed while holding spinlock bh_lock_sock().
> > 
> > Real-life and testlab experiments show, that the kernel choks
> > when reaching 130Kpps SYN floods (powerful Nehalem 16 cores).
> > Measuring with perf reveals, that its caused by
> > bh_lock_sock_nested() call in tcp_v4_rcv().
> 
> I can confirm this too, and it doesn't scale with more cores
> 
> > 
> > With this patch, the machine can handle 750Kpps (max of the SYN
> > flood generator) with cycles to spare.
>
> This looks great.

Yes, its definitely shows that there is huge performance gain hidden
here! But we still have to handle locking (which will affect perf).

> I'm also working with a solution that not trash conntack
> i.e. have conntrack working during a heavy SYN attack

Sounds interesting, but that's a separate problem.  In this case I have
disabled conntracking (I even disabled flow-control and drop the syn-ack
responses on the generator).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
