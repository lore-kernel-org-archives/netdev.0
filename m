From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Wed, 31 Mar 2010 10:38:36 -0700
Message-ID: <20100331173836.GG2461@linux.vnet.ibm.com>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
 <20100330161819.9628.10853.stgit@bert.katalix.com>
 <20100330093252.60d9cbee@nehalam>
 <4BB31761.2090906@katalix.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:57180 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755436Ab0CaRii (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 13:38:38 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2VHQqoO015156
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 13:26:52 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2VHcbgY142800
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 13:38:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2VHcblD005554
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 13:38:37 -0400
Content-Disposition: inline
In-Reply-To: <4BB31761.2090906@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 10:35:29AM +0100, James Chapman wrote:
> Stephen Hemminger wrote:
> > On Tue, 30 Mar 2010 17:18:19 +0100
> > James Chapman <jchapman@katalix.com> wrote:
> > 
> >> +struct l2tp_eth_net {
> >> +	struct list_head l2tp_eth_dev_list;
> >> +	rwlock_t l2tp_eth_lock;
> >> +};
> > 
> > Reader/write locks are discouraged because they are slower than
> > spin locks.  If you have lots of readers use RCU, if reading
> > is infrequent just use a spin lock.
> 
> Ok. In doing the conversion of the rwlocks in l2tp_core.c, I'm finding
> that some list access primitives don't have rcu equivalents, namely
> list_is_last(), list_for_each_entry_safe(). Is this intentional? Should
> I add the missing ones in a separate patch?

The list_is_last() is RCU-safe already, since the ->next pointer is
only compared, never dereferenced.  I suggest adding a comment to its
header stating that it is RCU-safe.

Feel free to create a list_for_each_entry_safe_rcu(), and I will be
happy to review it.

							Thanx, Paul
