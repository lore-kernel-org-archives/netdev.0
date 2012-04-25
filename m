From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 02:52:02 -0700
Message-ID: <CANP3RGeQR8pguGQgBy_vdL_jjeo52q2LOawBDAPey5gh7OwTHQ@mail.gmail.com>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	<CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	<1335298228.5205.168.camel@edumazet-glaptop>
	<CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	<1335331960.5205.180.camel@edumazet-glaptop>
	<CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
	<f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
	<1335346710.3274.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:35525 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757477Ab2DYJwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 05:52:03 -0400
Received: by iadi9 with SMTP id i9so2272954iad.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 02:52:02 -0700 (PDT)
In-Reply-To: <1335346710.3274.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm, but what if we change linux to choice a) instead of b) ?
>
> That is, not cap mtu to minimum value 1280 (and not use anymore
> RTAX_FEATURE_ALLFRAG) : dst_allfrag() would be always false.
>
> In this case, do we still need to send the frag header ?

Yeah, I was wondering about that myself.

By my reading of the relevant RFC it's not quite clear whether you
truly must include the frag header even if you choose to obey the
lower than 1280 mtu.
Although I don't see any reason why you would need to...
So long as there's a decent minimum pmtu we're willing to obey.

> I ask this because some TSO6 implementations probably dont cope very
> well with this added header (untested path)

Yes, I was thinking the same thing, hence why I mentioned GSO.
