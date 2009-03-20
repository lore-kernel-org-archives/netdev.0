From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Fri, 20 Mar 2009 22:50:50 +0100 (CET)
Message-ID: <alpine.LNX.2.00.0903202217590.4741@firda.kolla.no>
References: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no> <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no> <20090318.123308.29370828.yoshfuji@st-paulia.net> <20090319.234446.242594797.davem@davemloft.net> <alpine.LNX.2.01.0903200945160.20203@halbrend.uninett.no>
 <49C3DA3B.6080309@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>,
	David Miller <davem@davemloft.net>, yoshfuji@st-paulia.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ufisa.uninett.no ([158.38.152.126]:42170 "EHLO ufisa.uninett.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111AbZCTVuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 17:50:55 -0400
In-Reply-To: <49C3DA3B.6080309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2009, Brian Haley wrote:

> Kolbj=C3=B8rn Barmen wrote:
> > I personally really dont care what is default as long as I have a _=
very
> > easy_ way to turn it off, kernel module paramters and boot paramete=
rs -
> > great! If the rest of the world has decided they want to fight this
> > manually by default, fine by me :)
>=20
> I'll work on the module parameters Yoshifuji mentioned, the "harder"
> version since to me it seems more useful.  Since it's of interest to =
you
> can you give me some input?=20

Definetly! Thanks alot for the effort! :)

> Are the two parameters he described for this going to be good enough =
for
> you?  I was thinking of also adding a "default" keyword to control
> net.ipv6.conf.default.*, for example:
>=20
> 	disable_ipv6=3Dall,default,eth0,eth1
> 	autoconf=3Dall,default,eth2,eth3
>=20
> This is because "default" is what's inherited by all the ethX values,
> "all" is the big hammer.

This is still unclear for me. I've been assuming that by changing
"default" all future devices will inherit the value, but leaving existi=
ng
devices as is. "all" I've assumed takes all existing interfaces, but
leaving default as is. Is this what you are saying?

> And also adding an "enable_ipv6" one:
>=20
> 	enable_ipv6=3Dlo,eth4,eth5
>=20
> This would let you do:
>=20
> 	disable_ipv6=3Ddefault
> 	enable_ipv6=3Dlo,eth0
>=20
> Which saves you from listing many interfaces:
>=20
> 	disable_ipv6=3Deth1,eth2,eth3,eth4....
>=20
> Of course I could be over-thinking this and the simple solution could=
 work just
> fine:
>=20
> 	disable_ipv6=3D1
> 	autoconf=3D0
>=20
> Then just let you put things in sysctl.conf to enable what you want. =
 I'll play
> with that first to see if it's enough.

I think this would be enough yes. Probably best to think about how one
would be able to set boot paramets so that a machine gets static addres=
s
and no autoconf, for example for NFS-root etc. This falls under same
"mission"?

> I'd rather get this right the first time...

Ofcourse :)

> > How about the behaviour that I described:
> >=20
> >     root:~# sysctl net.ipv6.conf.all.accept_ra=20
> >     net.ipv6.conf.all.accept_ra =3D 1=20
> >     root:~# sysctl -w net.ipv6.conf.all.accept_ra=3D0=20
> >     net.ipv6.conf.all.accept_ra =3D 0=20
> >     root:~# sysctl net.ipv6.conf.eth0.accept_ra=20
> >     net.ipv6.conf.all.accept_ra =3D 1 =20
> >=20
> > Is this intended behaviour or not? Bug or (mis)feature?
>=20
> I *think* that's intended, at least it's one of the ways IPv6 differs=
 from IPv4
> - setting "all" doesn't reset to individual nic settings.  But the co=
de in
> ndisc_router_discovery() should probably check the "all" flag and dro=
p the RA.
> The other "all" sysctl's should behave the same, so someone needs to =
take a
> deeper look.

OK, I have this weird feeling that this "worked" some years ago, but I
dont have any old systems to try out that theory on. I fail to see wht
purpose "all" has, if it isn't setting the value of all interfaces.

Again, thank you very much for looking into this! :)

-- kolla
