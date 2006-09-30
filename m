From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 0/3] myri10ge Large Receive Offload
Date: Sat, 30 Sep 2006 13:38:00 +0400
Message-ID: <20060930093800.GA19549@2ka.mipt.ru>
References: <451B0541.1030208@myri.com> <451B4F44.60204@garzik.org> <451D9B4C.3020008@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:5791 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751201AbWI3Jie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 05:38:34 -0400
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <451D9B4C.3020008@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 30, 2006 at 12:16:44AM +0200, Brice Goglin (brice@myri.com)=
 wrote:
> Jeff Garzik a =C3=A9crit :
> > Brice Goglin wrote:
> >> This is a complete rework of the myri10ge receive path. The first
> >> patch converts skb allocation to use physical pages. The second on=
e
> >> adds a software implementation of Large Receive Offload. The third
> >> one updates the driver version to 1.1.0.
> >>
> >> The complete driver code in our CVS actually also supports high-or=
der
> >> allocations instead of single physical pages since it significantl=
y
> >> increase the performance. Order=3D2 allows us to receive standard =
frames
> >> at line rate even on low-end hardware such as an AMD Athlon(tm) 64=
 X2
> >> Dual Core Processor 3800+ (2.0GHz). Some customer might not care a=
 lot
> >> about memory fragmentation if the performance is better.
> >>
> >> But, since high-order allocations are generally considered a bad i=
dea,
> >> we do not include the relevant code in the following patch for inc=
lusion
> >> in Linux. Here, we simply pass order=3D0 to all page allocation ro=
utines.
> >> If necessary, I could drop the remaining reference to high-order
> >> (especially replace alloc_pages() with alloc_page()) but I'd rathe=
r
> >> keep it as is.
> >>
> >> If high-order allocations are ever considered OK under some circum=
-
> >> stances, we could send an additional patch (a module parameter wou=
ld
> >> be used to switch from single physical pages to high-order pages).
> >
> > As Herbert's already done, I would rather let the net core people
> > comment on this.  The code implementation doesn't look scary, but w=
e
> > may want to be smarter about this in the core net stack, rather tha=
n
> > implementing it inside multiple drivers.
>=20
> Ok, makes sense. We look forward to see this.
>=20
> Could we get patch #1 merged anyway (page-based skb allocation)?
>=20
> Any comments about what I was saying about high-order allocations abo=
ve?

It is quite strnage that you see very noticeble speed degradation after
switching from higher order to 0 order allocations, could specify where=
=20
observed  bottleneck in network stack is?

> thanks,
> Brice

--=20
	Evgeniy Polyakov
