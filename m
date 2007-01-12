From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: RCU info
Date: Fri, 12 Jan 2007 13:19:48 +0100
Message-ID: <20070112121948.GA1707@ff.dom.local>
References: <20070111082958.GB1672@ff.dom.local> <20070111083526.GC1672@ff.dom.local> <20070111083934.GA2578@ff.dom.local> <20070111.012755.15271378.davem@davemloft.net> <20070111110902.GA3561@ff.dom.local> <20070111094213.08907e1f@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, greearb@candelatech.com,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:38139 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750977AbXALMRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 07:17:51 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070111094213.08907e1f@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 11, 2007 at 09:42:13AM -0800, Stephen Hemminger wrote:
> Paul McKenney has given lots of talks on RCU see:
> 	http://www.rdrop.com/users/paulmck/RCU/
> 
> and look in Documentation/RCU
 
I've read a lot of this but it's sometimes confusing e.g.:

>From Documentation/RCU/checklist.txt:

>9.      All RCU list-traversal primitives, which include
>        list_for_each_rcu(), list_for_each_entry_rcu(),
>        list_for_each_continue_rcu(), and list_for_each_safe_rcu(),
>        must be within an RCU read-side critical section.  RCU
>        read-side critical sections are delimited by rcu_read_lock()
>        and rcu_read_unlock(), or by similar primitives such as
>        rcu_read_lock_bh() and rcu_read_unlock_bh().

So "All" and "must be"!

>        Use of the _rcu() list-traversal primitives outside of an
>        RCU read-side critical section causes no harm other than
>        a slight performance degradation on Alpha CPUs.  It can
>        also be quite helpful in reducing code bloat when common
>        code is shared between readers and updaters.

... or not all and not must be?


I think, probably because of examples in those docs -  mostly with 
spin_locks (or without preemption), I've got wrong conviction that
writers (or more often readers and writers) in their reading part
aren't allowed to be preempted or block also. But after rethinking
yesterday explanation of David Miller I undestood the writers have
more possibilities and individual analyzis is required each time.

Many thanks once more to everyone,

Jarek P. 
