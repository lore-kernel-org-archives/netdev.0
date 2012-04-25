From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 04:02:55 -0700
Message-ID: <CANP3RGeV9Z2z3i4GYyupU2tBVbL-4nX2-h2e8MP=PP4WE2s9qw@mail.gmail.com>
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
	<7333a1d306fa2eca215bc9f55d23d03c@greed.fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48004 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758383Ab2DYLC4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 07:02:56 -0400
Received: by iadi9 with SMTP id i9so2345463iad.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 04:02:56 -0700 (PDT)
In-Reply-To: <7333a1d306fa2eca215bc9f55d23d03c@greed.fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think you forgot to include the explanation why. :-)

I did try, I just didn't do a very good job.

> I suppose. This would be invisible to IPv6, though - the fragmentatio=
n and
> reassembly happens at a lower layer than IPv6. Same as ATM for exampl=
e. Situation is
> described by RFC 2460:

It would be invisible (*), and you probably wouldn't really need the
frag header in the ipv6 packet,
but it would still be desirable to have ipv6 already have packets
smaller than ipv4
mtu - 20, rather than have to frag/unfrag at the tunnel endpoint.
Since it is always more efficient to have fragmented correctly in the
first place.

(*) Would it be legal for a tunnel endpoint to support ipv6 packets up
to 1280 bytes in size
but still send back a 'packet to big please use 1K mtu' message?

> =C2=ABOn any link that cannot convey a 1280-octet packet in one piece=
,
> link-specific fragmentation and reassembly must be provided at a laye=
r below IPv6.=C2=BB

True...  I wonder how far we should bend over, just because it'll do
the work for us,
doesn't mean it isn't more efficient to do it ourselves...

Eh, not sure it's really worth the bother, I've never seen ipv6
tunneled over something with a small (<1280) but not tiny (>200) mtu.

>> (re: Eric's patch, I think it should protect itself against maliciou=
s
>> PMTU messages with too small MTUs, like 0 or 1 or 68 [not enough for
>> timestamped ipv6/tcp)
>
>
> Does this happen for IPv4, I wonder? IMHO, it makes sense to keep the=
 the
> minimum
> PMTUDs allowed in sync. If PMTUD=3D1 is allowed in IPv4, and this is =
not
> problematic,
> I don't see why it couldn't be allowed in IPv6 either.
>
> Tore
>
>



--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
