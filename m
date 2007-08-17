From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net/core/dst.c : Should'nt dst_run_gc() be more scalable
 and friendly ?
Date: Fri, 17 Aug 2007 10:10:30 +0200
Message-ID: <20070817101030.cc64467a.dada1@cosmosbay.com>
References: <20070816153619.2c699e21.dada1@cosmosbay.com>
	<E1ILft1-0001Db-00@gondolin.me.apana.org.au>
	<20070816174044.43c90ff4.dada1@cosmosbay.com>
	<20070816233339.GA11594@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:45244 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759699AbXHQIKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 04:10:32 -0400
In-Reply-To: <20070816233339.GA11594@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007 07:33:39 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Aug 16, 2007 at 05:40:44PM +0200, Eric Dumazet wrote:
> > 
> > So do you think this patch is enough or should we convert dst_run_gc processing from softirq to workqueue too ?
> 
> I think a workqueue would be the best solution since with
> that you wouldn't have to worry about processing things in
> chunks.

Will a workqueue react the same in case of a DDOS situation, 
where softirq could use all CPU cycles to handle incoming
packets and feed the GC list, and GC would never
have a chance to scan and free some items ?

About chunk processing, I did it on purpose, to not throw away
all CPU cache. Goal is to process entries, but not all of them
in a row, especially if we find many yet referenced entries
(and thus not candidates to freeing)

Thanks


