From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 21:04:16 +0000
Message-ID: <1289423056.2249.7.camel@achroite.uk.solarflarecom.com>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2951 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab0KJVEU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 16:04:20 -0500
In-Reply-To: <1289421187.2469.127.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-10 at 21:33 +0100, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 10:40 -0800, Ben Greear a =C3=A9c=
rit :
>=20
> > In my opinion, the kernel and/or driver should deal with this such =
that
> > at worst the user has to deal with 32 v/s 64 bits based on whether =
the
> > kernel is compiled for 32 or 64 bit CPUs.  (Let the driver sample a=
t
> > intervals needed to never wrap it's counters more than once and upd=
ate
> > software stats of well-defined bit-width, and present those softwar=
e
> > counters to users.
> >=20
>=20
> How so ? Are you willing to provide patches for all network drivers ?
>=20
> > In practice, this seems to be the case, at least for the NICs I've =
used
> > (mostly Intel).  But, please don't propagate the idea that any widt=
h of
> > counters is OK to present to user-space:  It is completely unfair t=
o
> > make app writers have to know the network driver and/or hardware qu=
irks to
> > know how often it must sample stats.
> >=20
>=20
> I am sorry Ben, but /proc/net/dev doesnt publish each counter effecti=
ve
> width. Its unfair, but its like that.
>=20
> An appplication must be able to cope for wrap arounds, running on a 3=
2
> or 64bit kernel. Our duty is to provide 64bit counters for high speed
> interfaces where possible.
> For a 10Mb adapter, there is no need, since a 32bit counter doesnt wr=
ap
> in less than one hour (RFC1902 suggestion)
>=20
> As I said, many drivers counters are not 32bit or 64bit. I did many
> driver get_stats() checks lately...
>=20
> Why should we cap them to 32bit if they really are 36 or 40 bits ?=20
[...]

Drivers should calculate differences and accumulate them in a 64-bit
counter.  (A lot of hardware has read-to-clear counters anyway, in whic=
h
case the driver *has* to accumulate the values it reads.)

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

