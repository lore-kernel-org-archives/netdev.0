From: "tgraf@suug.ch" <tgraf@suug.ch>
Subject: Re: [v1 PATCH 1/14] rhashtable: Remove shift from bucket_table
Date: Tue, 17 Mar 2015 11:22:03 +0000
Message-ID: <20150317112203.GG11089@casper.infradead.org>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX61x-0005m7-GV@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CB024AB@AcuExch.aculab.com>
 <20150317105657.GE11089@casper.infradead.org>
 <20150317110041.GA11385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48304 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107AbbCQLWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 07:22:05 -0400
Content-Disposition: inline
In-Reply-To: <20150317110041.GA11385@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/15 at 10:00pm, Herbert Xu wrote:
> On Tue, Mar 17, 2015 at 10:56:57AM +0000, tgraf@suug.ch wrote:
> >
> > Given the discussions, the grow decision will likely change to
> > a max bucket length limit anyway.
> 
> Actually no.  In my pathces the chain length is only used to
> force an immediate rehash.  Growing is still based on the number
> of elements.
> 
> The reason is that the maximum (not average) chain length actually
> grows with the hash table size, even at 75% utilisation.
> 
> So unless we want ever decreasing utilisation as the table grows,
> we have to cope with a few chains with many elements.  The limit
> I'm currently using is 16 which shouldn't be hit even if you had
> a 2^32 table (which you currently cannot).

Not sure I understand the downside of a bucket length based grow
decision with optional forced rehashing plus synchroneous table
realloc if we hit a 2nd watermark as you proposed earlier. Shouldn't
we consider deterministic lookup and insert behaviour more important
than overall table utilization? Given the rehashing, the grow decision
should not be attackable.
