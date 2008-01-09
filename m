From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Wed, 9 Jan 2008 06:43:39 -0800
Message-ID: <20080109144339.GF13714@linux.vnet.ibm.com>
References: <20080109094637.GA28874@gondor.apana.org.au> <20080109113727.50eae500.dada1@cosmosbay.com> <20080109142258.GC13714@linux.vnet.ibm.com> <20080109.063126.68241252.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, herbert@gondor.apana.org.au,
	dipankar@in.ibm.com, netdev@vger.kernel.org, josh@freedesktop.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43774 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbYAIOns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 09:43:48 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09Ehg3j028794
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 09:43:42 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09EhfRD129248
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 07:43:41 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09EheMm026115
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 07:43:41 -0700
Content-Disposition: inline
In-Reply-To: <20080109.063126.68241252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 06:31:26AM -0800, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Wed, 9 Jan 2008 06:22:58 -0800
> 
> > On Wed, Jan 09, 2008 at 11:37:27AM +0100, Eric Dumazet wrote:
> > > On Wed, 9 Jan 2008 20:46:37 +1100
> > > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > 
> > > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > > index d337706..28484f3 100644
> > > --- a/net/ipv4/route.c
> > > +++ b/net/ipv4/route.c
> > > @@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
> > >  			break;
> > >  		rcu_read_unlock_bh();
> > >  	}
> > > -	return r;
> > > +	return rcu_dereference(r);
> > >  }
> > 
> > Would it be possible to tag rt_cache_get_first() with an __acquires(RCU)
> > to help out sparse?
> 
> Sparse can't handle conditional locking very well, as is done here.
> There is a seperate thread where Eric reworks how all of this
> locking is done in order to pacify sparse and be able to add the
> __acquires() etc. tags and some of us found it too ugly to
> swallow :-)

Ah!  ;-)

							Thanx, Paul
