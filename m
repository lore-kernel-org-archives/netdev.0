From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 05:57:33 -0800
Message-ID: <20100310135733.GH6267@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003101041.32518.arnd@arndb.de> <20100310131946.GB6267@linux.vnet.ibm.com> <201003101430.06736.arnd@arndb.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41333 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932254Ab0CJN5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 08:57:36 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2ADnTpY019858
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:49:30 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2ADvZKS095682
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:57:35 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2ADvYDN021090
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:57:35 -0500
Content-Disposition: inline
In-Reply-To: <201003101430.06736.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 02:30:06PM +0100, Arnd Bergmann wrote:
> On Wednesday 10 March 2010, Paul E. McKenney wrote:
> > > When rt_hash_table[h].chain gets the __rcu_bh annotation, we'd have to
> > > turn first rcu_dereference into rcu_dereference_bh in order to have a clean
> > > build with sparse. Would that change be
> > > a) correct from RCU perspective,
> > > b) desirable for code inspection, and
> > > c) lockdep-clean?
> > 
> > I have a patch queued up that will make rcu_dereference_bh() handle this
> > correctly -- current -tip and mainline would complain.  Please see below
> > for a sneak preview.
> > 
> > Thoughts?
> 
> Ok, so that would mean we can convert it all to rcu_dereference_bh().
> I guess an alternative to this would be to also change the rcu_read_lock()
> inside local_bh_disable() sections to rcu_read_lock_bh(), which is not
> necessary but also not harmful, right?

It does impose additional overhead, which the networking guys are eager
to avoid, given that network links speeds are continuing to increase.  ;-)
So moving to rcu_dereference_bh() seems better to me.

(Please note that rcu_dereference_bh() imposes checking overhead only
in the presence of both CONFIG_PROVE_LOCKING and CONFIG_PROVE_RCU.)

							Thanx, Paul
