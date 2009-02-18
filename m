From: David Miller <davem@davemloft.net>
Subject: Re: [RFT 4/4] netfilter: Get rid of central rwlock in tcp
 conntracking
Date: Wed, 18 Feb 2009 13:55:12 -0800 (PST)
Message-ID: <20090218.135512.104648058.davem@davemloft.net>
References: <20090218051906.174295181@vyatta.com>
	<20090218052747.679540125@vyatta.com>
	<499BDB5D.2050105@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rick.jones2@hp.com, dada1@cosmosbay.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499BDB5D.2050105@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 18 Feb 2009 10:56:45 +0100

> Stephen Hemminger wrote:
> 
> > @@ -50,6 +50,7 @@ struct ip_ct_tcp_state {
> >  struct ip_ct_tcp
> >  {
> > +	spinlock_t	lock;
> >  	struct ip_ct_tcp_state seen[2];	/* connection parameters per direction */
> >  	u_int8_t	state;		/* state of the connection (enum tcp_conntrack) */
> >  	/* For detecting stale connections */
> 
> Eric already posted a patch to use an array of locks, which is
> a better approach IMO since it keeps the size of the conntrack
> entries down.

Just as a side note, we generally frown upon the
hash-array-of-spinlocks approach to scalability.

If you need proof that in the long term it's suboptimal, note that:

1) this is Solaris's approach to locking scalability :-)

2) every such case in the kernel eventually gets transformed into
   RCU, a tree/trie based scheme, or some combination of the two

So maybe for now it's ok, but keep in mind that eventually
this is certain to change. :)
