From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 16:03:36 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
References: <1101499285.1079.45.camel@jzny.localdomain>
 <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain>
 <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain>
 <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
 <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org>
 <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041205145051.GA647@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Lennert Buytenhek wrote:

> Enabling 'DMA packet prefetching' gives me an impressive boost in performance.
> Combined with your TX clean rework, I now get 1.03Mpps TX performance at 60B
> packets.  Transmitting from both of the 82546 ports at the same time gives me
> close to 2 Mpps.
>
> The freebsd post hints that (some) e1000 hardware might be buggy w.r.t. this
> prefetching though.
>
> I'll play some more with the other ideas you suggested as well.
>
> 60      1036488

I was just playing with prefetching when you sent your mail :)

I get that number with Scotts patch but without prefetching.
If I mode the TDT update to the tc cleaning I get a few extra kpps but not
much.

BUT if I use the above + prefetching I get this:

60      1483890
64      1418568
68      1356992
72      1300523
76      1248568
80      1142989
84      1140909
88      1114951
92      1076546
96      960732
100     949801
104     972876
108     945314
112     918380
116     891393
120     865923
124     843288
128     696465

Which is pretty nice :)

This is on one port of a 82546GB

The hardware is a dual Athlon MP 2000+ in an Asus A7M266-D motherboard and
the nic is located in a 64/66 slot.

I won't post any patch until I've tested some more and cleaned up a few
things.

BTW, I also get some transmit timouts with Scotts patch sometimes, not
often but it does happen.

/Martin
