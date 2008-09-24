From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 08:46:09 +0300
Message-ID: <48D9D421.9050500@iki.fi>
References: <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi> <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi> <20080923133234.GA30370@gondor.apana.org.au> <48D8F337.2050103@iki.fi> <20080924042349.GA5419@gondor.apana.org.au> <48D9CCA3.2040500@iki.fi> <20080924051555.GA6218@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:10243 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbYIXFqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 01:46:14 -0400
Received: by ey-out-2122.google.com with SMTP id 6so718473eyi.37
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 22:46:12 -0700 (PDT)
In-Reply-To: <20080924051555.GA6218@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Sep 24, 2008 at 08:14:11AM +0300, Timo Ter=E4s wrote:
>> Only comment is that there really should be struct for the
>> shared stuff. Otherwise it's bound to break at some point.
>=20
> That's why I put comments there.  If people change it without
> reading the comments, they'll ignore the struct too :)

Well, it's also because in the dump routine the entries
are cast to xfrm_state, even if it was a walker entry. This
is just wrong, though it probably works since only the specific
entries are used.

There should be some intermediate struct which we use to=20
iterate in dumping routing, check if it was iterator/real entry
(can be still based on the state thing). And only after that
cast to struct xfrm_state. It would make the dumping routine
more readable.

Cheers,
  Timo
