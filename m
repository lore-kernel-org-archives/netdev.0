From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Wed, 15 Feb 2012 20:13:59 +0100
Message-ID: <1329333239.2469.3.camel@edumazet-laptop>
References: <20120215163748.GA3998@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37662 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719Ab2BOTOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 14:14:14 -0500
Received: by werb13 with SMTP id b13so842231wer.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 11:14:13 -0800 (PST)
In-Reply-To: <20120215163748.GA3998@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 11:37 -0500, Nick Bowler a =C3=A9=
crit :
> Hi folks,
>=20
> We were testing IPsec with large mtu sizes (9000 bytes) and noticed t=
he
> occasional failure with large datagrams (requiring several fragments,
> >=3D25k bytes or so).  Investigating further, I was able to reproduce=
 the
> issue without using IPsec at all.  Looking at the wireshark capture I
> see that one of the fragments transmitted is totally bogus: portions =
of
> the payload data have made it onto the wire as the headers.  My test
> case was this:
>=20
>   ping -c 1 -s 30000 -p 42 birch
>=20
> which is split into 4 frames, 3 of which (first, second and last) loo=
k
> correct but the fourth consists entirely of 0x42 octets, including th=
e
> ethernet and IP headers (so the source address is 42:42:42:42:42:42, =
the
> destination address is 42:42:42:42:42:42, ethertype is 0x4242, etc.)
> I've attached the wireshark capture (gzipped) since it's small enough=
=2E
> Nevertheless, the total length is correct for the missing fragment.
>=20
> It seems to be specific to the particular network chipset on this
> machine (using the r8169 driver):
>=20
>   Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B =
PCI Express Gigabit Ethernet controller (rev 03)
>=20
> because the other machine (which has a Marvell controller) transmits
> fine as far as I can tell.  I'll see about putting a discrete network
> card in this computer to see if that helps any.
>=20
> It's not entirely consistent in how things fail.  Sufficiently small
> pings (say, <=3D20k bytes) seem to work 100% of the time, sufficientl=
y
> large pings (say, >=3D 40k bytes) seem to fail 100% of the time, and =
in
> between most pings fail but the occasional one makes it through.
> Everything works at all sizes with 1500 byte MTU.
>=20
> There are no unusual messages in dmesg and this was all run with late=
st
> Linus' git as of this morning.  It occurred with somewhat older kerne=
ls
> (2.6.39) as well, even though the driver only let me go to 7200 byte =
mtu
> on that version.
>=20
> Let me know if you need any more info,

Interesting, but 2nd frame is also corrupted (not at the start but in
the middle)

Where was taken this trace exactly ?
