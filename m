From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Wed, 13 Mar 2013 07:13:15 +0100
Message-ID: <1363155195.13690.48.camel@edumazet-glaptop>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
	 <1362888229.4051.2.camel@edumazet-glaptop>
	 <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
	 <1362891937.4051.25.camel@edumazet-glaptop>
	 <20130310004904.de508bfa.billfink@mindspring.com>
	 <1362894876.4051.27.camel@edumazet-glaptop> <513F3BE1.2080409@genband.com>
	 <20130312154245.GA13101@casper.infradead.org>
	 <20130313020156.c9dd9841.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>,
	Chris Friesen <chris.friesen@genband.com>,
	Vimal <j.vimal@gmail.com>, netdev@vger.kernel.org,
	shemminger <shemminger@vyatta.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:60387 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab3CMGNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 02:13:19 -0400
Received: by mail-ea0-f180.google.com with SMTP id j14so213488eak.39
        for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 23:13:18 -0700 (PDT)
In-Reply-To: <20130313020156.c9dd9841.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-13 at 02:01 -0400, Bill Fink wrote:

> The last time this was discussed appears to be (on 2011-03-28):
>=20
> 	http://marc.info/?l=3Dlinux-netdev&m=3D130128741907282&w=3D2
>=20
> where Maciej =C5=BBenczykowski argued that creating a new 64-bit
> Netlink attribute for this would be much more complex than for
> the IFLA_STATS64 support.  There was no reply.
>=20
> Providing a new multiplier/shift parameter would be a simple
> way to extend support for higher rates, and would not break
> existing user space that doesn't require the higher rates.
> I imagine the user would not explicitly specify the multiplier/
> shift parameter, but would just normally specify the desired
> rate, and a newer tc would figure out what multiplier/shift
> to use if a high enough rate demanded it.  To maintain user
> space compatibility, the kernel should report back the same
> rate and multiplier/shift it was given, and the newer tc would
> convert it back to the user's originally specified rate.  Older
> user space that was fine with the ~34 Gbps rate limitation would
> always have the default multiplier of 1 or shift of 0 bits, and
> would see the exact same unmultiplied/unshifted rate it always
> did.


We already said no to such a hack. Maybe its not clear enough ?

netlink allows us to a proper way, and Thomas Graf explained how we
expect the thing to be done.

Yes, this is not a one liner patch, its a bit more of work, and its how
it will be done when someone does the job.


> I also believe 32 bits of precision is significant enough
> at these higher data rates.
>=20

This has nothing to do with the issue. Thats an implementation detail i=
n
the kernel. And frankly with 64bit arches we better use 64bit native
fields, instead of adding arbitrary limits.

We are speaking of the netlink message itself and old binaries.
