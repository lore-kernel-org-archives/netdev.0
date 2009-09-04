From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Fri, 4 Sep 2009 13:43:35 -0700
Message-ID: <20090904204335.GG6751@linux.vnet.ibm.com>
References: <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <4AA00400.1030005@gmail.com> <alpine.DEB.1.10.0909031731540.24199@V090114053VZO-1> <20090903231757.GP6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909041140040.9781@V090114053VZO-1>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909041140040.9781@V090114053VZO-1>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2009 at 11:42:17AM -0400, Christoph Lameter wrote:
> On Thu, 3 Sep 2009, Paul E. McKenney wrote:
> 
> > If it were the user of the slab who was invoking some variant of
> > call_rcu(), then I would agree with you.
> 
> The user already has to deal with it as explained by Eric.

I didn't read his email that way.  Perhaps I misinterpreted it.

> > However, call_rcu() is instead being invoked by the slab itself in the
> > case of SLAB_DESTROY_BY_RCU, so that there is no variation in usage.
> > Requiring that the user call rcu_barrier() is asking for subtle bugs.
> > Therefore, the best approach is to have kmem_cache_destroy() handle
> > the RCU cleanup, given that this cleanup is for actions taken by
> > kmem_cache_free(), not by the user.
> 
> The user already has to properly handle barriers and rcu logic in order to
> use objects handled with RCU properly. Moreover the user even has to check
> that the object is not suddenly checked under it. Its already complex.

mm/slab.c has had RCU calls since 2.6.9, so this is not new.

> Guess we are doing this ... Sigh. Are you going to add support other rcu
> versions to slab as well as time permits and as the need arises? Should
> we add you as a maintainer? ;-)

I don't see any point in adding anything resembling SLAB_DESTROY_BY_RCU_BH,
SLAB_DESTROY_BY_RCU_SCHED, or SLAB_DESTROY_BY_SRCU unless and until
someone needs it.  And I most especially don't see the point of adding
(say) SLAB_DESTROY_BY_RCU_BH_SCHED until someone convinces me of the
need for it.  I would prefer to put the energy into further streamlining
the underlying RCU implementation, maybe someday collapsing RCU-BH back
into RCU.  ;-)

We have gotten along fine with only SLAB_DESTROY_BY_RCU for almost
five years, so I think we are plenty fine with what we have.  So, as
you say, "as the need arises".

I don't see any more need to add me as maintainer of slab and friends
than of btrfs, netfilter, selinux, decnet, afs, wireless, or any of a
number of other subsystems that use RCU.

							Thanx, Paul
