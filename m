From: David Miller <davem@davemloft.net>
Subject: Re: dn_route.c momentarily exiting RCU read-side critical section
Date: Tue, 30 Oct 2007 01:10:36 -0700 (PDT)
Message-ID: <20071030.011036.43329108.davem@davemloft.net>
References: <20071029211540.GA12893@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	SteveW@ACM.org, dipankar@in.ibm.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752267AbXJ3IK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 04:10:58 -0400
In-Reply-To: <20071029211540.GA12893@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Mon, 29 Oct 2007 14:15:40 -0700

> net/decnet/dn_route.c in dn_rt_cache_get_next() is as follows:
> 
> static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_route *rt)
> {
> 	struct dn_rt_cache_iter_state *s = rcu_dereference(seq->private);
> 
> 	rt = rt->u.dst.dn_next;
> 	while(!rt) {
> 		rcu_read_unlock_bh();
> 		if (--s->bucket < 0)
> 			break;
> 
> ...  But what happens if seq->private is freed up right here?
> ...  Or what prevents this from happening?
 ...
> Similar code is in rt_cache_get_next().
> 
> So, what am I missing here?

seq->private is allocated on file open (here via seq_open_private()),
and freed up on file close (via seq_release_private).

So it cannot be freed up in the middle of an iteration.

