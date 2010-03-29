From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: UDP path MTU discovery
Date: Mon, 29 Mar 2010 16:38:49 -0700
Message-ID: <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com>
References: <1269561751.2891.8.camel@ilion>
 	<877how25kx.fsf@basil.nowhere.org>	<4BB0DCF6.9020401@hp.com>
 	<20100329201431.GH20695@one.firstfloor.org>
 	<20100329205035.GA32656@laped.iglesias.mooo.com>  <4BB11510.9000302@hp.com>
 <1269898152.1958.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:41588 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab0C3AGa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 20:06:30 -0400
In-Reply-To: <1269898152.1958.86.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of Eric Dumazet
> Sent: Monday, March 29, 2010 2:29 PM
> To: Rick Jones
> Cc: Edgar E. Iglesias; Andi Kleen; Glen Turner; netdev@vger.kernel.or=
g
> Subject: Re: UDP path MTU discovery
>=20
> Le lundi 29 mars 2010 =E0 14:01 -0700, Rick Jones a =E9crit :
>=20
> > I would get the alphabet soup completely garbled, but the DNS folks=
 are talking
> > about EDNS (?) message sizes upwards of 4096 bytes - encryption/aut=
hentication
> > and other angels being asked to dance on the head of the DNS pin ar=
e asking for
> > more and more space in the messages.
> >
> > So, someone will have to blink somewhere - either DNS will have to =
go TCP and
> > *possibly* take RTT hits there depending on various patch streams, =
or the IEEE
> > will have to sanction jumbo frames and people deploy them widely, o=
r it will
> > have to become feasible to actually do the occasional IPv6 datagram
> > fragmentation and get a timely retransmission out of a UDP applicat=
ion on a PMTU
> > hit.
> >
>=20
> 1) 4096 bytes UDP messages... well...
> 2) Using regular TCP for DNS servers... well...
>=20
> I believe some guys were pushing TCPCT (Cookie Transactions) for this
> case ( http://tools.ietf.org/html/draft-simpson-tcpct-00.html )
>=20
> (That is, using an enhanced TCP for long DNS queries... but not only =
for
> DNS...)

IPv4 gets by this by setting DF=3D0 in the IP header, and
lets the network fragment the packet if necessary. IPv6 can
similarly get by this by having the sending host fragment
the large UDP packet into IPv6 fragments no longer than
1280 bytes each.

But wait! IPv4 hosts are only required to reassemble 576 bytes
at a minimum, and IPv6 hosts are only required to reassemble
1500 bytes at a minimum. Indeed, RFC2460 says:

   "An upper-layer protocol or application that depends on IPv6
   fragmentation to send packets larger than the MTU of a path should
   not send packets larger than 1500 octets unless it has assurance tha=
t
   the destination is capable of reassembling packets of that larger
   size."

but it is not clear how the sender can get such "assurance".
In the end, perhaps IPv6 should just do what IPv4 does;
turn off PMTUD and hope for the best?

=46red
fred.l.templin@boeing.com=20
=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
