From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 14:30:06 +0100
Message-ID: <201003101430.06736.arnd@arndb.de>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003101041.32518.arnd@arndb.de> <20100310131946.GB6267@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56859 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756532Ab0CJNkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 08:40:15 -0500
In-Reply-To: <20100310131946.GB6267@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 March 2010, Paul E. McKenney wrote:
> > When rt_hash_table[h].chain gets the __rcu_bh annotation, we'd have to
> > turn first rcu_dereference into rcu_dereference_bh in order to have a clean
> > build with sparse. Would that change be
> > a) correct from RCU perspective,
> > b) desirable for code inspection, and
> > c) lockdep-clean?
> 
> I have a patch queued up that will make rcu_dereference_bh() handle this
> correctly -- current -tip and mainline would complain.  Please see below
> for a sneak preview.
> 
> Thoughts?

Ok, so that would mean we can convert it all to rcu_dereference_bh().
I guess an alternative to this would be to also change the rcu_read_lock()
inside local_bh_disable() sections to rcu_read_lock_bh(), which is not
necessary but also not harmful, right?

	Arnd
