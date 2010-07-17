From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Fri, 16 Jul 2010 17:36:46 -0700
Message-ID: <AANLkTil_c-TH6k2BDW2r5c0HYXFxiu85aMda1bT0nJt3@mail.gmail.com>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
	<AANLkTil3MVGwJUG12dikut9X1s9Ozc_3GwMjx_gErvxI@mail.gmail.com>
	<1279299709.2156.5814.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, davidsen@tmr.com,
	lists@wildgooses.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50640 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab0GQAgr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 20:36:47 -0400
In-Reply-To: <1279299709.2156.5814.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 16, 2010 at 10:01 AM, Patrick McManus <mcmanus@ducksong.com=
> wrote:
> On Wed, 2010-07-14 at 21:51 -0700, H.K. Jerry Chu wrote:
>> =A0except there are indeed bugs in the code today in that the
>> code in various places assumes initcwnd as per RFC3390. So when
>> initcwnd is raised, that actual value may be limited unnecessarily b=
y
>> the initial wmem/sk_sndbuf.
>
> Thanks for the discussion!
>
> can you tell us more about the impl concerns of initcwnd stored on th=
e
> route?

We have found two issues when altering initcwnd through the ip route cm=
d:
1. initcwnd is actually capped by sndbuf (i.e., tcp_wmem[1], which is
defaulted to a small value of 16KB). This problem has been made obscure=
d
by the TSO code, which fudges the flow control limit (and could be a bu=
g by
itself).

2. the congestion backoff code is supposed to take inflight, rather tha=
n cwnd,
but initcwnd presents a special case. I don't fully understand the code=
 yet to
propose a fix.

>
> and while I'm asking for info, can you expand on the conclusion
> regarding poor cache hit rates for reusing learned cwnds? (ok, I admi=
t I
> only read the slides.. maybe the paper has more info?)

This is partly due to our load balancer policy resulting in poor cache =
hit,
partly due to the sheer volumes of remote clients. Some of colleagues
tried to change the host cache to a /24 subnet cache but the result was=
n't
that good either (sorry I don't remember all the details.)

>
> article and slides much appreciated and very interetsing. I've long b=
een
> of the opinion that the downsides of being too aggressive once in a
> while aren't all that serious anymore.. as someone else said in a
> non-reservation world you are always trying to predict the future any=
how
> and therefore overflowing a queue is always possible no matter how
> conservative.

Please voice your support to TCPM then :)

Jerry

>
>
>
>
>
