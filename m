From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Tue, 24 Apr 2012 14:50:54 -0700
Message-ID: <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	<CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	<1335298228.5205.168.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55905 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757191Ab2DXVuz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 17:50:55 -0400
Received: by iadi9 with SMTP id i9so1534356iad.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 14:50:54 -0700 (PDT)
In-Reply-To: <1335298228.5205.168.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 24, 2012 at 1:10 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Tue, 2012-04-24 at 12:49 -0700, Maciej =C5=BBenczykowski wrote:
>> Why do we refuse to set ipv6 mtu's below 1280?
>> how is what we do any better?
>
> I guess you didnt read Tore use case.
>
> Thats the standard : http://tools.ietf.org/html/rfc2460#section-5
>
> =C2=A0 In response to an IPv6 packet that is sent to an IPv4 destinat=
ion
> =C2=A0 (i.e., a packet that undergoes translation from IPv6 to IPv4),=
 the
> =C2=A0 originating IPv6 node may receive an ICMP Packet Too Big messa=
ge
> =C2=A0 reporting a Next-Hop MTU less than 1280. =C2=A0In that case, t=
he IPv6 node
> =C2=A0 is not required to reduce the size of subsequent packets to le=
ss than

=2E.. is not required to reduce...

but doesn't that mean it _may_ reduce anyway?
and thus make life easier on the guy who will have to fragment (and
thus he won't have to fragment).

[of course you'd still need to lose 8 bytes for the frag header...]

> =C2=A0 1280, but must include a Fragment header in those packets so t=
hat the
> =C2=A0 IPv6-to-IPv4 translating router can obtain a suitable Identifi=
cation
> =C2=A0 value to use in resulting IPv4 fragments. =C2=A0Note that this=
 means the
> =C2=A0 payload may have to be reduced to 1232 octets (1280 minus 40 f=
or the
> =C2=A0 IPv6 header and 8 for the Fragment header), and smaller still =
if
> =C2=A0 additional extension headers are used.

I just don't see what not decreasing mtu below 1280 buys us.
