From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 08:26:58 -0800
Message-ID: <20100310162658.GI6267@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003092212.59627.arnd@arndb.de> <20100310021410.GD6203@linux.vnet.ibm.com> <201003101041.32518.arnd@arndb.de> <1268217583.2880.2.camel@edumazet-laptop> <20100310104907.GA23752@gondor.apana.org.au> <20100310131317.GA6267@linux.vnet.ibm.com> <20100310140729.GA25704@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:53981 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756284Ab0CJQ1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 11:27:01 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2AGGaYR005240
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 11:16:36 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2AGQxxN089742
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 11:26:59 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2AGQw1o012828
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 11:26:59 -0500
Content-Disposition: inline
In-Reply-To: <20100310140729.GA25704@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 10:07:29PM +0800, Herbert Xu wrote:
> On Wed, Mar 10, 2010 at 05:13:18AM -0800, Paul E. McKenney wrote:
> >
> > If CONFIG_PROVE_RCU is set, rcu_dereference() checks for rcu_read_lock()
> > and rcu_dereference_bh() checks for either rcu_read_lock_bh() or BH
> > being disabled.  Yes, this is a bit restrictive, but there are a few too
> > many to check by hand these days.
> 
> Fair enough.  We should get those fixed then.  In fact I reckon
> most of them should be using the BH variant so we might be able
> to kill a few rcu_read_lock's which would be a real gain.

I have -tip commit a898def29e4119bc01ebe7ca97423181f4c0ea2d that
converts some of the rcu_dereference()s in net/core/filter.c,
net/core/dev.c, net/decnet/dn_route.c, net/packet/af_packet.c, and
net/ipv4/route.c to rcu_dereference_bh().

How should we coordinate the removal of the rcu_read_lock() calls?

							Thanx, Paul
