From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Thu, 25 Sep 2008 12:01:30 +0300
Message-ID: <48DB536A.7020209@iki.fi>
References: <20080924061349.GA6679@gondor.apana.org.au> <48D9DC1A.10903@iki.fi> <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au> <48DB29A9.2090204@iki.fi> <20080925075715.GA18101@gondor.apana.org.au> <48DB4EE7.2030109@iki.fi> <20080925085634.GA18853@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:14239 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbYIYJBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 05:01:36 -0400
Received: by nf-out-0910.google.com with SMTP id d3so121667nfc.21
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 02:01:34 -0700 (PDT)
In-Reply-To: <20080925085634.GA18853@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Sep 25, 2008 at 11:42:15AM +0300, Timo Ter=E4s wrote:
>> Maybe we should make af_key.c code instead cache one entry before
>> sending it to user space. We could then get rid of the last hack
>> inside xfrm core walking code.
>=20
> Yes that should work.  But you want to keep cache the skb instead
> of the state since the latter can die.

Exactly, keep the converted entry in skb, since we have to allocate
that anyway. And when there's no more entries coming from enumerator
the sequence number of final skb is adjusted to zero.

Not sure if I can finish it today, but I think I should have the
time by tomorrow. Unless you have time to do it before that, I'll
post a patch later this week. Will update the similar xfrm_policy
patch for that too, before sending it.

- Timo
