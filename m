From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] slub: Fix kmem_cache_destroy() with SLAB_DESTROY_BY_RCU
Date: Thu, 3 Sep 2009 22:48:10 +0300
Message-ID: <84144f020909031248s56c16205j7992930c413b1bbe@mail.gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>
	 <4A9EEF07.5070800@gmail.com>
	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
	 <4A9F1620.2080105@gmail.com>
	 <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>
	 <4A9F7283.1090306@gmail.com>
	 <84144f020909030051u6cf6ae01he25c268f718ff3af@mail.gmail.com>
	 <alpine.DEB.1.10.0909031246010.27903@V090114053VZO-1>
	 <84144f020909030705x7909cf07w7ea0d3662a66c5cc@mail.gmail.com>
	 <4A9FD047.9000002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com, "stable@kernel.org" <stable@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756238AbZICTsM@vger.kernel.org>
In-Reply-To: <4A9FD047.9000002@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2009 at 5:18 PM, Eric Dumazet<eric.dumazet@gmail.com> wrote:
> Here is the second patch (RCU thing). Stable candidate
>
> [PATCH] slub: Fix kmem_cache_destroy() with SLAB_DESTROY_BY_RCU
>
> kmem_cache_destroy() should call rcu_barrier() *after* kmem_cache_close()
> and *before* sysfs_slab_remove() or risk rcu_free_slab()
> being called after kmem_cache is deleted (kfreed).
>
> rmmod nf_conntrack can crash the machine because it has to
> kmem_cache_destroy() a SLAB_DESTROY_BY_RCU enabled cache.

Do we have a bugzilla URL for this?

> Reported-by: Zdenek Kabelac <zdenek.kabelac@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

OK, this is in for-next now and queued for 2.6.31. If you guys want to
fix this in a different way, lets do that in 2.6.32.

                        Pekka
