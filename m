From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 08:27:05 -0500
Message-ID: <4742E0A9.2070205@myri.com>
References: <E1IuMIQ-0003gc-00@gondolin.me.apana.org.au>	<20071119.222214.81458569.davem@davemloft.net>	<4742C96D.3050203@myri.com> <20071120.035558.214794900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1910 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753698AbXKTN1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 08:27:45 -0500
In-Reply-To: <20071120.035558.214794900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
 > From: Andrew Gallatin <gallatin@myri.com>
 > Date: Tue, 20 Nov 2007 06:47:57 -0500
 >
 >> David Miller wrote:
 >>  > From: Herbert Xu <herbert@gondor.apana.org.au>
 >>  > Date: Tue, 20 Nov 2007 14:09:18 +0800
 >>  >
 >>  >> David Miller <davem@davemloft.net> wrote:
 >>  >>> Fundamentally, I really don't like this change, it batches to the
 >>  >>> point where it begins to erode the natural ACK clocking of TCP, 
and I
 >>  >>> therefore am very likely to revert it before merging to Linus.
 >>  >> Perhaps make it a tunable that defaults to off?
 >>  >
 >>  > That's one idea.
 >>
 >> I'd certainly prefer the option to have a tunable to having our
 >> customers see performance regressions when they switch to
 >> the kernel's LRO.
 >
 > Please qualify this because by itself it's an inaccurate statement.
 >
 > It would cause a performance regression in situations where the is
 > nearly no packet loss, no packet reordering, and the receiver has
 > strong enough cpu power.

Yes, a regression of nearly 1Gb/s in some cases as I mentioned
when I submitted the patch.

<....>

 > Show me something over real backbones, talking to hundres or thousands
 > of clients scattered all over the world.  That's what people will be
 > using these high end NICs for front facing services, and that's where
 > loss happens and stretch ACKs hurt performance.
 >

I can't.  I think most 10GbE on endstations is used either in the
sever room, or on dedicated links.  My experience with 10GbE users is
limited to my interactions with people using our NICs who contact our
support.  Of those, I can recall only a tiny handful who were using
10GbE on a normal internet facing connection (and the ones I dealt
with were actually running a different OS).  The vast majority were in
a well controlled, lossless environment.  It is quite ironic.  The
very fact that I cannot provide you with examples of internet facing
people using LRO (w/ack aggr) in more normal applications tends to
support my point that most 10GbE users seem to be in lossless
environments.

 > ACK stretching is bad bad bad for everything outside of some well
 > controlled test network bubble.

I just want those in the bubble to continue have the best performance
possible in their situation.  If it is a tunable the defaults to off,
that is great.

Hmm.. rather than a global tunable, what if it was a
network driver managed tunable which toggled a flag in the
lro_mgr features?  Would that be better?

Drew
