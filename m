From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: dn_route.c momentarily exiting RCU read-side critical section
Date: Mon, 29 Oct 2007 14:15:40 -0700
Message-ID: <20071029211540.GA12893@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SteveW@ACM.org, davem@davemloft.net, dipankar@in.ibm.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:42405 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbXJ2VPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 17:15:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

net/decnet/dn_route.c in dn_rt_cache_get_next() is as follows:

static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_route *rt)
{
	struct dn_rt_cache_iter_state *s = rcu_dereference(seq->private);

	rt = rt->u.dst.dn_next;
	while(!rt) {
		rcu_read_unlock_bh();
		if (--s->bucket < 0)
			break;

...  But what happens if seq->private is freed up right here?
...  Or what prevents this from happening?

		rcu_read_lock_bh();
		rt = dn_rt_hash_table[s->bucket].chain;
	}
	return rt;
}

Similar code is in rt_cache_get_next().

So, what am I missing here?

						Thanx, Paul
