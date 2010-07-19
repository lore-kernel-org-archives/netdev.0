From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Mon, 19 Jul 2010 15:51:13 -0700
Message-ID: <AANLkTilI3rXF9ikiQOIqCOXpq4s3cfqOULBn_P8jQVrp@mail.gmail.com>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
	<AANLkTil3MVGwJUG12dikut9X1s9Ozc_3GwMjx_gErvxI@mail.gmail.com>
	<1279299709.2156.5814.camel@tng>
	<AANLkTil_c-TH6k2BDW2r5c0HYXFxiu85aMda1bT0nJt3@mail.gmail.com>
	<4C448688.1070507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McManus <mcmanus@ducksong.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	lists@wildgooses.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63681 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966620Ab0GSWvP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 18:51:15 -0400
In-Reply-To: <4C448688.1070507@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Mon, Jul 19, 2010 at 10:08 AM, Rick Jones <rick.jones2@hp.com> wrote:
> H.K. Jerry Chu wrote:
>>
>> On Fri, Jul 16, 2010 at 10:01 AM, Patrick McManus <mcmanus@ducksong.=
com>
>> wrote:
>>>
>>> can you tell us more about the impl concerns of initcwnd stored on =
the
>>> route?
>>
>>
>> We have found two issues when altering initcwnd through the ip route=
 cmd:
>> 1. initcwnd is actually capped by sndbuf (i.e., tcp_wmem[1], which i=
s
>> defaulted to a small value of 16KB). This problem has been made obsc=
ured
>> by the TSO code, which fudges the flow control limit (and could be a=
 bug
>> by
>> itself).
>
> I'll ask my Emily Litella question of the day and inquire as to why t=
hat
> would be unique to altering initcwnd via the route?
>
> The slightly less Emily Litella-esque question is why an appliction w=
ith a
> desire to know it could send more than 16K at one time wouldn't have =
either
> asked via its install docs to have the minimum tweaked (certainly if =
one is
> already tweaking routes...), or "gone all the way" and made an explic=
it
> setsockopt(SO_SNDBUF) call? =A0We are in a realm of applications for =
which
> there was a proposal to allow them to pick their own initcwnd right? =
=A0Having

Per app setting of initcwnd is just one case. Another is per route sett=
ing of
initcwnd basis through the ip route cmd. For the latter the initcwnd ch=
ange is
more or less supposed to be transparent to apps.

This wasn't a big issue and can probably be easily fixed by
initializing sk_sndbuf
to max(tcp_wmem[1], initcwnd) as you alluded to below. It is just our
experiements got hindered by this little bug but we weren't aware of it=
 sooner
due to TSO fudging sndbuf.

Jerry

> them pick an SO_SNDBUF size would seem to be no more to ask.
>
> rick jones
>
> sendbuf_init =3D max(tcp_mem,initcwnd)?
>
