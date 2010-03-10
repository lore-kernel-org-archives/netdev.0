From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 05:13:18 -0800
Message-ID: <20100310131317.GA6267@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003092212.59627.arnd@arndb.de> <20100310021410.GD6203@linux.vnet.ibm.com> <201003101041.32518.arnd@arndb.de> <1268217583.2880.2.camel@edumazet-laptop> <20100310104907.GA23752@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:54840 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365Ab0CJNNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 08:13:21 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2AD5Evb001603
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:05:14 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2ADDKdt153030
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:13:20 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2ADDJ0h010306
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:13:20 -0500
Content-Disposition: inline
In-Reply-To: <20100310104907.GA23752@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 06:49:07PM +0800, Herbert Xu wrote:
> On Wed, Mar 10, 2010 at 11:39:43AM +0100, Eric Dumazet wrote:
> >
> > Its really rcu_dereference_bh() that could/should be used:
> > I see no problem changing
> > 
> > 
> >         local_bh_disable();
> >         ...
> >         rcu_read_lock();
> >         rcu_dereference(rt_hash_table[h].chain);
> >         rcu_read_unlock();
> >         ...
> >         local_bh_enable();
> 
> Why don't we just ignore the bh part for rcu_dereference?
> 
> After all it's call_rcu_bh and the other primitives that we really
> care about.  For rcu_dereference bh should make no difference
> whatsoever.

If CONFIG_PROVE_RCU is set, rcu_dereference() checks for rcu_read_lock()
and rcu_dereference_bh() checks for either rcu_read_lock_bh() or BH
being disabled.  Yes, this is a bit restrictive, but there are a few too
many to check by hand these days.

							Thanx, Paul
