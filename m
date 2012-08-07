From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: fib: fix incorrect call_rcu_bh()
Date: Tue, 7 Aug 2012 10:07:02 -0700
Message-ID: <20120807170702.GH2378@linux.vnet.ibm.com>
References: <1344336431.28967.14.camel@edumazet-glaptop>
 <20120807163454.GF2378@linux.vnet.ibm.com>
 <1344358094.28967.116.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:40894 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081Ab2HGR2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 13:28:34 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 7 Aug 2012 13:28:33 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 942B23C60A41
	for <netdev@vger.kernel.org>; Tue,  7 Aug 2012 13:07:14 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q77H77HN9044030
	for <netdev@vger.kernel.org>; Tue, 7 Aug 2012 13:07:07 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q77H72ZY005231
	for <netdev@vger.kernel.org>; Tue, 7 Aug 2012 11:07:03 -0600
Content-Disposition: inline
In-Reply-To: <1344358094.28967.116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 07, 2012 at 06:48:14PM +0200, Eric Dumazet wrote:
> On Tue, 2012-08-07 at 09:34 -0700, Paul E. McKenney wrote:
> > On Tue, Aug 07, 2012 at 12:47:11PM +0200, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > After IP route cache removal, I believe rcu_bh() has very little use and
> > > we should remove this RCU variant, since it adds some cycles in fast
> > > path.
> > 
> > Do you mean remove all uses of RCU-bh globally and also removing the
> > implementation itself?  That would actually be a good thing, from my
> > perspective.
> > 
> 
> Yes I meant that there are now too few rcu_bh users, and that they
> probably could switch to regular rcu.
> 
> We could then remove the implementation.
> 
> rcu_bh was needed because we could sit forever in softirq mode in one
> cpu, and we needed to allocate/free dsts with RCU protection.

Very cool!!!  Anything I can do to help, aside of course from the final
removal of RCU-bh support?

							Thanx, Paul
