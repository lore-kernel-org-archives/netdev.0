From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Fri, 4 Sep 2009 11:42:17 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909041140040.9781@V090114053VZO-1>
References: <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1>
 <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <4AA00400.1030005@gmail.com> <alpine.DEB.1.10.0909031731540.24199@V090114053VZO-1> <20090903231757.GP6761@linux.vnet.ibm.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090903231757.GP6761@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 Sep 2009, Paul E. McKenney wrote:

> If it were the user of the slab who was invoking some variant of
> call_rcu(), then I would agree with you.

The user already has to deal with it as explained by Eric.

> However, call_rcu() is instead being invoked by the slab itself in the
> case of SLAB_DESTROY_BY_RCU, so that there is no variation in usage.
> Requiring that the user call rcu_barrier() is asking for subtle bugs.
> Therefore, the best approach is to have kmem_cache_destroy() handle
> the RCU cleanup, given that this cleanup is for actions taken by
> kmem_cache_free(), not by the user.

The user already has to properly handle barriers and rcu logic in order to
use objects handled with RCU properly. Moreover the user even has to check
that the object is not suddenly checked under it. Its already complex.

