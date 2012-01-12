From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [BUG] commit a9b3cd7f32 is a mess
Date: Thu, 12 Jan 2012 09:12:01 -0800
Message-ID: <20120112171201.GC2419@linux.vnet.ibm.com>
References: <1326376603.2950.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:37764 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543Ab2ALROe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 12:14:34 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 12 Jan 2012 12:14:33 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0CHDOBf279724
	for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 12:13:24 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0CHC2aG014100
	for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 10:12:02 -0700
Content-Disposition: inline
In-Reply-To: <1326376603.2950.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 02:56:43PM +0100, Eric Dumazet wrote:
> commit a9b3cd7f32 (rcu: convert uses of rcu_assign_pointer(x, NULL) to
> RCU_INIT_POINTER) is complete garbage.
> 
> Real content of this commit doesnt reflect Changelog claim.
> 
> I found this while trying to understand a 3.2 regression in IGMP code.
> 
> 	iml->sfmode = MCAST_EXCLUDE;
> -	rcu_assign_pointer(inet->mc_list, iml);
> +	RCU_INIT_POINTER(inet->mc_list, iml);
> 
> Obviously iml is not NULL here.
> 
> Please Paul dont Ack a patch only reading the Changelog.

Sigh.  That will teach me to trust coccinelle.  :-(

> I'll make a patch to revert all non NULL uses.

Please accept my apologies.  I will avoid trusting coccinelle quite so
much in the future, and thank you for fixing this up.

							Thanx, Paul
