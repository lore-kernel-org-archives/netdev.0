From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH] crypto: talitos: Avoid excessive loops in softirq
 context
Date: Fri, 12 Sep 2014 18:21:26 -0500
Message-ID: <20140912182126.2d913df25f491416c3a1a677@freescale.com>
References: <1410338087-5317-1-git-send-email-helmut.schaa@googlemail.com>
	<20140911194918.9ea4795f7bb3f9d6e32490eb@freescale.com>
	<CAGXE3d-EiYmJQfEwS9VeR3-5vePNzc2+N20hQTw0vY8FKhJYRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-crypto@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Sandeep Malik <Sandeep.Malik@freescale.com>,
	Horia Geanta <horia.geanta@freescale.com>,
	<netdev@vger.kernel.org>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAGXE3d-EiYmJQfEwS9VeR3-5vePNzc2+N20hQTw0vY8FKhJYRA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[adding Sandeep, Horia and netdev]

On Fri, 12 Sep 2014 09:39:12 +0200
Helmut Schaa <helmut.schaa@googlemail.com> wrote:

> On Fri, Sep 12, 2014 at 2:49 AM, Kim Phillips
> <kim.phillips@freescale.com> wrote:
> > On Wed, 10 Sep 2014 10:34:47 +0200
> > Helmut Schaa <helmut.schaa@googlemail.com> wrote:
> >
> >> The talitos driver can cause starvation of other softirqs and as such
> >> it can also cause rcu stalls like:
> > ...
> >> Work around this by processing a maximum amount of 16 finished requests
> >> and rescheduling the done-tasklet if any work is left.
> >> This allows other softirqs to run.
> >
> > 16 sounds rather arbitrary, and application-dependent - talitos'
> > FIFO size is 24.
> 
> Yep, 16 is arbitrary, I can also do "fifo_len" if you prefer?
> 
> > IIRC, netdev's NAPI can be refactored out of just being able to work
> > on network devices, and be made to apply to crypto devices, too.  In
> > fact, some old Freescale hacks of this nature have improved
> > performance.  Can we do something like refactor NAPI instead?
> 
> That would indeed be nice but sounds like quite some more work and
> I won't have time to do so. Especially since my system was taken down
> completely by the talitos tasklet under some circumstances. If there is
> any work going on in that regard I'd be fine with just dropping that patch
> (and carrying it myself until the refactoring is done).

I'm not aware of any, but to prove whether NAPI actually fixes the
issue, can you try applying this patch:

http://patchwork.ozlabs.org/patch/146094/

For it to be upstream-acceptable, I believe it would have to port
NAPI in such a way that all crypto drivers could use it.  The
difference between net NAPI and crypto NAPI would be that the crypto
version would be reduced to only using the weight code, since that's
the only source of the performance benefit.

Thanks,

Kim
