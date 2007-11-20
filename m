From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 03:55:58 -0800 (PST)
Message-ID: <20071120.035558.214794900.davem@davemloft.net>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au>
	<20071119.222214.81458569.davem@davemloft.net>
	<4742C96D.3050203@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37343
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752915AbXKTLz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 06:55:59 -0500
In-Reply-To: <4742C96D.3050203@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue, 20 Nov 2007 06:47:57 -0500

> David Miller wrote:
>  > From: Herbert Xu <herbert@gondor.apana.org.au>
>  > Date: Tue, 20 Nov 2007 14:09:18 +0800
>  >
>  >> David Miller <davem@davemloft.net> wrote:
>  >>> Fundamentally, I really don't like this change, it batches to the
>  >>> point where it begins to erode the natural ACK clocking of TCP, and I
>  >>> therefore am very likely to revert it before merging to Linus.
>  >> Perhaps make it a tunable that defaults to off?
>  >
>  > That's one idea.
> 
> I'd certainly prefer the option to have a tunable to having our
> customers see performance regressions when they switch to
> the kernel's LRO.

Please qualify this because by itself it's an inaccurate statement.

It would cause a performance regression in situations where the is
nearly no packet loss, no packet reordering, and the receiver has
strong enough cpu power.

Because in fact, some "customers" might see performance regressions
by using this ack aggregation code.  In particular if they are
talking to the real internet at all.

> If vendors are going to pick this up, there is the risk of them just
> applying this patch (which currently has no tunable to disable it),
> leaving their users stuck with it enabled.

I will watch out for this and make sure to advise them strongly not to
do this.

So you can be sure this won't happen. :-)

> FWIW, we've seen TCP perform well in a WAN setting using our NICs and
> our LRO which does this ack aggregation.  For example, the last 2
> Supercomputing "Bandwidth Challenges" (making the most of a 10Gb/s
> WAN connection) were won by teams using our NICs, with drivers that
> did this sort of ack aggregation.

And basically nearly no packet loss, which just supports my objections
to this even more.  ANd this doesn't even begin to consider the RX
cpu limited cases, where again ACK stretching hurts a lot.

The bandwidth challenge cases are not very realistic at all, and are
about as far from the realities of real internet traffic as you can
get.

Show me something over real backbones, talking to hundres or thousands
of clients scattered all over the world.  That's what people will be
using these high end NICs for front facing services, and that's where
loss happens and stretch ACKs hurt performance.

ACK stretching is bad bad bad for everything outside of some well
controlled test network bubble.
