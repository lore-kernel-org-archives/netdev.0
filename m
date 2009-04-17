From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Fri, 17 Apr 2009 12:25:51 -0700
Message-ID: <20090417192551.GA15538@linux.vnet.ibm.com>
References: <49E5FF5E.50409@cosmosbay.com> <20090415215454.GU6766@linux.vnet.ibm.com> <49E6C4C7.3050105@cosmosbay.com> <20090417.045631.159492677.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:59432 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbZDQTZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 15:25:54 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3HJFbR8019289
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 15:15:37 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3HJPpCV185726
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 15:25:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3HJPoNx003171
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 15:25:51 -0400
Content-Disposition: inline
In-Reply-To: <20090417.045631.159492677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 04:56:31AM -0700, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 16 Apr 2009 07:40:23 +0200
> 
> > [PATCH] net: remove superfluous call to synchronize_net()
> > 
> > inet_register_protosw() function is responsible for adding a new
> > inet protocol into a global table (inetsw[]) that is used with RCU rules.
> > 
> > As soon as the store of the pointer is done, other cpus might see
> > this new protocol in inetsw[], so we have to make sure new protocol
> > is ready for use. All pending memory updates should thus be committed
> > to memory before setting the pointer.
> > This is correctly done using rcu_assign_pointer()
> > 
> > synchronize_net() is typically used at unregister time, after
> > unsetting the pointer, to make sure no other cpu is still using
> > the object we want to dismantle. Using it at register time
> > is only adding an artificial delay that could hide a real bug,
> > and this bug could popup if/when synchronize_rcu() can proceed
> > faster than now.
> > 
> > This saves about 13 ms on boot time on a HZ=1000 8 cpus machine  ;) 
> > (4 calls to inet_register_protosw(), and about 3200 us per call)
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> I think this change is fine, so I'm adding it to net-next-2.6
> 
> If you guys want to continue discussing the merits of putting
> comments in every spot where we lack a RCU sync call, that's
> your call. :-)

Your Honor, I plead guilty to charges as read.  ;-)

							Thanx, Paul
