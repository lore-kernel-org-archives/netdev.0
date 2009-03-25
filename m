From: Brian Haley <brian.haley@hp.com>
Subject: Re: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Tue, 24 Mar 2009 21:49:31 -0400
Message-ID: <49C98DAB.5070100@hp.com>
References: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no> <alpine.LNX.2.00.0903180200590.10453@firda.kolla.no> <20090318.123308.29370828.yoshfuji@st-paulia.net> <20090319.234446.242594797.davem@davemloft.net> <alpine.LNX.2.01.0903200945160.20203@halbrend.uninett.no> <49C3DA3B.6080309@hp.com> <alpine.LNX.2.00.0903202217590.4741@firda.kolla.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yoshfuji@st-paulia.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: =?UTF-8?B?S29sYmrDuHJuIEJhcm1lbg==?= <linux@kolla.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:28548 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbZCYBuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 21:50:15 -0400
In-Reply-To: <alpine.LNX.2.00.0903202217590.4741@firda.kolla.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kolbj=C3=B8rn Barmen wrote:
>> Are the two parameters he described for this going to be good enough=
 for
>> you?  I was thinking of also adding a "default" keyword to control
>> net.ipv6.conf.default.*, for example:
>>
>> 	disable_ipv6=3Dall,default,eth0,eth1
>> 	autoconf=3Dall,default,eth2,eth3
>>
>> This is because "default" is what's inherited by all the ethX values=
,
>> "all" is the big hammer.
>=20
> This is still unclear for me. I've been assuming that by changing
> "default" all future devices will inherit the value, but leaving exis=
ting
> devices as is. "all" I've assumed takes all existing interfaces, but
> leaving default as is. Is this what you are saying?

"default" is what's inherited by future devices, "all" is supposed to b=
e the
over-ride for all devices, but doesn't change any device-specific value=
s.

>> Of course I could be over-thinking this and the simple solution coul=
d work just
>> fine:
>>
>> 	disable_ipv6=3D1
>> 	autoconf=3D0
>>
>> Then just let you put things in sysctl.conf to enable what you want.=
  I'll play
>> with that first to see if it's enough.
>=20
> I think this would be enough yes. Probably best to think about how on=
e
> would be able to set boot paramets so that a machine gets static addr=
ess
> and no autoconf, for example for NFS-root etc. This falls under same
> "mission"?

My patch wouldn't address getting a static address via a module paramet=
er, that
can still be done in, for example, /etc/network/interfaces.  So no, thi=
s isn't
part of my "mission", just getting the basic functionality in place.

>>> How about the behaviour that I described:
>>>
>>>     root:~# sysctl net.ipv6.conf.all.accept_ra=20
>>>     net.ipv6.conf.all.accept_ra =3D 1=20
>>>     root:~# sysctl -w net.ipv6.conf.all.accept_ra=3D0=20
>>>     net.ipv6.conf.all.accept_ra =3D 0=20
>>>     root:~# sysctl net.ipv6.conf.eth0.accept_ra=20
>>>     net.ipv6.conf.all.accept_ra =3D 1 =20
>>>
>>> Is this intended behaviour or not? Bug or (mis)feature?
>> I *think* that's intended, at least it's one of the ways IPv6 differ=
s from IPv4
>> - setting "all" doesn't reset to individual nic settings.  But the c=
ode in
>> ndisc_router_discovery() should probably check the "all" flag and dr=
op the RA.
>> The other "all" sysctl's should behave the same, so someone needs to=
 take a
>> deeper look.
>=20
> OK, I have this weird feeling that this "worked" some years ago, but =
I
> dont have any old systems to try out that theory on. I fail to see wh=
t
> purpose "all" has, if it isn't setting the value of all interfaces.

I fixed the autoconf one, but this would still need to be addressed in =
a future
patch, trying to sneak-in before the deadline.  Might be too late...

I sent the actual patch to netdev a few minutes ago for review.

-Brian
