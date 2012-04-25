From: Tore Anderson <tore@fud.no>
Subject: Re: [PATCH net-next] ipv6: =?UTF-8?Q?RTAX=5FFEATURE=5FALLFRAG=20c?=  =?UTF-8?Q?auses=20inefficient=20TCP=20segment=20sizing?=
Date: Wed, 25 Apr 2012 12:45:02 +0200
Message-ID: <7333a1d306fa2eca215bc9f55d23d03c@greed.fud.no>
References: <1335289058.5205.165.camel@edumazet-glaptop>
 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
 <1335298228.5205.168.camel@edumazet-glaptop>
 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
 <1335331960.5205.180.camel@edumazet-glaptop>
 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
 <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
 <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
 <CANP3RGf5oTd9mQsXqKj3uXgweMwjs9N3VSeXBHjDXQ7vG0NaSg@mail.gmail.com>
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
Received: from greed.fud.no ([87.238.35.20]:56155 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758056Ab2DYKpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 06:45:06 -0400
In-Reply-To: <CANP3RGf5oTd9mQsXqKj3uXgweMwjs9N3VSeXBHjDXQ7vG0NaSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Maciej =C5=BBenczykowski

>> The sensible default would be either 1280 (and keep allfrag=20
>> feature), or
>> the minimum IPv4 PMTU currently enforced by the kernel + 20 bytes=20
>> (to
>> compensate for the larger IPv6 header size). I don't know what the=20
>> current
>> minimum PMTU is.
>
> I'd actually go with min IPv4 PMTU - 20, not + 20, see below for why.

I think you forgot to include the explanation why. :-)

> Hmm, it may be best to honour PMTUs below 1280 to some small but not
> too small value (512?), and below that give up, say mtu remains 1280
> but still add the frag header.

That is also possible, yes.

> Hmm, I thought one way to implement an IPv6 over IPv4 tunnel was to=20
> basically
> rely on IPv4 fragmentation, hence you would actually be using the=20
> same mechanism
> as for an IPv6-IPv4 translator, then you would be tunneling the IPv6=20
> packet over IPv4,
> so your IPv6 mtu would be 20 less than the v4 one, not 20 more which=20
> you get if you
> replace the v6 header with a smaller v4 one.
>
> Anyway, this certainly seems like an ipv6-in-ipv4 tunneling mechanism
> which would currently work, wouldn't it?

I suppose. This would be invisible to IPv6, though - the fragmentation=20
and reassembly
happens at a lower layer than IPv6. Same as ATM for example. Situation=20
is described
by RFC 2460:

=C2=ABOn any link that cannot convey a 1280-octet packet in one piece,=20
link-specific
fragmentation and reassembly must be provided at a layer below IPv6.=C2=
=BB

> (re: Eric's patch, I think it should protect itself against malicious
> PMTU messages with too small MTUs, like 0 or 1 or 68 [not enough for
> timestamped ipv6/tcp)

Does this happen for IPv4, I wonder? IMHO, it makes sense to keep the=20
the minimum
PMTUDs allowed in sync. If PMTUD=3D1 is allowed in IPv4, and this is no=
t=20
problematic,
I don't see why it couldn't be allowed in IPv6 either.

Tore
