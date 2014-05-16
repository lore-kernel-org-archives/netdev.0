From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH] net: gro: make sure skb->cb[] initial content has not
 to be zero
Date: Fri, 16 May 2014 22:08:22 +0300
Message-ID: <20140516220822.5d749752@vostro>
References: <20140516104014.607d2d0f@vostro>
	<1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516173443.0b40157e@vostro>
	<1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516194037.4486cd63@vostro>
	<1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516200112.114cf1bb@vostro>
	<1400260430.7973.222.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140516203835.5941ea3f@vostro>
	<1400263479.5367.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1400265277.5367.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:41081 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbaEPTIE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 15:08:04 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so2270097lbi.29
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 12:08:03 -0700 (PDT)
In-Reply-To: <1400265277.5367.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2014 11:34:37 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
>=20
> Starting from linux-3.13, GRO attempts to build full size skbs.
>=20
> Problem is the commit assumed one particular field in skb->cb[]
> was clean, but it is not the case on some stacked devices.
>=20
> Timo reported a crash in case traffic is decrypted before
> reaching a GRE device.
>=20
> Fix this by initializing NAPI_GRO_CB(skb)->last at the right place,
> this also removes one conditional.
>=20
> Thanks a lot to Timo for providing full reports and bisecting this.
>=20
> Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> Bisected-by: Timo Teras <timo.teras@iki.fi>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Please Timo test this patch so that we confirm it fixes the bug for
> you.

Yes, everything looks green now! (The test case reproduced the crash
reliably and immediately. Now it's been up and working for more than
tens minutes already :)

Tested-by: Timo Ter=C3=A4s <timo.teras@iki.fi>

Needless to say, this should go to 3.14-stable as well.

Thanks a lot Eric!
