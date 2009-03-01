From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next 17/17] tcp: get rid of two unnecessary u16s in TCP skb flags copying
Date: Sun, 1 Mar 2009 22:44:41 +0100
Message-ID: <20090301214441.GJ26292@one.firstfloor.org>
References: <12358322833023-git-send-email-ilpo.jarvinen@helsinki.fi> <12358322832837-git-send-email-ilpo.jarvinen@helsinki.fi> <87ocwm0xx5.fsf@basil.nowhere.org> <20090228.190845.137313353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59330 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754956AbZCAV0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 16:26:12 -0500
Content-Disposition: inline
In-Reply-To: <20090228.190845.137313353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 28, 2009 at 07:08:45PM -0800, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Sun, 01 Mar 2009 03:39:02 +0100
>=20
> > "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> writes:
> >=20
> > > From: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> > >
> > > I guess these fields were one day 16-bit in the struct but
> > > nowadays they're just using 8 bits anyway.
> > >
> > > This is just a precaution, didn't result any change in my
> > > case but who knows what all those varying gcc versions &
> > > options do. I've been told that 16-bit is not so nice with
> > > some cpus.
> >=20
> > Typically when 16bit is not nice, 8bit isn't nice either.
> > For general flags the most save in terms of uniform performance
> > is "int"
>=20
> It's really only the truly ancient alpha cpus where this is
> a measurable issue.  Those chips only have 32-bit loads
> and stores, so ever sub-32-bit access involves a 32-bit
> load/store and a bunch of byte extraction instructions.

Yes old Alpha is the only one I know, although I don't claim to know ev=
ery=20
weirdness of every embedded CPU out there.

My point was merely that 16bit is not in any way better than 8 bit.
>=20
> I don't think it's a relevant concern today.  Especially
> on x86 if that's why you are alluding to Andi.

x86 normally[1] doesn't care, but it also doesn't save anything normall=
y
for a on stack (or in register) variable because there's typically
padding anyways.

[1] there are some issues on older Intel CPUs with partial register
stall in a few cases.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
