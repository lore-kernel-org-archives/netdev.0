From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Mon, 06 Jun 2011 18:11:45 +0200
Message-ID: <1307376705.3098.58.camel@edumazet-laptop>
References: <4DE93422.3070000@ahsoftware.de>
	 <20110606111507.GA1000@hmsreliant.think-freely.org>
	 <4DECBEA3.6070408@ahsoftware.de> <1307362358.3098.6.camel@edumazet-laptop>
	 <4DECCCC0.70905@ahsoftware.de> <1307366166.3098.15.camel@edumazet-laptop>
	 <4DECD657.9010807@ahsoftware.de> <1307370363.3098.37.camel@edumazet-laptop>
	 <20110606153213.GC1000@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Holler <holler@ahsoftware.de>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47255 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147Ab1FFQLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 12:11:49 -0400
In-Reply-To: <20110606153213.GC1000@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 11:32 -0400, Neil Horman a =C3=A9crit :

> Not to drag this out further, but since you illustrated the correct w=
ay to do
> this with the blackhole_ops test, and this modification now gives us =
two
> instances of that case, would it perhaps be better to just do this in
> dst_metrics_write_ptr:
>=20
> return dst->ops->cow_metrics ? return dst->ops->cow_metrics(dst, p) :=
 NULL;
>=20
> Then we could eliminate the two functions that do nothing be retun NU=
LL (along
> with their respective call instructions), and save any future users f=
rom having
> to remember to include a dummy cow_metrics method if they happen to s=
et the read
> only flag on thier dst_ops?

Well, I prefer how David coded the thing.
We can add selective traces where we want.

Having a default behavior might give much more work to find a bug in
this area. A NULL pointer access gives us an immediate indication.

Its a bit late to add an "if (dst->ops->cow_metrics)" test now that we
covered all call sites ;)

But we probably have more bugs elsewhere, because of many dst changes i=
n
2.6.39



