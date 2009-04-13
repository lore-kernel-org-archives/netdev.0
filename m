From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: iptables very slow after commit
	784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 21:04:13 -0700
Message-ID: <20090413040413.GQ6822@linux.vnet.ibm.com>
References: <20090411174801.GG6822@linux.vnet.ibm.com> <18913.53699.544083.320542@cargo.ozlabs.ibm.com> <20090412173108.GO6822@linux.vnet.ibm.com> <20090412.181330.23529546.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753294AbZDMEEW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090412.181330.23529546.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 12, 2009 at 06:13:30PM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Sun, 12 Apr 2009 10:31:08 -0700
> 
> > On Sun, Apr 12, 2009 at 09:34:27PM +1000, Paul Mackerras wrote:
> >> Paul E. McKenney writes:
> >> 
> >> > If the generic implementation is needed only on !SMP systems, that
> >> > could work.  The architectures I would be worried about include
> >> > powerpc and ia64, which I believe support 32-bit SMP builds.
> >> 
> >> 32-bit powerpc doesn't have 64-bit atomic operations and does support
> >> SMP.
> >> 
> >> What about ARM?  I thought they had 32-bit SMP these days as well.
> > 
> > Some of Steve Hemminger's recent suggestions in this thread seem to me
> > to avoid this whole issue nicely.  But we will see!  ;-)
> 
> I hope so.
> 
> Eventually it seems that all of the older 32-bit SMP platforms
> will be run under a bus having to execute some many "efficient"
> primitives using the "hash table of spinlocks" scheme for
> synchronization.

Or, in some cases, per-CPU locks.  It might also be that 32-bit SMP
systems use stop-the-world approaches.

Or that we get a variant of RCU with shorter grace periods.  I don't
recommend holding your breath, but I have not given up on this.  For one
only slightly crazy example, some of the user-level RCU variants could be
adapted to in-kernel use.  Some of these have sub-microsecond grace-period
latencies, but also have some limitations that would make it difficult
for them to replace RCU wholesale in the Linux kernel.  And it is not
like we are suffering from any lack of distinct RCU implementations in
the Linux kernel just now.  :-/

However, they might be useful in isolated situations.

							Thanx, Paul
