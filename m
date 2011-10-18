From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Tue, 18 Oct 2011 15:00:01 +0100
Message-ID: <1318946401.23980.6.camel@deadeye>
References: <4E9D5E1B.3080704@gmail.com>
	 <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Turull <daniel.turull@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Voravit Tanyingyong <voravit@kth.se>,
	Jens Laas <jens.laas@uadm.uu.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59236 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757964Ab1JROAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 10:00:16 -0400
In-Reply-To: <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-18 at 13:56 +0200, Eric Dumazet wrote:
> Le mardi 18 octobre 2011 =C3=A0 13:08 +0200, Daniel Turull a =C3=A9cr=
it :
> > The value selected to delay the transmission in pktgen with the nde=
lay function should be lower.
> > In Linux/arch/x86/include/asm/delay.h and Linux/arch/sh/include/asm=
/delay.h
> > the maximal expected value for a constant is 20000 ns.
> >=20
> > Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
> > ---
> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> > index 796044a..e17bd41 100644
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -2145,7 +2145,7 @@ static void spin(struct pktgen_dev *pkt_dev, =
ktime_t spin_until)
> >  	}
> > =20
> >  	start_time =3D ktime_now();
> > -	if (remaining < 100000)
> > +	if (remaining < 20000)
> >  		ndelay(remaining);	/* really small just spin */
> >  	else {
> >  		/* see do_nanosleep */
>=20
> But 'remaining' is not a constant.
>=20
> If we want exactly 40.000 packets per second rate (25 us between
> packets), your patch makes this not quite possible without
> CONFIG_HIGH_RES_TIMERS and probable high jitter because of scheduler
> effects.
>=20
> pktgen is kind of special, we _want_ a cpu for our exclusive use.

AIUI, the reason for limits on delays is not that it's bad practice to
spin for so long, but that the delay calculations may overflow or
otherwise become inaccurate.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
