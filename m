From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Mon, 16 Oct 2006 00:15:18 +0200
Message-ID: <200610160015.19041.dpc@asn.pl>
References: <200610151820.22867.dpc@asn.pl> <Pine.LNX.4.64.0610151729210.14523@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:4538 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S932139AbWJOWPb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 18:15:31 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0610151729210.14523@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday, 15 October 2006 23:35, you wrote:
> > Hi,
> > =A0I'd be thankful for your opinions about that idea. Please forgiv=
e me any
> > nuances that I didn't know about.
>=20
> This limits the system to only talking to one other system on the sam=
e=20
> link. =A0I guess you could have per-MAC keys and associate the crypto=
 info=20
> with neighbor cache entries.

The idea is to use vlan and macvlan devices to separate encrypted traff=
ic -=20
as you can just encrypt vlan device. Other than that - yes ccrypt was=20
considered as solution for point-to-point links.

> Likely need a cryptographer to review the protocol -- blindly using t=
he=20
> first block of every encrypted packet as the IV smells problematic, f=
or=20
> example.

Cryptographic part needs attention. I'm not a cryptographer and no=20
cryptographer have checked the idea or code.

And yes - this is little problematic, but I think the solution is good=20
enough - there is little chance to inject valid upper level packet, and=
 even=20
if such event occur - there is no chance that can carry valid hostile=20
information.

The magic function is is_decoded_buffer_valid, which - using upper leve=
l=20
info - will just drop packets that weren't encrypted correctly. There a=
re=20
little chances that spoofed frame after decryption will look like good=20
packet - for IPv4 I estimate them to be much less than 1 to 256 * 256 *=
 32=20
(2097152) and this can be rather easily improved.

Injected packets that will not pass such validation will not change sto=
red IV,=20
so transmition will not be affected. And even when such frame will pass=
 - it=20
will probable consist of garbages - the only effect will be using bad I=
V in=20
the next encryption - so next good frame will be dropped.

If ccrypt will be considered reasonable I was thinking about kernel war=
nings=20
on spoofing tries detection, using simple bad frames counters.
