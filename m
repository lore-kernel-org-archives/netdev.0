From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Fri, 4 Sep 2009 11:33:26 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909041130030.9781@V090114053VZO-1>
References: <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1>
 <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <20090903174435.GF6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909031736340.24199@V090114053VZO-1> <20090903220300.GN6761@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933866AbZIDS4r@vger.kernel.org>
In-Reply-To: <20090903220300.GN6761@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 Sep 2009, Paul E. McKenney wrote:

> > You need to ensure that no objects are in use before destroying a slab. In
> > case of DESTROY_BY_RCU you must ensure that there are no potential
> > readers. So use a suitable rcu barrier or something else like a
> > synchronize_rcu...
>
> If by "you must ensure" you mean "kmem_cache_destroy must ensure", then
> we are in complete agreement.  Otherwise, not a chance.

Well then we are going down to a crappy interface and mixing rcu with slab
semantics. More bugs to follow in the future.

> If by "must ensure that no objects are in use", you mean "must have
> no further references to them", then we are in agreement.  And in my
> scenario above, it is not the -user- who later references the memory,
> but rather the slab code itself.

The slab code itself is not referencing the later memory with my patch. It
can only be the user.

> Put the rcu_barrier() in kmem_cache_free().  Please.

Guess we are doing this ... Sigh. Are you going to add support other rcu
versions to slab as well as time permits and as the need arises? Should we
add you as a maintainer? ;-)
