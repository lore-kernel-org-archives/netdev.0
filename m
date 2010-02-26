From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 3/6] cnic: Fix panic in
	cnic_iscsi_nl_msg_recv() when device is down.
Date: Fri, 26 Feb 2010 10:40:01 -0800
Message-ID: <20100226184001.GJ6733@linux.vnet.ibm.com>
References: <20100226005114.GH3876@verge.net.au> <C27F8246C663564A84BB7AB34397724218312F8FD0@IRVEXCHCCR01.corp.ad.broadcom.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Simon Horman'" <horms@verge.net.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:34590 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965631Ab0BZSkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 13:40:05 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1QIQMGN008945
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 13:26:22 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1QIe2IG1614018
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 13:40:02 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1QIe120019021
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 13:40:02 -0500
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB34397724218312F8FD0@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2010 at 11:01:59PM -0800, Michael Chan wrote:
> Simon Horman wrote:
> 
> > On Wed, Feb 24, 2010 at 04:42:06PM -0800, Michael Chan wrote:
> > > Some data structures are freed when the device is down and it will
> > > crash if an ISCSI netlink message is received.  Add RCU protection
> > > to prevent this.  In the shutdown path, ulp_ops[CNIC_ULP_L4] is
> > > assigned NULL and rcu_synchronized before freeing the data
> > > structures.
> >
> > Is rcu_assign_pointer() unnecessary in cnic_cm_open()?
> > It doesn't seem to be followed by rcu_synchronized() and the pointer
> > doesn't seem to be accessible anywhere else at that time.
> 
> We assign a valid pointer in cnic_cm_open() so that it can be used
> during run-time (in service_kcqes() for example).  During shutdown in
> cnic_stop_hw(), we assign NULL followed by rcu_synchronize().

So you are saying that when the pointer is assigned in cnic_cm_open(),
there cannot possibly be any concurrent reading threads?

Use of an explicit rcu_assign_pointer() would be better if so.

							Thanx, Paul
