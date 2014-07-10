From: Wolfgang Walter <linux@stwm.de>
Subject: Re: GRO: very bad routing performance with 3.14.4 for GRE-packets
Date: Thu, 10 Jul 2014 16:34:56 +0200
Message-ID: <10126633.oS5Z8BFzgN@h2o.as.studentenwerk.mhn.de>
References: <1442942.x8F4o95O8x@h2o.as.studentenwerk.mhn.de> <1404859475.3515.10.camel@edumazet-glaptop2.roam.corp.google.com> <CAPshTCgBRn6JT=b=anaoLxeAs1CfkiavuV4MRev+yeHo9VBddQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:52652 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751115AbaGJOe7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 10:34:59 -0400
In-Reply-To: <CAPshTCgBRn6JT=b=anaoLxeAs1CfkiavuV4MRev+yeHo9VBddQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 8. Juli 2014, 17:19:33 schrieb Jerry Chu:
> On Tue, Jul 8, 2014 at 3:44 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > On Tue, 2014-07-08 at 22:35 +0200, Wolfgang Walter wrote:
> >> Hello,
> >>=20
> >> I upgraded a router from 3.10.46 to 3.14.4 and I see a dramatic
> >> perfomance
> >> loss for GRE-pakets if (and only if) GRO is enabled on the incomin=
g or
> >> outgoing interface (drops to 1/50th to 1/100th).
> >>=20
> >> Other traffic is just fine.
> >>=20
> >> The router itself is not endpoint of the GRE-tunnel.
> >>=20
> >> The router has connection tracking enabled and does NAT (but most =
of the
> >> traffic is not NATed nor are GRE-packets).
> >>=20
> >> The network card is an Intel Corporation I350 Gigabit (both interf=
aces).
> >>=20
> >> Regards,
> >=20
> > GRO is a win if the consumer of the packets understands GSO packets=
=2E
> >=20
> > In this case, Intel driver is not able to send GSO packets with GRE
> > encapsulation, so they need to be segmented before being sent.
> >=20
> > That's extra work and not worth it, as you noticed.
> >=20
> > One way to get good performance would be to implement a software TS=
O in
> > the Intel driver for the GRE encapsulated packets.
> >=20
> > You might revert bf5a755f5e9186406bbf50f4087100af5bd68e40, or submi=
t a
> > patch to make the GRE handling in GRO an optional feature.
>=20
> There is also a bug to the forwarding path introduced by my GRE-GRO
> patch that I discovered a while back and submitted a fix to it. Pleas=
e
> see http://patchwork.ozlabs.org/patch/324953/ and let me know if that
> addresses the problem you've seen. Sorry I have not got the time to
> follow through with the patch.

Yes, this patch fixes the problem.

Is there any chance this will make it into 3.14, soon?

I would recommend to revert bf5a755f5e9186406bbf50f4087100af5bd68e40 in=
 3.14=20
for now and reapply it when this fix is available as this is a real=20
regression.

Thanks for your help.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
