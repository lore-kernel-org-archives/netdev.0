From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/2] SCTP: Add RCU synchronization around sctp_localaddr_list
Date: Wed, 12 Sep 2007 08:20:58 -0700
Message-ID: <20070912152058.GB9830@linux.vnet.ibm.com>
References: <11894535901969-git-send-email-vladislav.yasevich@hp.com> <11894535913932-git-send-email-vladislav.yasevich@hp.com> <20070910214712.GI11801@linux.vnet.ibm.com> <46E642AA.7090703@us.ibm.com> <46E6A096.9010208@hp.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:43866 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759396AbXILPVC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 11:21:02 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8CFKxIx009928
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:20:59 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CFKxc1685670
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:20:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CFKwcE004930
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:20:59 -0400
Content-Disposition: inline
In-Reply-To: <46E6A096.9010208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 11, 2007 at 10:05:10AM -0400, Vlad Yasevich wrote:
> Sridhar, Paul
> 
> Thanks for review.  Some answers and questions below...

NP!

> Sridhar Samudrala wrote:
> > Paul E. McKenney wrote:

[ . . . ]

> >>>                  if ((PF_INET == sk->sk_family) &&
> >>>                      (AF_INET6 == addr->a.sa.sa_family))
> >>>                      continue;
> >>> +
> >>>                  cnt++;
> >>>              }
> >>> +            rcu_read_unlock();
> >>
> >> We are just counting these things, right?  If on the other hand we are
> >> keeping a reference outside of rcu_read_lock() protection, then there
> >> needs to be some explicit mechanism preventing the corresponding entry
> >> from being freed.
> 
> In this particular case, we are just counting.  There are other cases,
> we make a copy of the address in the list.  The goal was to reduce the
> probability that an address that is about to be deleted at the rcu
> quiescent state will not be copied/counted.
> 
> My other thought was to use atomics, but with all the yelling about atomic_read(),
> that didn't seem any better then a simple __u8 flag.

If just counting, then no worries either way.  As long as you are counting
to a local variable, as in fact you are.

							Thanx, Paul
