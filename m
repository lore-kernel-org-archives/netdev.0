From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 02:48:27 -0700
Message-ID: <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	<CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	<1335298228.5205.168.camel@edumazet-glaptop>
	<CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	<1335331960.5205.180.camel@edumazet-glaptop>
	<CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
	<f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43020 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406Ab2DYJs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 05:48:28 -0400
Received: by yenl12 with SMTP id l12so969949yen.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 02:48:27 -0700 (PDT)
In-Reply-To: <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I get that we _choose_ to behave such, and I agree this adheres to
>> specs.
>
> "Chose" (past), not "choose" (present). ;-)

Details, but until we 'choose' to change it we continuously 'choose'
to have the current behaviour. ;-)

> This patch does not make this choice. This patch merely fixes a bug in
> the implementation of the choice that was made a long time ago.

yes, I wasn't saying this patch was bad, I was just wanting to point
that we should perhaps revisit the design choice.

>> But I'm not convinced that (even though this is allowed per RFC) this
>> is the right choice.
>
> That is a different issue entirely, but I don't disagree with you. A
> "min_pmtu" sysctl or something like that would be useful.

I don't really know what the default value should be?  Something around 500?
[to handle IPv4s min mtu of 576?]

Do we have any idea what values of small mtu actually show up in practice?

> Actually, in IPv6, fragmentation *must* be performed by end hosts,
> routers (including tunnel end points) *cannot* fragment.

Yes, I miss-phrased that, that's what I meant.

> However, the use case for the allfrag feature is not handling tunnels,
> but IPv4<->IPv6 translation. The issue is that a IPv6 host may very well
> receive an ICMPv6 Packet Too Big indicating a PMTU of <1280 that was
> originally transmitted by an IPv4 router (as an ICMPv4 Need To Fragment)
> and underwent translation to IPv6.

Very good point, although that's basically kind of like half a tunnel ;-)

> In case you're interested, I have a slide deck below that explains the
> use case for IPv4<->IPv6 translation. Slide 25 is about the particular
> corner case where the allfrag feature is necessary. URL:
>
> http://fud.no/talks/20120417-RIPE64-The_Case_for_IPv6_Only_Data_Centres.pdf

Yes, I've seen this slide set a couple days ago - very good.
