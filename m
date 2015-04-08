From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Wed, 08 Apr 2015 09:12:15 -0500
Message-ID: <1428502335.12988.1.camel@redhat.com>
References: <1427409698.18540.11.camel@redhat.com>
	 <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
	 <1427749308.1913.28.camel@redhat.com>
	 <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
	 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
	 <CAF2d9jikrJU0k3sS=awZQN+SD46qnN4r0bubjXZiY7K9vQieEQ@mail.gmail.com>
	 <1427921700.6874.8.camel@redhat.com>
	 <CAF2d9jgqJBfWVnX1mye5xMfYznA_NFte3dEEKG5CyogXTM73Rw@mail.gmail.com>
	 <1427985636.5282.9.camel@redhat.com>
	 <CAF2d9jjBtSptfmFY2BDF7ULNxAz=WtUVpNz0iExyd-h+v+4GSQ@mail.gmail.com>
	 <1428340638.16890.15.camel@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB1668E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"jbenc@redhat.com" <jbenc@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750920AbbDHOLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 10:11:36 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1668E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-08 at 09:37 +0000, David Laight wrote:
> From: Dan Williams
> ...
> > > Probably something similar where turn on the broadcast bit and wa=
it
> > > for the interface to get configured (2 min timer) and at the expi=
ry
> > > decide what is to be done about braodcast bit. If the addresses
> > > configured are all IPv6, then eliminate it and if any of them are=
 IPv4
> > > then don't change it. In this case no special casing nor snooping=
 is
> > > required and this should work for dual-stack scenario as well.
> >=20
> > This does not work for the case where, after configuring, the DHCPv=
4
> > address lease expires and the IPv4 address is removed, and then DHC=
Pv4
> > is started again.  Possibly because the DHCP server was gone for a =
short
> > time.  The only way to handle that is to snoop again.
> >=20
> > Reaching for maximum performance is great, but if that is done by
> > ignoring/breaking a whole class of normal use-cases, I don't think
> > that's reasonable.  It's like saying "gee, I'd love UDP to be faste=
r, so
> > I'll remove anything TCP-related in the kernel".
> >=20
> > Also, I don't think the snooping is as bad for performance as you m=
ay
> > think.  The only relevant issue here is L2 + IPv6-only, and in that=
 case
> > it's 4 extra compares (dhcp4_seen, ipv4cnt, lyr3h, and addr_type) f=
or
> > the external case.  How much is that really going to slow things do=
wn,
> > versus breaking a huge part of IPv4 address configuration?
>=20
> How much performance do you really gain from disabling broadcasts in =
hardware?
> (Unless your network has massive broadcast storms - which are a diffe=
rent problem).
> I can imagine it helping a low power device stay idle.

I'm not sure what metrics the decision to have a broadcast filter in
ipvlan was based on since I'm just trying to fix some bugs, but I assum=
e
Mahesh has the answer to that?

Dan

> For DHCP you have bigger issues.
> All the versions of the dhcp client I've seen use the bpf interface f=
or
> receive traffic (even once started) so you get the cost of a clone
> of every received packet.
>=20
> 	David
>=20
> NrybX=C7=A7v^)=DE=BA{.n+z^)w*=1Fjg=1E=DD=A2j/z=DE=962=DE=99&)=DF=A1a=7F=
=1EGh=0Fj:+vw=D9=A5
