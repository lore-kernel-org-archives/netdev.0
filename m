From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Thu, 25 Sep 2008 09:03:21 +0300
Message-ID: <48DB29A9.2090204@iki.fi>
References: <20080924051555.GA6218@gondor.apana.org.au> <48D9D421.9050500@iki.fi> <20080924055550.GA6506@gondor.apana.org.au> <48D9D86E.7020205@iki.fi> <20080924061349.GA6679@gondor.apana.org.au> <48D9DC1A.10903@iki.fi> <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:13973 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbYIYGDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 02:03:34 -0400
Received: by ey-out-2122.google.com with SMTP id 6so88871eyi.37
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 23:03:32 -0700 (PDT)
In-Reply-To: <20080924140819.GA10022@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Sep 24, 2008 at 04:18:37PM +0300, Timo Ter=E4s wrote:
>> Gave it a test spin and found one bug. The walking routine will
>> get called one extra time when it has successfully dumped
>> everything so we need to check for that in the beginning; the
>> earlier version would start all over from the beginning resulting
>> never ending dumps.
>=20
> Aha, that's why the if statement was there :)

Yup.

I forgot to test pf_key support. And remembered why the "last"
thingy was in the walking routines. In pf_key dumps, the dump
is terminated when an entry with seq zero is received; that's
why the final entry received special treatment. And now that
breaks. The first entry is zero so pf_key dumps only one entry.

Not sure if we should fix this in pf_key or in the walking routines.

Cheers,
  Timo

