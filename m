From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 3/6] cnic: Fix panic in
	cnic_iscsi_nl_msg_recv() when device is down.
Date: Fri, 26 Feb 2010 11:33:36 -0800
Message-ID: <20100226193336.GM6733@linux.vnet.ibm.com>
References: <20100226005114.GH3876@verge.net.au> <C27F8246C663564A84BB7AB34397724218312F8FD0@IRVEXCHCCR01.corp.ad.broadcom.com> <20100226184001.GJ6733@linux.vnet.ibm.com> <1267211469.19491.8.camel@nseg_linux_HP1.broadcom.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Simon Horman'" <horms@verge.net.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:46642 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965824Ab0BZTdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 14:33:38 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1QJMdwV025660
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 14:22:39 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1QJXb9g1867914
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 14:33:37 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1QJXafS021361
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 14:33:36 -0500
Content-Disposition: inline
In-Reply-To: <1267211469.19491.8.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2010 at 11:11:09AM -0800, Michael Chan wrote:
> 
> On Fri, 2010-02-26 at 10:40 -0800, Paul E. McKenney wrote:
> > On Thu, Feb 25, 2010 at 11:01:59PM -0800, Michael Chan wrote:
> > > Simon Horman wrote:
> > > 
> > > > On Wed, Feb 24, 2010 at 04:42:06PM -0800, Michael Chan wrote:
> > > > > Some data structures are freed when the device is down and it will
> > > > > crash if an ISCSI netlink message is received.  Add RCU protection
> > > > > to prevent this.  In the shutdown path, ulp_ops[CNIC_ULP_L4] is
> > > > > assigned NULL and rcu_synchronized before freeing the data
> > > > > structures.
> > > >
> > > > Is rcu_assign_pointer() unnecessary in cnic_cm_open()?
> > > > It doesn't seem to be followed by rcu_synchronized() and the pointer
> > > > doesn't seem to be accessible anywhere else at that time.
> > > 
> > > We assign a valid pointer in cnic_cm_open() so that it can be used
> > > during run-time (in service_kcqes() for example).  During shutdown in
> > > cnic_stop_hw(), we assign NULL followed by rcu_synchronize().
> > 
> > So you are saying that when the pointer is assigned in cnic_cm_open(),
> > there cannot possibly be any concurrent reading threads?
> 
> Right.  The hardware has not been started yet so there will be no events
> to process from the hardware.  The pointer is read when processing these
> hardware events.
> 
> > 
> > Use of an explicit rcu_assign_pointer() would be better if so.
> 
> Yes, we use rcu_assign_pointer in cnic_cm_open() when assigning the
> valid pointer in cnic_cm_open().  Thanks.

Sounds very good, thank you!

							Thanx, Paul
