From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 09:04:30 +0300
Message-ID: <48D9D86E.7020205@iki.fi>
References: <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi> <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi> <20080923133234.GA30370@gondor.apana.org.au> <48D8F337.2050103@iki.fi> <20080924042349.GA5419@gondor.apana.org.au> <48D9CCA3.2040500@iki.fi> <20080924051555.GA6218@gondor.apana.org.au> <48D9D421.9050500@iki.fi> <20080924055550.GA6506@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:1949 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbYIXGEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 02:04:35 -0400
Received: by nf-out-0910.google.com with SMTP id d3so854305nfc.21
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 23:04:34 -0700 (PDT)
In-Reply-To: <20080924055550.GA6506@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Sep 24, 2008 at 08:46:09AM +0300, Timo Ter=E4s wrote:
>> Well, it's also because in the dump routine the entries
>> are cast to xfrm_state, even if it was a walker entry. This
>> is just wrong, though it probably works since only the specific
>> entries are used.
>=20
> No it works because all walker entries set the state to DEAD
> so they're skipped by everybody else.

Yes, I know. I was pointing the fact that the walker function
iterates using struct xfrm_state. So temporarily when it is
iterating through the walker entry, we get strct xfrm_state
pointer which points to some place before the struct xfrm_state_walk.
Now since the km.state is checked first, those are skipped.

I find it very confusing to let the code say "iterate through
list of struct xfrm_state" when it is not such a list. It is a
list of struct xfrm_state or struct xfrm_state_walk. So I'd use
some intermediate struct to so the code can say e.g "iterate
through list of struct xfrm_state_dump_entry" or whatever.

Or at least add a comment to the dumping function to say that
we have struct xfrm_state, but in matter of fact it can be
also struct xfrm_state_walk pointer with displacement, so we
better check km.state first.

Cheers,
  Timo
