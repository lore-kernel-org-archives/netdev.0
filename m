From: David Miller <davem@davemloft.net>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Wed, 09 Jan 2008 06:31:26 -0800 (PST)
Message-ID: <20080109.063126.68241252.davem@davemloft.net>
References: <20080109094637.GA28874@gondor.apana.org.au>
	<20080109113727.50eae500.dada1@cosmosbay.com>
	<20080109142258.GC13714@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, herbert@gondor.apana.org.au,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751918AbYAIOb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 09:31:27 -0500
In-Reply-To: <20080109142258.GC13714@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 9 Jan 2008 06:22:58 -0800

> On Wed, Jan 09, 2008 at 11:37:27AM +0100, Eric Dumazet wrote:
> > On Wed, 9 Jan 2008 20:46:37 +1100
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index d337706..28484f3 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
> >  			break;
> >  		rcu_read_unlock_bh();
> >  	}
> > -	return r;
> > +	return rcu_dereference(r);
> >  }
> 
> Would it be possible to tag rt_cache_get_first() with an __acquires(RCU)
> to help out sparse?

Sparse can't handle conditional locking very well, as is done here.
There is a seperate thread where Eric reworks how all of this
locking is done in order to pacify sparse and be able to add the
__acquires() etc. tags and some of us found it too ugly to
swallow :-)
