From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Thu, 25 Sep 2008 11:42:15 +0300
Message-ID: <48DB4EE7.2030109@iki.fi>
References: <20080924055550.GA6506@gondor.apana.org.au> <48D9D86E.7020205@iki.fi> <20080924061349.GA6679@gondor.apana.org.au> <48D9DC1A.10903@iki.fi> <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au> <48DB29A9.2090204@iki.fi> <20080925075715.GA18101@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:12625 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbYIYImV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 04:42:21 -0400
Received: by nf-out-0910.google.com with SMTP id d3so118819nfc.21
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 01:42:19 -0700 (PDT)
In-Reply-To: <20080925075715.GA18101@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Sep 25, 2008 at 09:03:21AM +0300, Timo Ter=E4s wrote:
>> I forgot to test pf_key support. And remembered why the "last"
>> thingy was in the walking routines. In pf_key dumps, the dump
>> is terminated when an entry with seq zero is received; that's
>> why the final entry received special treatment. And now that
>> breaks. The first entry is zero so pf_key dumps only one entry.
>>
>> Not sure if we should fix this in pf_key or in the walking routines.
>=20
> This is part of the user-space ABI (and an RFC) so wecan't change
> it.  I've put the last stuff back and fixed up the error handling
> on the very last entry.

I was just figuring if we need to change seq in pf_key.c kernel code
or in xfrm_state.c. But I guess it's good if the walking walks as
previously.

Now there is a new problem: if dumping is interrupted and meanwhile
all the remaining entries get deleted, there is no entry to dump
with seq zero when dumping is eventually continued.

Since xfrm_user does not care for the seq as end-of-message, this
problem appears only in af_key.

Maybe we should make af_key.c code instead cache one entry before
sending it to user space. We could then get rid of the last hack
inside xfrm core walking code.

Cheers,
  Timo
