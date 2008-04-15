From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/2][NETNS]: The generic per-net pointers.
Date: Tue, 15 Apr 2008 00:36:23 -0700 (PDT)
Message-ID: <20080415.003623.104148675.davem@davemloft.net>
References: <4800848D.6020101@openvz.org>
	<20080414162220.GC9250@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752983AbYDOHgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 03:36:22 -0400
In-Reply-To: <20080414162220.GC9250@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Mon, 14 Apr 2008 09:22:20 -0700

> On Sat, Apr 12, 2008 at 01:44:45PM +0400, Pavel Emelyanov wrote:
> > Add the elastic array of void * pointer to the struct net.
> > The access rules are simple:
> > 
> >  1. register the ops with register_pernet_gen_device to get
> >     the id of your private pointer
> >  2. call net_assign_generic() to put the private data on the
> >     struct net (most preferably this should be done in the
> >     ->init callback of the ops registered)
> >  3. do not store any private reference on the net_generic array;
> >  4. do not change this pointer while the net is alive;
> >  5. use the net_generic() to get the pointer.
> > 
> > When adding a new pointer, I copy the old array, replace it
> > with a new one and schedule the old for kfree after an RCU
> > grace period.
> > 
> > Since the net_generic explores the net->gen array inside rcu
> > read section and once set the net->gen->ptr[x] pointer never 
> > changes, this grants us a safe access to generic pointers.
> > 
> > Quoting Paul: "... RCU is protecting -only- the net_generic 
> > structure that net_generic() is traversing, and the [pointer]
> > returned by net_generic() is protected by a reference counter 
> > in the upper-level struct net."
> 
> ;-)  One of the nice things about both reference counting and RCU
> is that you can safely "sandwich" the protection regions in this
> way.  If you try it with pure locking, you are prone to deadlock.
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Also applied, thanks everyone.
