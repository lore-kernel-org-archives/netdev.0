From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Wed, 18 Mar 2015 10:26:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB0337A@AcuExch.aculab.com>
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
 <20150318101209.GA23236@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	"'tgraf@suug.ch'" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:54107 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755844AbbCRK1r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:27:47 -0400
In-Reply-To: <20150318101209.GA23236@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
..
> Of course I will also add a patch to limit the number of elements
> to the table size (so maximum utilisation is 100%).  This will come
> after we allow insertions to fail.

There may be some uses where short hash chains are acceptable.
In which case a utilisation way above 100% may make sense.

If a table is likely to have repeated lookups for the same item
then it can make sense to cache the last looked up item for each chain.
This cached value can be written without any locking - the only
place care is needed is ensuring it doesn't reference an item
that has just been deleted.
(You'd want a separate array to not dirty the cache lines containing
the head pointers. Although for a large table they are misses anyway.)

	David
