From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 20:23:46 +1100
Message-ID: <200902042023.47916.nickpiggin@yahoo.com.au>
References: <20090202.235017.253437221.davem@davemloft.net> <20090203.164609.160183741.davem@davemloft.net> <20090204080851.GA10445@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, w@1wt.eu, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp113.mail.mud.yahoo.com ([209.191.84.66]:47942 "HELO
	smtp113.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751972AbZBDJYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 04:24:17 -0500
In-Reply-To: <20090204080851.GA10445@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 February 2009 19:08:51 Evgeniy Polyakov wrote:
> On Tue, Feb 03, 2009 at 04:46:09PM -0800, David Miller (davem@davemloft.net) 
wrote:
> > > NTA tried to solve this by not allowing to free the data allocated on
> > > the different CPU, contrary to what SLAB does. Modulo cache coherency
> > > improvements,
> >
> > This could kill performance on NUMA systems if we are not careful.
> >
> > If we ever consider NTA seriously, these issues would need to
> > be performance tested.
>
> Quite contrary I think. Memory is allocated and freed on the same CPU,
> which means on the same memory domain, closest to the CPU in question.
>
> I did not test NUMA though, but NTA performance on the usual CPU (it is
> 2.5 years old already :) was noticebly good.

I had a quick look at NTA... I didn't understand much of it yet, but
the remote freeing scheme is kind of like what I did for slqb. The
freeing CPU queues objects back to the CPU that allocated them, which
eventually checks the queue and frees them itself.

I don't know how much cache coherency gains you get from this -- in
most slab allocations, I think the object tends to be cache on on the
CPU that frees it. I'm doing it mainly to try avoid locking... I guess
that makes for cache coherency benefit itself.

If NTA does significantly better than slab allocator, I would be quite
interested. It might be something that we can learn from and use in
the general slab allocator (or maybe something more network specific
that NTA does).

