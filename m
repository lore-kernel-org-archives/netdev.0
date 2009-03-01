From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 17/17] tcp: get rid of two unnecessary u16s in
 TCP skb flags copying
Date: Sat, 28 Feb 2009 19:08:45 -0800 (PST)
Message-ID: <20090228.190845.137313353.davem@davemloft.net>
References: <12358322833023-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832837-git-send-email-ilpo.jarvinen@helsinki.fi>
	<87ocwm0xx5.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755251AbZCADJE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2009 22:09:04 -0500
In-Reply-To: <87ocwm0xx5.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andi Kleen <andi@firstfloor.org>
Date: Sun, 01 Mar 2009 03:39:02 +0100

> "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> writes:
>=20
> > From: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> >
> > I guess these fields were one day 16-bit in the struct but
> > nowadays they're just using 8 bits anyway.
> >
> > This is just a precaution, didn't result any change in my
> > case but who knows what all those varying gcc versions &
> > options do. I've been told that 16-bit is not so nice with
> > some cpus.
>=20
> Typically when 16bit is not nice, 8bit isn't nice either.
> For general flags the most save in terms of uniform performance
> is "int"

It's really only the truly ancient alpha cpus where this is
a measurable issue.  Those chips only have 32-bit loads
and stores, so ever sub-32-bit access involves a 32-bit
load/store and a bunch of byte extraction instructions.

I don't think it's a relevant concern today.  Especially
on x86 if that's why you are alluding to Andi.

