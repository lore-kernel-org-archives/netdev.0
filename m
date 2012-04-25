From: Tore Anderson <tore@fud.no>
Subject: Re: [PATCH net-next] ipv6: =?UTF-8?Q?RTAX=5FFEATURE=5FALLFRAG=20c?=  =?UTF-8?Q?auses=20inefficient=20TCP=20segment=20sizing?=
Date: Wed, 25 Apr 2012 12:04:54 +0200
Message-ID: <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
References: <1335289058.5205.165.camel@edumazet-glaptop>
 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
 <1335298228.5205.168.camel@edumazet-glaptop>
 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
 <1335331960.5205.180.camel@edumazet-glaptop>
 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
 <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:55769 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757090Ab2DYKE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 06:04:58 -0400
In-Reply-To: <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Maciej =C5=BBenczykowski

>> That is a different issue entirely, but I don't disagree with you. A
>> "min_pmtu" sysctl or something like that would be useful.
>
> I don't really know what the default value should be?  Something=20
> around 500?
> [to handle IPv4s min mtu of 576?]

The sensible default would be either 1280 (and keep allfrag feature),=20
or
the minimum IPv4 PMTU currently enforced by the kernel + 20 bytes (to
compensate for the larger IPv6 header size). I don't know what the=20
current
minimum PMTU is.

Also, I'm not really sure if the IPv4 minimum PMTU is defined as 576 or
68 bytes. There are some conflicting information out there, and nothing=
=20
really
authoritative either way (that I've found at least).

> Do we have any idea what values of small mtu actually show up in=20
> practice?

I have no data on this, I'm afraid. But I believe small MTUs (<1260,=20
which
currently triggers the need for allfrag), are very rare - at least=20
where I'm
from. Anectdotal, but - we've been running our corporate web site=20
IPv6-only
with IPv4 access through stateless translation on a Linux server with=20
the
buggy allfrag feature for several months, and there has been no=20
complaints.

>> However, the use case for the allfrag feature is not handling=20
>> tunnels,
>> but IPv4<->IPv6 translation. The issue is that a IPv6 host may very=20
>> well
>> receive an ICMPv6 Packet Too Big indicating a PMTU of <1280 that was
>> originally transmitted by an IPv4 router (as an ICMPv4 Need To=20
>> Fragment)
>> and underwent translation to IPv6.
>
> Very good point, although that's basically kind of like half a tunnel=
=20
> ;-)

Yup, only difference is that an IPv6 tunnel is guaranteed to have a MTU=
=20
of
1280, so no need for allfrag or dropping PMTU below 1280. No such=20
guarantees
exist for IPv4 links.

Tore
