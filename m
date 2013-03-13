From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Wed, 13 Mar 2013 02:01:56 -0400
Message-ID: <20130313020156.c9dd9841.billfink@mindspring.com>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
	<1362888229.4051.2.camel@edumazet-glaptop>
	<CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
	<1362891937.4051.25.camel@edumazet-glaptop>
	<20130310004904.de508bfa.billfink@mindspring.com>
	<1362894876.4051.27.camel@edumazet-glaptop>
	<513F3BE1.2080409@genband.com>
	<20130312154245.GA13101@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Friesen <chris.friesen@genband.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Vimal <j.vimal@gmail.com>, netdev@vger.kernel.org,
	shemminger <shemminger@vyatta.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:33161 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753562Ab3CMGCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 02:02:05 -0400
In-Reply-To: <20130312154245.GA13101@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Mar 2013, Thomas Graf wrote:

> On 03/12/13 at 08:29am, Chris Friesen wrote:
> > The only problem I see is that you can't set the multiplier with a
> > new tool and then query the rate with old tools.
> >=20
> > But you're going to run into that problem with the old tools no
> > matter what you do--and not doing anything is a crappy option as
> > well.
> >=20
> > Some kind of multiplier or shift makes as much sense as anything
> > else. With old tools you get current behaviour, with new tools you
> > can specify a multiplying factor to trade off resolution vs
> > precision.
>=20
> The introduction of a shift operator or multiplier introduces
> inprecision. I'd much rather see new 64bit Netlink attributes
> that, if present, replace the old rate values and statistics.
>=20
> You will need to add a new Netlink attribute anyway and we might
> as well transfer the actual rate instead of a multiplier. Just
> like we did with IFLA_STATS64.

The last time this was discussed appears to be (on 2011-03-28):

	http://marc.info/?l=3Dlinux-netdev&m=3D130128741907282&w=3D2

where Maciej =C5=BBenczykowski argued that creating a new 64-bit
Netlink attribute for this would be much more complex than for
the IFLA_STATS64 support.  There was no reply.

Providing a new multiplier/shift parameter would be a simple
way to extend support for higher rates, and would not break
existing user space that doesn't require the higher rates.
I imagine the user would not explicitly specify the multiplier/
shift parameter, but would just normally specify the desired
rate, and a newer tc would figure out what multiplier/shift
to use if a high enough rate demanded it.  To maintain user
space compatibility, the kernel should report back the same
rate and multiplier/shift it was given, and the newer tc would
convert it back to the user's originally specified rate.  Older
user space that was fine with the ~34 Gbps rate limitation would
always have the default multiplier of 1 or shift of 0 bits, and
would see the exact same unmultiplied/unshifted rate it always
did.

I also believe 32 bits of precision is significant enough
at these higher data rates.

					-Bill
