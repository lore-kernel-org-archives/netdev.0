From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/5] slab.c: remove branch hint
Date: Mon, 30 Nov 2009 10:09:39 -0600 (CST)
Message-ID: <alpine.DEB.2.00.0911300926150.14098@router.home>
References: <cover.1259059549.git.tim@klingt.org> <4B0BBBA8.2090604@klingt.org>  <20091124112058.GA23765@elte.hu> <84144f020911240328l3d36d347o6c91b2b1a0f50f2a@mail.gmail.com> <4B125CC2.7000202@klingt.org> <4B138AC2.7080008@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tim Blechmann <tim@klingt.org>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752965AbZK3QKH@vger.kernel.org>
In-Reply-To: <4B138AC2.7080008@cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Nov 2009, Pekka Enberg wrote:

> OK, so it's the generic alloc_skb() function that keeps hitting
> kmem_cache_alloc_node() with "-1". Christoph, are you okay with removing the
> unlikely() annotation from __cache_alloc_node()?

Yes. Lets look for other cases in the allocators too.
kmem_cache_alloc_node used to be mainly used for off node allocations but
the network alloc_skb() case shows that this is changing now.

I hope the users of kmem_cache_alloc_node() realize that using -1 is not
equivalent to kmem_cache_alloc(). kmem_cache_alloc follows numa policies
for memory allocations. kmem_cache_alloc_node() does not.
