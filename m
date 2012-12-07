From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] dynamic_queue_limit.h: Make the struct
 ___cacheline_aligned_on_smp
Date: Fri, 07 Dec 2012 08:05:46 -0800
Message-ID: <1354896346.29937.43.camel@joe-AO722>
References: <1354892334.29937.14.camel@joe-AO722>
	 <CAL4Wiip12_Frb64WGk419_YApOuckTa3Jtd-nVROodLFTqvacg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47047 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030835Ab2LGQFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 11:05:46 -0500
In-Reply-To: <CAL4Wiip12_Frb64WGk419_YApOuckTa3Jtd-nVROodLFTqvacg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-07 at 07:55 -0800, Eric Dumazet wrote:
> 2012/12/7 Joe Perches <joe@perches.com>:
> > Given that the struct will always have limit at the start of
> > a cacheline, why not make  struct ___cacheline_aligned_on_smp
> > and make limit the first member?
> >
> > It could make other structs that use struct dql a bit more
> > predictable or efficient to pack.
> >
> > (netdev_queue is size reduced from 256 to 192 on x86-32)
> >
> 
> No, please.
> 
> Have you tested this on a range of hardware and check how it can hurt
> performance ?

No.  Hence the RFC subject title and
unsigned patch.

I was wondering though about cacheline ping-pong 
effects.

I noted Tom's comment back in
http://patchwork.ozlabs.org/patch/108856/
"Also, the cache line containing the struct dql can ping-pong between
CPUs doing initiation and completion.  (I know we're aiming for these to
be the same, but we can't yet assume they will be.)"

So it seemed somewhat sensible to make the
entire struct in a single cacheline.
