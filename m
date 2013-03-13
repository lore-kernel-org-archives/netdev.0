From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Wed, 13 Mar 2013 11:29:50 -0400
Message-ID: <20130313112950.f3a4a332.billfink@mindspring.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
	<1362888229.4051.2.camel@edumazet-glaptop>
	<CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
	<1362891937.4051.25.camel@edumazet-glaptop>
	<20130310004904.de508bfa.billfink@mindspring.com>
	<1362894876.4051.27.camel@edumazet-glaptop>
	<513F3BE1.2080409@genband.com>
	<20130312154245.GA13101@casper.infradead.org>
	<20130313020156.c9dd9841.billfink@mindspring.com>
	<1363155195.13690.48.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>,
	Chris Friesen <chris.friesen@genband.com>,
	Vimal <j.vimal@gmail.com>, netdev@vger.kernel.org,
	shemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:39025 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932391Ab3CMPa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:30:28 -0400
In-Reply-To: <1363155195.13690.48.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Mar 2013, Eric Dumazet wrote:

> On Wed, 2013-03-13 at 02:01 -0400, Bill Fink wrote:
>=20
> > The last time this was discussed appears to be (on 2011-03-28):
> >=20
> > 	http://marc.info/?l=3Dlinux-netdev&m=3D130128741907282&w=3D2
> >=20
> > where Maciej =C5=BBenczykowski argued that creating a new 64-bit
> > Netlink attribute for this would be much more complex than for
> > the IFLA_STATS64 support.  There was no reply.
> >=20
> > Providing a new multiplier/shift parameter would be a simple
> > way to extend support for higher rates, and would not break
> > existing user space that doesn't require the higher rates.
> > I imagine the user would not explicitly specify the multiplier/
> > shift parameter, but would just normally specify the desired
> > rate, and a newer tc would figure out what multiplier/shift
> > to use if a high enough rate demanded it.  To maintain user
> > space compatibility, the kernel should report back the same
> > rate and multiplier/shift it was given, and the newer tc would
> > convert it back to the user's originally specified rate.  Older
> > user space that was fine with the ~34 Gbps rate limitation would
> > always have the default multiplier of 1 or shift of 0 bits, and
> > would see the exact same unmultiplied/unshifted rate it always
> > did.
>=20
> We already said no to such a hack. Maybe its not clear enough ?
>=20
> netlink allows us to a proper way, and Thomas Graf explained how we
> expect the thing to be done.
>=20
> Yes, this is not a one liner patch, its a bit more of work, and its h=
ow
> it will be done when someone does the job.

I've no problem with that since it is a cleaner solution, but
one that requires significantly more work.  I was only arguing
that the multiplier/shift approach was also a workable solution
and should be simpler to implement.  But since there appears to
be developer consensus that it's not a desired method, I'm fine
with going along with that expert opinion.

						-Bill
