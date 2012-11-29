From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 3/9] net: frag, move LRU list maintenance
 outside of rwlock
Date: Thu, 29 Nov 2012 23:33:51 +0100
Message-ID: <1354228431.11754.355.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161137.17754.48002.stgit@dragon>
	 <1354211004.3299.12.camel@edumazet-glaptop>
	 <20121129.124839.963269461515687321.davem@davemloft.net>
	 <1354211659.3299.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157Ab2K2WfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 17:35:22 -0500
In-Reply-To: <1354211659.3299.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 09:54 -0800, Eric Dumazet wrote:
> On Thu, 2012-11-29 at 12:48 -0500, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 29 Nov 2012 09:43:24 -0800
> > 
> > > Use a schem with a hash table of 256 (or 1024) slots.
> > > 
> > > Each slot/bucket has : 
> > >   - Its own spinlock.
> > >   - List of items
> > >   - A limit of 5 (or so) elems in the list.
> > > 
> > > No more LRU, no more rehash (thanks to jhash and the random seed at boot
> > > or first frag created), no more reader-writer lock.
> > > 
> > > Use a percpu_counter to implement ipfrag_low_thresh/ipfrag_high_thresh
> > 
> > If we limit the chain sizes to 5 elements, there is no need for
> > any thresholds at all.
> 
> One element can hold about 100KB.
> 
> I guess some systems could have some worries if we consume 1024 * 5 *
> 100 KB

1024 * 5 * 100k = 512 MB  -- That's just crasy!
I guess the embedded guys is going to choke reading this! 

Look at what I have achieved with 256KBytes per CPU...

--Jesper
