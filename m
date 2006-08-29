From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Wed, 30 Aug 2006 02:16:06 +0400
Message-ID: <20060829221606.GA10285@ms2.inr.ac.ru>
References: <20060828230748.827712918@localhost.localdomain> <20060828230915.587544687@localhost.localdomain> <20060829152816.GA24283@ms2.inr.ac.ru> <20060829112204.0cf5e866@localhost.localdomain> <20060829211722.GA27855@ms2.inr.ac.ru> <20060829144608.012f0d60@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:35007 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965435AbWH2WQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 18:16:19 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060829144608.012f0d60@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> > Also, probably, it makes sense to add neigh_lookup_light(), which does
> > not take refcnt, but required to call
> > neigh_release_light() (which is just rcu_read_unlock_bh()).
> 
> Which code paths would that make sense on?
> 	fib_detect_death (ok)
> 	infiniband (ok)
> 	wireless/strip (ok) -- hey, this code is crap it has
> 		a refcount leak already!
> 	arp_req_get (ok)
> 	ndisc (ok)
> 
> Perhaps killing the refcount all together, and just changing
> everybody to neigh_lookup_rcu(). Nobody holds a long term reference
> to the entries.

The only real user of refcnt is destination cache.

It uses __neigh_lookup/__neigh_lookup_errno, which could also
use neigh_lookup_rcu(), then do atomic_inc_not_zero() and, if it fails
fall to neigh_create().

Alexey
