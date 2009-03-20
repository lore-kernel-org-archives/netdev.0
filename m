From: Brian Haley <brian.haley@hp.com>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Fri, 20 Mar 2009 14:02:35 -0400
Message-ID: <49C3DA3B.6080309@hp.com>
References: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no> <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no> <20090318.123308.29370828.yoshfuji@st-paulia.net> <20090319.234446.242594797.davem@davemloft.net> <alpine.LNX.2.01.0903200945160.20203@halbrend.uninett.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yoshfuji@st-paulia.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: =?UTF-8?B?S29sYmrDuHJuIEJhcm1lbg==?= <linux@kolla.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:30036 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbZCTSCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 14:02:40 -0400
In-Reply-To: <alpine.LNX.2.01.0903200945160.20203@halbrend.uninett.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kolbj=C3=B8rn Barmen wrote:
> I personally really dont care what is default as long as I have a _ve=
ry
> easy_ way to turn it off, kernel module paramters and boot parameters=
 -
> great! If the rest of the world has decided they want to fight this
> manually by default, fine by me :)

I'll work on the module parameters Yoshifuji mentioned, the "harder" ve=
rsion
since to me it seems more useful.  Since it's of interest to you can yo=
u give me
some input?  Are the two parameters he described for this going to be g=
ood
enough for you?  I was thinking of also adding a "default" keyword to c=
ontrol
net.ipv6.conf.default.*, for example:

	disable_ipv6=3Dall,default,eth0,eth1
	autoconf=3Dall,default,eth2,eth3

This is because "default" is what's inherited by all the ethX values, "=
all" is
the big hammer.

And also adding an "enable_ipv6" one:

	enable_ipv6=3Dlo,eth4,eth5

This would let you do:

	disable_ipv6=3Ddefault
	enable_ipv6=3Dlo,eth0

Which saves you from listing many interfaces:

	disable_ipv6=3Deth1,eth2,eth3,eth4....

Of course I could be over-thinking this and the simple solution could w=
ork just
fine:

	disable_ipv6=3D1
	autoconf=3D0

Then just let you put things in sysctl.conf to enable what you want.  I=
'll play
with that first to see if it's enough.

I'd rather get this right the first time...

> How about the behaviour that I described:
>=20
>     root:~# sysctl net.ipv6.conf.all.accept_ra=20
>     net.ipv6.conf.all.accept_ra =3D 1=20
>     root:~# sysctl -w net.ipv6.conf.all.accept_ra=3D0=20
>     net.ipv6.conf.all.accept_ra =3D 0=20
>     root:~# sysctl net.ipv6.conf.eth0.accept_ra=20
>     net.ipv6.conf.all.accept_ra =3D 1 =20
>=20
> Is this intended behaviour or not? Bug or (mis)feature?

I *think* that's intended, at least it's one of the ways IPv6 differs f=
rom IPv4
- setting "all" doesn't reset to individual nic settings.  But the code=
 in
ndisc_router_discovery() should probably check the "all" flag and drop =
the RA.
The other "all" sysctl's should behave the same, so someone needs to ta=
ke a
deeper look.

-Brian
