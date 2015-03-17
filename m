From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 13:06:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB02607@AcuExch.aculab.com>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
 <20150317112203.GG11089@casper.infradead.org>
 <20150317112726.GC11671@gondor.apana.org.au>
 <20150317115749.GJ17829@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB02567@AcuExch.aculab.com>
 <20150317122033.GA12612@gondor.apana.org.au>
 <20150317124012.GH11089@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "'tgraf@suug.ch'" <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:64983 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbbCQNIG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 09:08:06 -0400
In-Reply-To: <20150317124012.GH11089@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf
> Sent: 17 March 2015 12:40
...
> I'm not claiming perfect hash functions and this is exactly why I
> think average utilization is not an optimal growth criteria because
> it gives very limited view into the actual chain lengths.

If you assume that all the entries are being looked up equally
often the interesting number ought to be the number of failed compares.
So you want to sum 'length * (length - 1)/2' and compare against the
total number of items (or the table size).

> What you describe above is a 100% utilization scenario. Initially
> we talked about 0.1% utilization and whether to resize & rehash if a
> single chain has length > 4. My answer is: yes we should resize &
> rehash or at least rehash in that case.

0.1% utilisation is about as realistic as 100%.
50-75% is probably a reasonable limit.
This will give some short chains.

> My point here is that a chain length of 4 may be a serious
> performance bottleneck already and that it might be worth to try
> and detect bad hashing distribution and attempt to fix it at an
> earlier stage while ruling out the possibility of endless rehashes.

If you have 4 items and they are all on one chain they I suspect that
nothing you do will actually split them.

OTOH if you have 1000 items and one chain of length 4 it really doesn't
matter. Unless, of course, someone arranges to flood the last item with
traffic - in which case you are going to lose anyway.

	David
