From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Fri, 20 Mar 2009 09:48:30 +0100 (CET)
Message-ID: <alpine.LNX.2.01.0903200945160.20203@halbrend.uninett.no>
References: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no> <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no> <20090318.123308.29370828.yoshfuji@st-paulia.net> <20090319.234446.242594797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@st-paulia.net, linux@kolla.no, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ufisa.uninett.no ([158.38.152.126]:39544 "EHLO ufisa.uninett.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757505AbZCTIrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 04:47:23 -0400
In-Reply-To: <20090319.234446.242594797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Mar 2009, David Miller wrote:

> From: YOSHIFUJI Hideaki <yoshfuji@st-paulia.net>
> Date: Wed, 18 Mar 2009 12:33:08 +0900 (JST)
>=20
> > In article <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no> (at
> > Wed, 18 Mar 2009 02:06:09 +0100 (CET)), Kolbj=C3=B8rn Barmen
> > <linux@kolla.no> says:
> >=20
> > > > My personal oppinion is that anything ipv6 autoconfig/accept_ra
> > > > should be default _off_, since this simplifies all the above
> > > > mentioned issues, and it is incredibly easy to turn on again wi=
th
> > > > systcl if people want it.  It is much easier to enable ipv6
> > > > automagic than to disable it.  At least there should be
> > > > kernel/module parameter to set default behaviour.
> > > >=20
> > > > Part of the problem with deploying IPv6 is due to "magic" like
> > > > this, all the autoconfig/router announcement magic looks very w=
ell
> > > > on paper and in theory, but out in the field it quickly leads t=
o
> > > > loads of totally unnecessary extra work, work that could easily=
 be
> > > > avoided if default behaviour was to have it off. It should be i=
n
> > > > the interest of IPv6 advocates to support a "soft" transition f=
rom
> > > > IPv4-only to dual-stack, fencing off unwanted "magic" only adds=
 to
> > > > the frustration for those who actually try to deploy it.
> > > >=20
> > > > What do you think?
> > >=20
> > > Obviously noone really think much of this, one way or the other, =
so here's a
> > > patch that changes the default values.
> >=20
> > Default should be ON.
>=20
> I absolutely agree.
>=20
> It can't be called autoconfiguration if it's off by default, and
> you have to "configure" something.
>=20
> What are people smoking? :-)

Reality?

Anyways, I'm overthrilled to actually see response, since this has been
pestering me (well, us), for years - configuring server with static
addresses is a real _pain_ if machine is located on a network where
autoconfigure and router announcements exist (or suddenly show up by
error due to someone untentionally configuring their machine as router,
some systems are even so clever that if they dont see router
announcements, they will assume all sorts of things and start acting as
6to4 router themselves - YAY! NOT!  People creating unintended network
loops on the switch panel is another classic, leaving all machiens with
double up of adresses and faulty default routes long after physical err=
or
has been fixed - woohoo! Sheesh, I could go on all day long about what =
a
bad idea autoconf/accept_ra really is... :P )

I personally really dont care what is default as long as I have a _very
easy_ way to turn it off, kernel module paramters and boot parameters -
great! If the rest of the world has decided they want to fight this
manually by default, fine by me :)

How about the behaviour that I described:

    root:~# sysctl net.ipv6.conf.all.accept_ra=20
    net.ipv6.conf.all.accept_ra =3D 1=20
    root:~# sysctl -w net.ipv6.conf.all.accept_ra=3D0=20
    net.ipv6.conf.all.accept_ra =3D 0=20
    root:~# sysctl net.ipv6.conf.eth0.accept_ra=20
    net.ipv6.conf.all.accept_ra =3D 1 =20

Is this intended behaviour or not? Bug or (mis)feature?

A few days ago I recieved mail from someone who was annoyed that even a=
s
he changed the values with sysctl and restarted the interface, the old
addresses, routes etc were still up - yes, the lack of proper IPv6 supp=
ort
in distros "network interface up/down" scripts is really tedious, and
there really is no easy way to "reset" ipv6 status on a machine, except
from doing it manually. I dont see any distro care much for IPv6 anytim=
e
soon, so anything that can be done to ease IPv6 configuration is _very
much appreciated_ for those of us who actually run IPv6 in full
production.

Cheers!

--=20
Kolbj=C3=B8rn Barmen
