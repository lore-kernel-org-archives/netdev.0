From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 09:18:25 +0000
Message-ID: <20091113091825.GA7449@ff.dom.local>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com> <20091113074508.GA6605@ff.dom.local> <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:42121 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755660AbZKMJS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 04:18:27 -0500
Received: by fxm21 with SMTP id 21so209581fxm.21
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 01:18:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 04:54:50PM +0800, Changli Gao wrote:
> On Fri, Nov 13, 2009 at 3:45 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On 13-11-2009 07:16, Changli Gao wrote:
> >
> > I don't think so. There would be a lot of code duplication and later
> > maintenance problems only because of the scheduling method. The main
> > question is to establish if there is really no performance difference
> > (which I doubt) - unless Changli can show some tests for various
> > setups now. On the other hand, if there is a difference, why keep
> > ineffective solution - similar thing should be possible to do in the
> > softirq context as well.
> >
> > So it should not be a big problem to do it a bit messy for some
> > testing time. Since we can use separate ->ndo_start_xmit() etc. it
> > shouldn't be too messy, I guess.
> >
> 
> I have done a simple test. I run a simple program on computer A, which
> sends SYN packets with random source ports to Computer B's 80 port (No
> socket listens on that port, so tcp reset packets will be sent) in
> 90kpps. On computer B, I redirect the traffic to IFB. At the same
> time, I ping from B to A to get the RTT between them. I can't see any
> difference between the original IFB and my MQ version. They are both:
> 
> CPU idle: 50%
> Latency: 0.3-0.4ms, burst 2ms.
> 

I'm mostly concerned with routers doing forwarding with 1Gb or 10Gb
NICs (including multiqueue). Alas/happily I don't have such a problem,
but can't help you with testing either.

Regards,
Jarek P.
