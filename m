From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable
 and friendly ?
Date: Fri, 17 Aug 2007 10:31:13 +0200
Message-ID: <20070817103113.e737c2d9.dada1@cosmosbay.com>
References: <20070816153619.2c699e21.dada1@cosmosbay.com>
	<E1ILft1-0001Db-00@gondolin.me.apana.org.au>
	<20070816174044.43c90ff4.dada1@cosmosbay.com>
	<20070816233339.GA11594@gondor.apana.org.au>
	<20070817101030.cc64467a.dada1@cosmosbay.com>
	<20070817081522.GA16720@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:45450 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbXHQIbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 04:31:15 -0400
In-Reply-To: <20070817081522.GA16720@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007 16:15:22 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Aug 17, 2007 at 10:10:30AM +0200, Eric Dumazet wrote:
> >
> > Will a workqueue react the same in case of a DDOS situation, 
> > where softirq could use all CPU cycles to handle incoming
> > packets and feed the GC list, and GC would never
> > have a chance to scan and free some items ?
> 
> Well when that happens the softirqs will be deferred to
> ksoftirqd which should share the CPU fairly with the
> workqueue.

Thats nice :)

I'll code a workqueue based thing in about 10 days after my hollidays,
and perform DOS tests as well.

Thanks for the feedback.

> 
> > About chunk processing, I did it on purpose, to not throw away
> > all CPU cache. Goal is to process entries, but not all of them
> > in a row, especially if we find many yet referenced entries
> > (and thus not candidates to freeing)
> 
> I agree that chunks are desirable for a timer since you'd
> be hogging the CPU otherwise.  However, if you went to a
> workqueue then it's less of a concern and would simplify
> things.  In particular, you won't have to pick a good
> chunk size :)
