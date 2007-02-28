From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [NET]: Handle disabled preemption in gfp_any()
Date: Tue, 27 Feb 2007 17:25:11 -0800
Message-ID: <20070228012510.GD1919@linux.vnet.ibm.com>
References: <45E46EE3.9040802@trash.net> <20070227.095657.106265863.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:49109 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbXB1BZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 20:25:17 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1S1PFst013538
	for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 20:25:15 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1S1PFda498238
	for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 18:25:15 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1S1PEZv025835
	for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 18:25:14 -0700
Content-Disposition: inline
In-Reply-To: <20070227.095657.106265863.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 27, 2007 at 09:56:57AM -0800, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 27 Feb 2007 18:48:19 +0100
> 
> > [NET]: Handle disabled preemption in gfp_any()
> > 
> > ctnetlink uses netlink_unicast from an atomic_notifier_chain
> > (which is called within a RCU read side critical section)
> > without holding further locks. netlink_unicast calls netlink_trim
> > with the result of gfp_any() for the gfp flags, which are passed
> > down to pskb_expand_header. gfp_any() only checks for softirq
> > context and returns GFP_KERNEL, resulting in this warning:
> > 
> > BUG: sleeping function called from invalid context at mm/slab.c:3032
> > in_atomic():1, irqs_disabled():0
> > no locks held by rmmod/7010.
> 
> Applied, good catch Patrick.

Breaks -rt, but I will submit a patch to Ingo to that will make this
fix work in the -rt context.  I nevertheless agree that this is a good
catch!!!

						Thanx, Paul
