From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 3 Feb 2011 13:17:19 -0800
Message-ID: <AANLkTimWHAz0SX_u42guHp2KNyQESsH6ysNwRoe7ZVJ=@mail.gmail.com>
References: <20110202.170750.229739784.davem@davemloft.net>
	<47859e9273bb0c1b2c32fc1adfa450ee@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org, therbert@google.com
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62468 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892Ab1BCVR4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 16:17:56 -0500
In-Reply-To: <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 3, 2011 at 6:00 AM, Hagen Paul Pfeifer <hagen@jauu.net> wro=
te:
>
> On Wed, 02 Feb 2011 17:07:50 -0800 (PST), David Miller wrote:
>
>> +/* TCP initial congestion window */
>> +#define TCP_INIT_CWND =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A010
>> +
>
> Davem, there is _no_ research how this huge IW will behave in environ=
ments
> with a small BDP. Belief it or not, but there are networks out there =
with a
> BDP similar to ~1980. Why for heaven's sake should this work in these
> environments? There are only _two_ extensive analysis one from Cherry=
 and
> and one from Ilpo. Both analysis focus on current mainstream BDP. I s=
tarted

It's more than that. We have also conducted extensive, large scale
experiments covering
all BDP/RTT combinations and the result was documented in details in a
SIGCOMM/CCR paper that can be found from a summary page
http://code.google.com/speed/protocols/tcpm-IW10.html covering all our
IW10 work.

> to setup a ns-2 environment but due to lack of time I am a little bit
> behind schedule. Anyway, why not make this a tunable per route knob s=
o that
> it is easier to fix things, e.g. set IW back to 3.

You've seemed to get this backwards. Shouldn't we set the default for t=
he normal
cases and leave the corner cases to the initcwnd and initrwnd knobs to =
cover?

Jerry

>
> HGN
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
