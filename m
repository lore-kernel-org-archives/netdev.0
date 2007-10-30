From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: dn_route.c momentarily exiting RCU read-side critical section
Date: Tue, 30 Oct 2007 08:12:54 -0700
Message-ID: <20071030151254.GA8285@linux.vnet.ibm.com>
References: <20071029211540.GA12893@linux.vnet.ibm.com> <20071030.011036.43329108.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	SteveW@ACM.org, dipankar@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:58809 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbXJ3Peh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 11:34:37 -0400
Content-Disposition: inline
In-Reply-To: <20071030.011036.43329108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 01:10:36AM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Mon, 29 Oct 2007 14:15:40 -0700
> 
> > net/decnet/dn_route.c in dn_rt_cache_get_next() is as follows:
> > 
> > static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_route *rt)
> > {
> > 	struct dn_rt_cache_iter_state *s = rcu_dereference(seq->private);
> > 
> > 	rt = rt->u.dst.dn_next;
> > 	while(!rt) {
> > 		rcu_read_unlock_bh();
> > 		if (--s->bucket < 0)
> > 			break;
> > 
> > ...  But what happens if seq->private is freed up right here?
> > ...  Or what prevents this from happening?
>  ...
> > Similar code is in rt_cache_get_next().
> > 
> > So, what am I missing here?
> 
> seq->private is allocated on file open (here via seq_open_private()),
> and freed up on file close (via seq_release_private).
> 
> So it cannot be freed up in the middle of an iteration.

Thank you for the info!!!

OK, for my next stupid question: why is the rcu_dereference(seq->private)
required, as opposed to simply seq->private?

							Thanx, Paul
