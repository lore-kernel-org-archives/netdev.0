From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Wed, 18 Mar 2015 21:12:10 +1100
Message-ID: <20150318101209.GA23236@gondor.apana.org.au>
References: <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
 <20150317122033.GA12612@gondor.apana.org.au>
 <20150317124012.GH11089@casper.infradead.org>
 <20150317215638.GA16776@gondor.apana.org.au>
 <20150318095102.GL17829@casper.infradead.org>
 <20150318095516.GA22634@gondor.apana.org.au>
 <20150318100812.GM17829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "'tgraf@suug.ch'" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56092 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbbCRKMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:12:34 -0400
Content-Disposition: inline
In-Reply-To: <20150318100812.GM17829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2015 at 10:08:12AM +0000, 'tgraf@suug.ch' wrote:
>
> With this fixed up I can see what you mean. So if we are
> to only do a chain length based decision, the limit would
> have to grow together with the table size.

All we could just use a flat limit of 16 since our maximum table
size is 2^32 (actually a bit less) and 16 should be plenty for
that.

Remember this limit is only there to detect when somebody has
stolen our secret is trying to DoS us.  So if we can keep them
under 16 per-bucket it should be sufficient to defeat any attack.

Of course I will also add a patch to limit the number of elements
to the table size (so maximum utilisation is 100%).  This will come
after we allow insertions to fail.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
