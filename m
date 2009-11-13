From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 08:15:53 -0800
Message-ID: <20091113081553.0568296c@s6510>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
	<20091113074508.GA6605@ff.dom.local>
	<412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com>
	<20091113091825.GA7449@ff.dom.local>
	<412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35969 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755729AbZKMQQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 11:16:15 -0500
In-Reply-To: <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 17:38:56 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Fri, Nov 13, 2009 at 5:18 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On Fri, Nov 13, 2009 at 04:54:50PM +0800, Changli Gao wrote:
> >> On Fri, Nov 13, 2009 at 3:45 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> >>
> >> I have done a simple test. I run a simple program on computer A, which
> >> sends SYN packets with random source ports to Computer B's 80 port (No
> >> socket listens on that port, so tcp reset packets will be sent) in
> >> 90kpps. On computer B, I redirect the traffic to IFB. At the same
> >> time, I ping from B to A to get the RTT between them. I can't see any
> >> difference between the original IFB and my MQ version. They are both:
> >>
> >> CPU idle: 50%
> >> Latency: 0.3-0.4ms, burst 2ms.
> >>
> >
> > I'm mostly concerned with routers doing forwarding with 1Gb or 10Gb
> > NICs (including multiqueue). Alas/happily I don't have such a problem,
> > but can't help you with testing either.
> >
> 
> Oh, :) . I know more than one companies use kernel threads to forward
> packets, and there isn't explicit extra overhead at all. And as you
> know, as throughput increases, NAPI will bind the NIC to a CPU, and
> softirqd will be waked up to do the work, which should be done in
> SoftIRQ context. At that time, there isn't any difference between my
> approach and the current kernel's.
> 
> 

Why not make IFB a NAPI device. This would get rid of the extra soft-irq
round trip from going through netif_rx().  It would also behave like
regular multi-queue recieive device, and eliminate need for seperate
tasklets or threads.

