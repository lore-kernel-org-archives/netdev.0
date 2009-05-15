From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 07:15:30 -0400
Message-ID: <20090515111530.GD7745@hmsreliant.think-freely.org>
References: <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515054947.GA4497@ff.dom.local> <20090515110141.GB7745@hmsreliant.think-freely.org> <20090515111213.GA6807@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58651 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbZEOLPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 07:15:45 -0400
Content-Disposition: inline
In-Reply-To: <20090515111213.GA6807@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 11:12:14AM +0000, Jarek Poplawski wrote:
> On Fri, May 15, 2009 at 07:01:41AM -0400, Neil Horman wrote:
> > On Fri, May 15, 2009 at 05:49:47AM +0000, Jarek Poplawski wrote:
> ...
> > > IMHO it looks worse now. rcu_read_lock() suggests it's a read side,
> > > and spin_lock(&trace_state_lock) protects something else.
> > > 
> > the read lock is required (according to the comments for the list loop
> > primitive) to protect against the embedded mutation primitive, so its required.
> > I understand that its a bit counterintuitive, but intuition takes a backseat to
> > functionality. :)
> > Neil
> > 
> 
> I guess, you missed:
> 
> > Looks good from an RCU viewpoint!
> > 
> > Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> for the previous version...
> 
I didn't, our comments passed in flight.  Nevertheless, I'm not sure what this
adds (other than additional overhead), which I agree is bad and so might should
be removed, but there are some outstanding questions regarding if it is needed
in relation to the list primitives I'm using here.  According to Eric,
list_for_each_entry_safe might be less intrusive here, and I'm trying to figure
out if I agree. :)
Neil

> Jarek P.
> 
