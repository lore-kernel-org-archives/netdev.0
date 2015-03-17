From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 23:20:33 +1100
Message-ID: <20150317122033.GA12612@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'tgraf@suug.ch'" <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:37600 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbbCQMVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 08:21:01 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 12:13:42PM +0000, David Laight wrote:
> From: Thomas Graf 
> > Sent: 17 March 2015 11:58
> ...
> > > Do you really want to double the table size when 0.1% of the buckets
> > > have a chain length > 4 but still < 16?
> > 
> > If we constantly hit that bucket because we are handling just a few
> > TCP flows it would be worth to double the size & rehash to avoid the
> > additional cache misses of the linked list.
> > 
> > Although a limit of 4 would be too high. Ideally we should resize and
> > rehash when we add the 2nd entry to a bucket to stay < 100% utilization.
> > It seems likely though that we'll always have a bucket with >=2
> > entries so we would end up constantly doubling and rehashing. This is
> > the only thing that speaks for a table wide nelems counters in my
> > opinion.
> 
> I think you are seriously overestimating the 'efficiency' of the hash function.
> And not doing the 'birthday paradox' maths at all.

Agreed.  Thomas, an easy test to do is to pump the integers from
0 to 65535 into jhash, then mask it with 65535 and run sort |
uniq -c | sort -n on it, I think you'll see what we're talking
about.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
