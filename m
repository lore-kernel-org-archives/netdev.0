From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Fri, 8 Oct 2010 14:56:04 -0700
Message-ID: <20101008215604.GF2408@linux.vnet.ibm.com>
References: <1286471555.2912.291.camel@edumazet-laptop>
 <20101007103051.63b5177c@nehalam>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:48566 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759919Ab0JHV4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 17:56:06 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o98Lem1T005612
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 17:40:48 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o98Lu5Zq344162
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 17:56:05 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o98Lu43W021834
	for <netdev@vger.kernel.org>; Fri, 8 Oct 2010 17:56:05 -0400
Content-Disposition: inline
In-Reply-To: <20101007103051.63b5177c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 07, 2010 at 10:30:51AM -0700, Stephen Hemminger wrote:
> On Thu, 07 Oct 2010 19:12:35 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > We tried very hard to remove all possible dev_hold()/dev_put() pairs in
> > network stack, using RCU conversions.
> > 
> > There is still an unavoidable device refcount change for every dst we
> > create/destroy, and this can slow down some workloads (routers or some
> > app servers)
> > 
> > We can switch to a percpu refcount implementation, now dynamic per_cpu
> > infrastructure is mature. On a 64 cpus machine, this consumes 256 bytes
> > per device.
> 
> It makes sense, but what about 256 cores and 1024 Vlans?
> That adds up to 4M of memory which is might be noticeable.

I bet that systems that have 256 cores have >100GB of memory, at which
point 4MB is way down in the noise.

							Thanx, Paul
