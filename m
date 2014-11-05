From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: net: fec: fix regression on i.MX28 introduced by rx_copybreak
 support
Date: Wed, 5 Nov 2014 06:21:48 +0100
Message-ID: <20141105062148.2a997b95@ipc1.ka-ro>
References: <20141030.121710.1524000348187962764.davem@davemloft.net>
	<20141031063210.69004315@ipc1.ka-ro>
	<20141104112912.2be8bf1a@ipc1.ka-ro>
	<20141104.112858.356827532569349127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fabio.estevam@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rmk+kernel@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:51229 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaKEFWD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 00:22:03 -0500
In-Reply-To: <20141104.112858.356827532569349127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller wrote:
> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> Date: Tue, 4 Nov 2014 11:29:12 +0100
>=20
> > Hi David,
> >=20
> > Lothar Wa=C3=9Fmann wrote:
> >> David Miller wrote:
> >> > From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> >> > Date: Thu, 30 Oct 2014 07:51:04 +0100
> >> >=20
> >> > >> Also, I don't thnk your DIV_ROUND_UP() eliminate for the loop
> >> > >> in swap_buffer() is valid.  The whole point is that the curre=
nt
> >> > >> code handles buffers which have a length which is not a multi=
ple
> >> > >> of 4 properly, after your change it will no longer do so.
> >> > >>
> >> > > Do you really think so?
> >> >=20
> >> > Yes, because you're rounding down so you'll miss the final
> >> > partial word (if any).
> >> >
> >> Nope. DIV_ROUND_UP() would give '1' as upper bound for lengths fro=
m 1 to
> >> 4, '2' for lengths from 5 to 8 and so on.
> >>=20
> >> The loop with increment 4 and i < len does exactly the same.
> >> Try it for yourself, if you don't believe it.
> >>=20
> >>=20
> > Do you still think, the loop without DIV_ROUND_UP() is incorrect,
> > or can this patch be applied?
>=20
> I haven't had the time to fully re-look into the details, I'm busy
> with many other things at the moment.
>=20
> But looking at DIV_ROUND_UP() macro it rounds up.  It gives an
> upper bound of 4 for any value 1 to 4.  Unlike what you claim.
>=20
You're missing the 'DIV' part of DIV_ROUND_UP().

> Because it goes "(n + (d - 1)) / d"
>=20
> Which for 'd' of 4 gives:
>=20
> 1 --> 4
> 2 --> 4
> 3 --> 4
> 4 --> 4
>
'1', not '4'.
The loop has to be done once for each (probably partial) WORD of input
data, not for each BYTE.

Without dividing and incrementing by four the loop
counter will be 0 for the first word which is less than any length > 0.
Thus the loop will be run once for any number of bytes from 1 thru 4.
If incremented by 4 after the first loop, it will be run again for any
length > 5 and so forth.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
