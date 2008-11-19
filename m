From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Wed, 19 Nov 2008 13:17:39 -0800
Message-ID: <20081119211739.GF6753@linux.vnet.ibm.com>
References: <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com> <20081119170117.GA6753@linux.vnet.ibm.com> <49245290.1050408@cosmosbay.com> <20081119184624.GE6753@linux.vnet.ibm.com> <20081119185347.GA30491@ghostprotocols.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vya
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:40923 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753085AbYKSVSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 16:18:01 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAJLHaHU015042
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 16:17:36 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAJLHeGm151908
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 16:17:43 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAJMHiNN017579
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 17:17:45 -0500
Content-Disposition: inline
In-Reply-To: <20081119185347.GA30491@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2008 at 04:53:47PM -0200, Arnaldo Carvalho de Melo wrote:
> Em Wed, Nov 19, 2008 at 10:46:24AM -0800, Paul E. McKenney escreveu:
> > For whatever it is worth, here is a more complete use case, on the
> > off-chance that it becomes useful some time:
> > 
> > 	retry:
> > 	rcu_read_lock();
> 
> 	retry: /* should be here, huh? */

Indeed!  Either that or have an rcu_read_unlock() before the
goto retry.

Good catch!

							Thanx, Paul

> > 	hlist_nulls_for_each_entry_rcu(tpos, pos, head, hn_node) {
> > 		if (!(curgen = still_valid(tpos)))
> > 			goto retry;
> > 		if (needs_deletion(tpos)) {
> > 			spin_lock(&update_side_lock);
> > 			if (still_valid(tpos) == curgen)
> > 				hlist_nulls_del_init_rcu(pos);
> > 			spin_unlock(&update_side_lock);
> > 		}
> > 	}
> > 	rcu_read_unlock();
> 
> - Arnaldo
