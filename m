From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 3 Sep 2009 13:38:50 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>  <alpine.DEB.1.10.0908121820410.3257@gentwo.org>  <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>  <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>
 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>  <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>  <4A9EEF07.5070800@gmail.com>  <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>  <4A9F1620.2080105@gmail.com>
 <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A9FCDC6.3060003@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 Sep 2009, Eric Dumazet wrote:

> Christoph Lameter a ?crit :
> > On Thu, 3 Sep 2009, Eric Dumazet wrote:
> >
> >> on a SLAB_DESTROY_BY_RCU cache, there is no need to try to optimize this
> >> rcu_barrier() call, unless we want superfast reboot/halt sequences...
> >
> > I stilll think that the action to quiesce rcu is something that the caller
> > of kmem_cache_destroy must take care of.
>
> Do you mean :
>
> if (kmem_cache_shrink(s) == 0) {
> 	rcu_barrier();
> 	kmem_cache_destroy_no_rcu_barrier(s);
> } else {
> 	kmem_cache_destroy_with_rcu_barrier_because_SLAB_DESTROY_BY_RCU_cache(s);
> }
>
> What would be the point ?

The above is port of slub?

I mean that (in this case) the net subsystem would have to deal with RCU quietness
before disposing of the slab cache. There may be multiple ways of dealing
with RCU. The RCU barrier may be unnecessary for future uses. Typically
one would expect that all deferred handling of structures must be complete
for correctness before disposing of the whole cache.

> [PATCH] slub: fix slab_pad_check()

Acked-by: Christoph Lameter <cl@linux-foundation.org>
