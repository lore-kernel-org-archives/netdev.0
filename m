From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 04:55:51 -0700
Message-ID: <CANP3RGdv1eoPP-UNrbif92teH_9oO-WA0CZXJsDREwrcYiRODQ@mail.gmail.com>
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
	<CANP3RGeV9Z2z3i4GYyupU2tBVbL-4nX2-h2e8MP=PP4WE2s9qw@mail.gmail.com>
	<4b7a2708fd4545ac65cfef6561e7f02a@greed.fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56212 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757383Ab2DYLzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 07:55:52 -0400
Received: by ghrr11 with SMTP id r11so1027993ghr.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 04:55:52 -0700 (PDT)
In-Reply-To: <4b7a2708fd4545ac65cfef6561e7f02a@greed.fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> (*) Would it be legal for a tunnel endpoint to support ipv6 packets up
>> to 1280 bytes in size
>> but still send back a 'packet to big please use 1K mtu' message?
>
>
> I don't think this is a valid thing to do - either the tunnel server would
> forward the packet through the tunnel (fragmenting the underlaying IPv4 if
> necessary), and *not* send back a ICMPv6 PTB error at the same time, OR: it
> would need to drop the packet and *do* send back the ICMPv6 PTB. Not both
> at the same time.
>
> However, if it is going to drop the large packets and reply with the PTB, it
> will cause a blackhole with current Linux, because if it get the PTB with
> MTU=1000, it will include the frag header, but *not* reduce the actual
> packet
> size. And since this is pure IPv6 routing, the tunnel server will not be
> able
> to fragment the IPv6 packets, since IPv6 routers don't do that (the presense
> of the Fragmentation header does not change this fact).
>
> So the tunnel routers pretty much *must* support an IPv6 MTU of 1280, either
> by ensuring the outer IPv4 MTU is 1300 or larger, or by performing IPv4
> fragmentation and reassembly "under the hood".

I think you could still accept 1280 mtu packets, but for packets >= 1281 mtu
you could return packet to big, please use mtu=1000.

>
> I don't think it is worth while (or even appropriate) for the Linux IPv6
> stack
> to try to optimize for this.

Agreed.  Let's ignore this.
