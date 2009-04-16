From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 16:49:55 -0700
Message-ID: <20090416234955.GL6924@linux.vnet.ibm.com>
References: <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, torvalds@linux-foundation.org,
	shemminger@vyatta.com, dada1@cosmosbay.com,
	jeff.chua.linux@gmail.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:53593 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753516AbZDPXt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 19:49:59 -0400
Content-Disposition: inline
In-Reply-To: <20090416.153354.170676392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 03:33:54PM -0700, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 16 Apr 2009 15:11:31 +0200
> 
> > Linus Torvalds wrote:
> >> On Wed, 15 Apr 2009, Stephen Hemminger wrote:
> >>> The counters are the bigger problem, otherwise we could just free
> >>> table
> >>> info via rcu.  Do we really have to support: replace where the counter
> >>> values coming out to user space are always exactly accurate, or is it
> >>> allowed to replace a rule and maybe lose some counter ticks (worst
> >>> case
> >>> NCPU-1).
> >> Why not just read the counters fromt he old one at RCU free time (they
> >> are guaranteed to be stable at that point, since we're all done with
> >> those entries), and apply them at that point to the current setup?
> > 
> > We need the counters immediately to copy them to userspace, so waiting
> > for an asynchronous RCU free is not going to work.
> 
> It just occurred to me that since all netfilter packet handling
> goes through one place, we could have a sort-of "netfilter RCU"
> of sorts to solve this problem.

OK, I am putting one together...

It will be needed sooner or later, though I suspect per-CPU locking
would work fine in this case.

							Thanx, Paul
