From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Wed, 19 Nov 2008 16:53:47 -0200
Message-ID: <20081119185347.GA30491@ghostprotocols.net>
References: <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C282A.5050802@cosmosbay.com> <20081119170117.GA6753@linux.vnet.ibm.com> <49245290.1050408@cosmosbay.com> <20081119184624.GE6753@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christian Bell <christian@myri.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53238 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752580AbYKSSyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 13:54:43 -0500
Content-Disposition: inline
In-Reply-To: <20081119184624.GE6753@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Nov 19, 2008 at 10:46:24AM -0800, Paul E. McKenney escreveu:
> For whatever it is worth, here is a more complete use case, on the
> off-chance that it becomes useful some time:
> 
> 	retry:
> 	rcu_read_lock();

	retry: /* should be here, huh? */

> 	hlist_nulls_for_each_entry_rcu(tpos, pos, head, hn_node) {
> 		if (!(curgen = still_valid(tpos)))
> 			goto retry;
> 		if (needs_deletion(tpos)) {
> 			spin_lock(&update_side_lock);
> 			if (still_valid(tpos) == curgen)
> 				hlist_nulls_del_init_rcu(pos);
> 			spin_unlock(&update_side_lock);
> 		}
> 	}
> 	rcu_read_unlock();

- Arnaldo
