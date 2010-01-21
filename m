From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: Problems with tg3 driver after lowering the MTU
Date: Thu, 21 Jan 2010 09:47:03 -0800
Message-ID: <E1829B60731D1740BB7A0626B4FAF0A6467F0DA0D5@XCH-NW-01V.nw.nos.boeing.com>
References: <ac67d9131001210721q37a6883eg85430f9564d8e007@mail.gmail.com>
 	<1264087643.2794.2.camel@achroite.uk.solarflarecom.com>
 <ac67d9131001210742x7bb6af87o546007707c412835@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Szilveszter Ordog <slipszi@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:54488 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566Ab0AUSWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 13:22:20 -0500
In-Reply-To: <ac67d9131001210742x7bb6af87o546007707c412835@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.o=
rg] On Behalf Of Szilveszter
> Ordog
> Sent: Thursday, January 21, 2010 7:42 AM
> To: netdev@vger.kernel.org
> Subject: Re: Problems with tg3 driver after lowering the MTU
>=20
> On Thu, Jan 21, 2010 at 16:27, Ben Hutchings <bhutchings@solarflare.c=
om> wrote:
> > On Thu, 2010-01-21 at 16:21 +0100, Szilveszter Ordog wrote:
> >> After the MTU is lowered (e.g. to 1420) on a tg3-driven interface,
> >> received packets larger than that (e.g. 1500 bytes) are silently
> >> discarded by the driver. Therefore the system doesn't send ICMP
> >> fragmentation-needed packets and the other side doesn't detect thi=
s
> >> condition.
> >>
> >> Is this a known bug?
> >
> > I don't believe this a bug. =A0Within a local network, MTU should b=
e set
> > the same for all interfaces. =A0Routers that connect networks with
> > different MTUs will generate the fragmentation-needed message as
> > appropriate.
>=20
> Other drivers do not behave like that. Most of them always allow
> packets smaller than 1500 bytes. That is why I think that this is a
> bug.

The question seems to be what happens when the
Maximum Transmission Unit (MTU) is smaller than
the Maximum Receive Unit (MRU)?

=46or TCP, MSS is calculated based on MTU (not MRU)
so there should not be any size mismatches with TCP.
=46or large packets of other IP protocols, it should
be OK for the end system to receive a packet larger
than it is capable of sending. So, it seems to me
that packets that are larger than MTU but no larger
than MRU should be accepted.

=46red
fred.l.templin@boeing.com

> slipszi
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
