From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 1/3] rhashtable: Add a function for in order
 insertion in buckets
Date: Wed, 15 Jul 2015 09:08:06 +0800
Message-ID: <20150715010806.GA30213@gondor.apana.org.au>
References: <1436834353-1851565-2-git-send-email-tom@herbertland.com>
 <20150714095721.GA22264@gondor.apana.org.au>
 <CALx6S34mGfzUbmPvsxTZDSJX7tehoh4j3nee3C33a57_FFnerw@mail.gmail.com>
 <20150714235837.GA29279@gondor.apana.org.au>
 <CALx6S37KRjff719DT_+f2EXoJ6ehdvX7P-jvgca9cTiHCSrkDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:32941 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbbGOBIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 21:08:18 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S37KRjff719DT_+f2EXoJ6ehdvX7P-jvgca9cTiHCSrkDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 05:59:53PM -0700, Tom Herbert wrote:
>
> Conceptually, I agree with you, but I would point out that we've had
> this model of intentional collisions for a while in socket lookup. I
> would assume that it's a goal to use rhashtable for socket tables, so
> we'll need some solution that works with that!

Why you couldn't have them hang off a node as I described earlier?

> > The other reason I wanted to have this logic outside of rhashtable
> > is because for IPsec, the wildcards may in fact change after a
> > "rehash".  For example we may move from a /32 granularity to a
> > /31 granlarity at the requst of the admin.  In that case you can't
> > just mix the chain from the old table with the new.
> >
> Where ordering elements in the table can't be sustained, scoring would
> be used (e.g. scoring function can be changed on the fly, but ordering
> rules can't be).

I'm not sure whether we're talking about the same thing here.

Let me describe the IPsec case more clearly.  We have wildcards
and non-wildcards.  Only the non-wildcards would be hashed.  The
wild cards are checked outside of the hash table.  The tricky bit
is that the admin can flip a switch and we may either have to move
previously wildcard entries that are no longer wildcards into the
hash table, or move non-wildcard entries out of the table and into
the wildcard list.

And of course we want to do this without imposing locking on the
reader :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
