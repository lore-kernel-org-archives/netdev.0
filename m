From: dormando <dormando@rydia.net>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Mon, 4 Mar 2013 21:44:34 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>  <51356AC1.4090302@gmail.com> <1362460046.15793.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362460046.15793.111.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 4 Mar 2013, Eric Dumazet wrote:

> On Tue, 2013-03-05 at 11:47 +0800, Cong Wang wrote:
> > (Cc'ing the right netdev mailing list...)
> >
> > On 03/05/2013 08:01 AM, dormando wrote:
> > > Hi!
> > >
> > > I have a (core lockup?) with 3.7.6+ and 3.8.2 which appears to be under
> > > ixgbe. The machine appears to still be up but network stays in a severely
> > > hobbled state. Either lagging or not responding to the network at all.
> > >
> > > On a new box the hang happens within 8-24 hours of giving it production
> > > network traffic. On an older machine (6 cores instead of 8, etc) it can
> > > run for a week or more before hanging.
> > >
> > > The hang from 3.7 might be slightly different than 3.8. They seem to be
> > > mostly the same aside from 3.8 hanging in the GRO path. Don't see anything
> > > obvious in 3.9-rc1 that would fix it, and haven't tried 3.9-rc1.
> > >
> > > I've not yet figured out how to reproduce outside of production (as
> > > always, sigh). This doesn't seem to happen with 3.6.6, but we have
> > > different and less frequent kernel panics there.
> > >
>
> Dornando, do you use any kind of special setup, external modules,
> or netfilter ? (iptables-save output would help)
>
> Is it a pristine kernel, or a modified one ?
>

(Sigh. sorry for the misfire, thanks for fixing cc).

No 3rd party modules. There's a tiny patch for controlling initcwnd from
userspace and another one for the extra_free_kbytes tunable that I brought
up in another thread. We've had the initcwnd patch in for a long time
without trouble. The extra_free_kbytes tunable isn't even being used yet,
so all that's doing is adding a 0 somewhere.

Only two iptables rules loaded: global NOTRACK rules for PREROUTING/OUTPUT
in raw.

Kernel's as close to pristine as I can make it. We had the 10g patch in
but I've dropped it.
