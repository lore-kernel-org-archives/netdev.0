From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 17:07:44 -0700
Message-ID: <20090516000744.GE6759@linux.vnet.ibm.com>
References: <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515054947.GA4497@ff.dom.local> <20090515110141.GB7745@hmsreliant.think-freely.org> <20090515111213.GA6807@ff.dom.local> <20090515111530.GD7745@hmsreliant.think-freely.org> <20090515114029.GB6807@ff.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:59682 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbZEPAHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 20:07:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4G02Xdf028483
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 20:02:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4G07kks256806
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 20:07:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4G07jZZ007329
	for <netdev@vger.kernel.org>; Fri, 15 May 2009 20:07:46 -0400
Content-Disposition: inline
In-Reply-To: <20090515114029.GB6807@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 11:40:29AM +0000, Jarek Poplawski wrote:
> On Fri, May 15, 2009 at 07:15:30AM -0400, Neil Horman wrote:
> > On Fri, May 15, 2009 at 11:12:14AM +0000, Jarek Poplawski wrote:
> > > On Fri, May 15, 2009 at 07:01:41AM -0400, Neil Horman wrote:
> > > > On Fri, May 15, 2009 at 05:49:47AM +0000, Jarek Poplawski wrote:
> > > ...
> > > > > IMHO it looks worse now. rcu_read_lock() suggests it's a read side,
> > > > > and spin_lock(&trace_state_lock) protects something else.
> > > > > 
> > > > the read lock is required (according to the comments for the list loop
> > > > primitive) to protect against the embedded mutation primitive, so its required.
> > > > I understand that its a bit counterintuitive, but intuition takes a backseat to
> > > > functionality. :)
> > > > Neil
> > > > 
> > > 
> > > I guess, you missed:
> > > 
> > > > Looks good from an RCU viewpoint!
> > > > 
> > > > Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > 
> > > for the previous version...
> > > 
> > I didn't, our comments passed in flight.  Nevertheless, I'm not sure what this
> > adds (other than additional overhead), which I agree is bad and so might should
> > be removed, but there are some outstanding questions regarding if it is needed
> > in relation to the list primitives I'm using here.  According to Eric,
> > list_for_each_entry_safe might be less intrusive here, and I'm trying to figure
> > out if I agree. :)
> > Neil
> 
> Paul "acked" two variants, and Eric prefers one of them. Adding
> rcu_read_lock() makes sense only "If this code was shared between the
> read side and the update side". Anyway it would need additional
> comment. Otherwise it's misleading (but not wrong). And, since Paul
> reviewed this, it's definitely not needed here because Paul is simply
> always right ;-)

Much as I appreciate the vote of confidence...  ;-)

I believe that both versions work correctly, and that the difference
is therefore a matter of style.  My mild preference would be to use
rcu_read_lock() only if there was some possibility that a reader (some
task not holding the update-side lock) would execute this code.

							Thanx, Paul
