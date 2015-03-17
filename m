From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 12:13:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "'tgraf@suug.ch'" <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:60918 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbbCQMOx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 08:14:53 -0400
In-Reply-To: <20150317115749.GJ17829@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf 
> Sent: 17 March 2015 11:58
...
> > Do you really want to double the table size when 0.1% of the buckets
> > have a chain length > 4 but still < 16?
> 
> If we constantly hit that bucket because we are handling just a few
> TCP flows it would be worth to double the size & rehash to avoid the
> additional cache misses of the linked list.
> 
> Although a limit of 4 would be too high. Ideally we should resize and
> rehash when we add the 2nd entry to a bucket to stay < 100% utilization.
> It seems likely though that we'll always have a bucket with >=2
> entries so we would end up constantly doubling and rehashing. This is
> the only thing that speaks for a table wide nelems counters in my
> opinion.

I think you are seriously overestimating the 'efficiency' of the hash function.
And not doing the 'birthday paradox' maths at all.

The only way you'll get a 'hash' that good is if you can pick the input
value in order to generate a perfect hash.
However you aren't going to manage that for inbound TCP connections since
none of the inputs to the hash can be chosen by the listening system
(unless IPv6 has something than can help you).

You may have to live with a few % of the items being on long chains.
Maybe count the number of items on chains longer than (say) 4 and
rehash or increase the table size if this exceeds a few % of the
table size.
(Or count the number of items that are further than 4 from the start
of the hash chain.)

	David
