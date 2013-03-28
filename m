From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 12:39:57 -0700
Message-ID: <20130328193957.GH3337@linux.vnet.ibm.com>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
 <1364478265.15753.42.camel@edumazet-glaptop>
 <20130328182356.GE3337@linux.vnet.ibm.com>
 <1364496577.15753.51.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Balakumaran Kannan <kumaran.4353@gmail.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:60728 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab3C1Tku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 15:40:50 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 28 Mar 2013 15:40:49 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6490E38C804F
	for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 15:40:46 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2SJej8K347094
	for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 15:40:45 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2SJgdoF031309
	for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 13:42:41 -0600
Content-Disposition: inline
In-Reply-To: <1364496577.15753.51.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 11:49:37AM -0700, Eric Dumazet wrote:
> On Thu, 2013-03-28 at 11:23 -0700, Paul E. McKenney wrote:
> 
> > 
> > Agreed, there is no point in using RCU when it is not needed.
> > 
> > That said...
> > 
> > Since v3.1, in CONFIG_PREEMPT=y kernels, rcu_read_lock() does not
> > disable preemption.  In CONFIG_PREEMPT=n kernels, rcu_read_lock() does
> > disable preemption, but to no effect because preemption is already
> > disabled anyway.
> > 
> > The net effect is that rcu_read_lock() has no effect on preemption.
> > 
> 
> Good point, but this patch might be a stable candidate.
> 
> Rule of thumb for networking is 
> 
> 1) Control path : RTNL mutex
> 
> 2) Data path : RTNL cant be taken (from softirq), so use RCU if
> possible.

Stable candidate and rules of thumb sound good to me!

							Thanx, Paul
