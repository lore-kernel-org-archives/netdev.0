From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: nf_conntrack_alloc() fixes
Date: Thu, 16 Jul 2009 14:05:02 +0200
Message-ID: <4A5F176E.7010508@trash.net>
References: <20090707.191424.167842005.davem@davemloft.net>	<4A5441A0.3050504@gmail.com>	<4A5581C5.5070409@gmail.com> <20090711.202727.18146102.davem@davemloft.net> <4A598BAB.6030400@gmail.com> <4A5DCB7C.9000502@gmail.com> <4A5DF5B4.5090809@trash.net> <4A5E33D9.2030602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54556 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbZGPMFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 08:05:11 -0400
In-Reply-To: <4A5E33D9.2030602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH] net: nf_conntrack_alloc() fixes
> 
> When a slab cache uses SLAB_DESTROY_BY_RCU, we must be careful when allocating
> objects, since slab allocator could give a freed object still used by lockless
> readers.
> 
> In particular, nf_conntrack RCU lookups rely on ct->tuplehash[xxx].hnnode.next
> being always valid (ie containing a valid 'nulls' value, or a valid pointer to next
> object in hash chain.)
> 
> kmem_cache_zalloc() setups object with NULL values, but a NULL value is not valid
> for ct->tuplehash[xxx].hnnode.next.
> 
> Fix is to call kmem_cache_alloc() and do the zeroing ourself.
> 
> As spotted by Patrick, we also need to make sure lookup keys are committed to
> memory before setting refcount to 1, or a lockless reader could get a reference
> on the old version of the object. Its key re-check could then pass the barrier. 

Looks good to me. Applied, thanks Eric. I'll push it to -stable
with the other fixes in a couple of days.
