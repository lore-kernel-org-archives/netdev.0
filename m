From: Gustavo Pimentel <gustavo.pimentel@efacec.com>
Subject: RE: Bonding
Date: Tue, 11 Feb 2014 17:15:34 +0000
Message-ID: <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5B04@S103.efacec.pt>
References: <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5AA5@S103.efacec.pt>
 <20140211141549.GB29570@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.efacec.com ([213.58.230.66]:49664 "HELO mail3.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751323AbaBKRPP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:15:15 -0500
In-Reply-To: <20140211141549.GB29570@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Veaceslav,

It's quite different from broadcast mode, each frame sent through the s=
laves has attached a Redundancy Control Trailer also known as RCT (this=
 trailer is compose by a LAN identifier, sequence number, a LSDU size a=
nd a PRP suffix).
Also the equipment with PRP capability has to send periodically a super=
vision frame to both similar LANs. Each device on the network has to ke=
ep track of receive sequence numbers received, if the received a sequen=
ce number for instance from LAN A of specific device and it doesn't exi=
st on internal table, the device should accept the frame and update the=
 internal table. When receiving the same sequence number from the LAN B=
, the device should discard it, providing zero downtime redundancy.

I can supply you information about this redundancy protocol, if you lik=
e. This type of network redundancy is now being large deployed on elect=
rical power stations (like thermal and hydro) and transmission power st=
ations instead of teaming / bonding that depends on RSTP for redundancy=
=2E

> -----Original Message-----
> From: Veaceslav Falico [mailto:vfalico@redhat.com]
> Sent: ter=E7a-feira, 11 de Fevereiro de 2014 14:16
> To: Gustavo Pimentel
> Cc: netdev@vger.kernel.org
> Subject: Re: Bonding
>=20
> On Tue, Feb 11, 2014 at 01:53:32PM +0000, Gustavo Pimentel wrote:
> >Hi,
>=20
> Hi Gustavo,
>=20
> >
> >I'm writing you because because I'm have implemented a new mode (PRP=
 Parallel
> Redundancy Protocol) for bonding kernel driver. This new mode is quit=
e simple, I
> don't know if you have heard about PRP, but it's a new standard that =
allows to
> overcome any single network failure without affecting the data transm=
ission. The
> general idea resides on having two separate LAN (A & B) very similar =
and
> transmitting the almost the same frame=A0through both LANs and the en=
d device
> should accept one frame and discard the other according to a known me=
chanism.
>=20
> Isn't that the current 'broadcast' mode, where every packet is transm=
itted over all
> the slaves? After quick googling/reading I don't see any difference t=
here, though I
> might have missed something.
>=20
> >
> >I have implemented this new mode on bonding driver, but I have some
> difficulties:
> >. Writing linux driver is quite new for me. I don't' know if exists =
guide lines for
> driver coding.
>=20
> You can find everything under Documentation/, but without the code I =
can't tell you
> exact documents. CodingStyle and SubmittingPatches might be the first=
 ones.
>=20
> Also, try CC-ing relevant people for more feedback, specifically bond=
ing
> maintainers.
>=20
> >. I don't know how to submit the code to be include on kernel reposi=
tory.
> >. Maybe another pair of eyes could find help to improve the writing =
code for this
> mode.
>=20
> Try sending an RFC when net-next opens.
>=20
> >
> >I think my driver code is 99% complete. I'm currently testing with 3=
 equipments (1
> pc + 1 embedded device running both my modify bonding driver) and a t=
hird party
> equipment called RedBox.
> >
> >Would you be interested in participating / helping this project?
> >
> >With my best regards,
> >
> >Gustavo Gama da Rocha Pimentel
> >Power Systems Automation / Innovation & Development Efacec Engenhari=
a e
> >Sistemas, S.A.
> >Phone: +351229403391
> >Disclaimer
> >
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org More majordomo in=
fo
> >at  http://vger.kernel.org/majordomo-info.html
