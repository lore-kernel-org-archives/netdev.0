From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Wed, 3 Sep 2008 17:18:15 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0809031703480.3515@nehalem.linux-foundation.org>
References: <20080903.161341.239039051.davem@davemloft.net> <alpine.LFD.1.10.0809031615450.3515@nehalem.linux-foundation.org> <alpine.LFD.1.10.0809031621160.3515@nehalem.linux-foundation.org> <20080903.162603.27086959.davem@davemloft.net>
 <20080904000103.GF5967@tesla>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"tomasw@gmail.com" <tomasw@gmail.com>,
	"yi.zhu@intel.com" <yi.zhu@intel.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>
To: "Luis R. Rodriguez" <lrodriguez@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41104 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784AbYIDATR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 20:19:17 -0400
In-Reply-To: <20080904000103.GF5967@tesla>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 3 Sep 2008, Luis R. Rodriguez wrote:
> 
> What I think really happens here IMHO is communication needs to be
> enhanced. I only recently noticed that "regression only" policy for
> 2.6.27 for example. I think some of us were rather surprised by it too.

It's really not a "2.6.27" policy, it's always been a "merge window" vs 
"-rc" policy. It's just that I've started making more noise about it, 
since many people don't seem to see what the point of the merge window is.

And no, the problem isn't new either. But it does seem to have been 
getting somewhat worse lately. Possibly simply because we have more code 
(ie releases have grown, which has made the problem more visible, even if 
it hasn't necessarily changed in any other way).

> Before snapping at people for not following "orders" we need a clear
> guideline for what should or not be sent.

The basic rule really should be:

 - *any* new development should target the merge window. 

   I think some of the driver people in particular have been mislead by 
   the fact that we have actually accepted new drivers even after the 
   merge window ("they can't regress"), and that in turn has probably 
   de-sensitized people a bit to the whole merge window.

   Similarly, drivers (and other wholly self-contained modules like 
   filesystems etc) that didn't exist before - even if they were then
   merged _during_ the merge window - have also been getting leeway in the 
   -rc code, since again they cannot regress.

And it really does appear like a lot of driver people just get very comfy 
and used to that _first_ release, when we allow almost anything. And then 
they just continue with it.

> To avoid it I do think another exception needs to be made for patches:
> 
> * Small fixes which make something that was not working, which was
>   supposed to work work

Not really.

The thing is, if it's a driver that has been around for more than a single 
release, then those "small fixes" really can't be worth all that much. And 
yes, they may be small, and yes, they may be "obvious", but the fact is, 
they definitely can regress.

Sure, if some driver really haven't been around for very long, I can see 
your point. Not very many people have used it, and I can well imagine that 
there are lots of those "small fixes" that really do matter.

but if the driver has been in active use for a few kernel versions, there 
really is almost no excuse to say "this fix is so important that it needs 
to go in even though it's not a regression/security/oops fix".

So I would agree that the very first release a new driver (or filesystem) 
is in is special. Almost anything goes during the -rc releases leading up 
to that. And yes, I can well imagine that during the -rc for the second 
release it perhaps makes sense to be a _bit_ more relaxed, simply because 
it's young and as more people use it, silly (but serious) issues can just 
become more obvious.

But in the long run? No. Drivers are not different from any other code, 
and the -rc rules should be "regressions only".

In fact, in many ways we should be even _more_ careful with drivers than 
with most other things, because driver changes are seldom "obvious". Even 
really trivial stuff can interact with hardware in odd ways, in ways that 
is seldom true of normal code that you can think about and analyze (since 
we assume that the CPU itself doesn't have subtle timing etc bugs, of 
course).

			Linus
