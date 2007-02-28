From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Run-time kfree check for correct cache [was Re: [NET]: Fix kfree(skb)]
Date: Wed, 28 Feb 2007 11:10:54 +0100
Message-ID: <200702281110.54619.dada1@cosmosbay.com>
References: <20070227.100052.59655152.davem@davemloft.net> <20070227.102452.102574618.davem@davemloft.net> <20070228090258.GA28336@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, paul.moore@hp.com,
	kaber@trash.net, netdev@vger.kernel.org, acme@ghostprotocols.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:38984 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124AbXB1KLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 05:11:06 -0500
In-Reply-To: <20070228090258.GA28336@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 February 2007 10:02, Evgeniy Polyakov wrote:
> Attached patch detects in run-time things like:
> skb = alloc_skb();
> kfree(skb);
>
> where provided to kfree pointer does not belong to kmalloc caches.
> It is turned on when slab debug config option is enabled.
>
> When problem is detected, following warning is printed with hint to
> what cache/function should be used instead:

It would be less expensive to add a flag 
#define SLAB_KFREE_NOWARNING 0x00200000UL

And OR this flags into cs->flags of all standard caches created by 
kmem_cache_init() from malloc_sizes[]/cache_names[]

kfree() would then just test this flag.

