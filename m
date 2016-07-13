From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/3] perf, events: add non-linear data support
 for raw records
Date: Wed, 13 Jul 2016 18:40:07 +0200
Message-ID: <20160713164007.GV30154@twins.programming.kicks-ass.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
 <f6ffffc1011706426682be92f80fc6aa6a8cc196.1468362046.git.daniel@iogearbox.net>
 <20160713134231.GT30154@twins.programming.kicks-ass.net>
 <57864B77.9090105@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57864B77.9090105@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 13, 2016 at 04:08:55PM +0200, Daniel Borkmann wrote:
> Hi Peter,
> 
> On 07/13/2016 03:42 PM, Peter Zijlstra wrote:
> >
> >Ok so the nonlinear thing was it doing _two_ copies, one the regular
> >__output_copy() on raw->data and second the optional fragment thingy
> >using __output_custom().
> >
> >Would something like this work instead?
> >
> >It does the nonlinear thing and the custom copy function thing but
> >allows more than 2 fragments and allows each fragment to have a custom
> >copy.
> >
> >It doesn't look obviously more expensive; it has the one ->copy branch
> >extra, but then it doesn't recompute the sizes.
> 
> Yes, that would work as well on a quick glance with diff just a bit
> bigger, but more generic this way. Do you want me to adapt this into
> the first patch?

Please.

> One question below:
> 

> >-			u64 zero = 0;

> >-			if (real_size - raw_size)
> >-				__output_copy(handle, &zero, real_size - raw_size);

> 
> We still need the zero padding here from above with the computed
> raw->size, right?

Ah, yes, we need some __output*() in order to advance the handle offset.
We don't _need_ to copy the 0s, but I doubt __output_skip() is much
cheaper for these 1-3 bytes worth of data; we've already touched that
line anyway.
