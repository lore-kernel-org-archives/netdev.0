From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Wed, 20 Apr 2011 09:05:43 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1104200904440.8634@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>  <1303279470.2756.17.camel@edumazet-laptop>  <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
 <1303286998.3186.18.camel@edumazet-laptop>  <1303290464.3186.32.camel@edumazet-laptop> <1303293765.3186.74.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.prem.mail.ac4.yahoo.com ([76.13.13.47]:22802 "HELO
	smtp108.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752156Ab1DTOFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 10:05:47 -0400
In-Reply-To: <1303293765.3186.74.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Apr 2011, Eric Dumazet wrote:

> > Then, just disable SLUB_CMPXCHG_DOUBLE if KMEMCHECK is defined, as I did in my first patch.

Ok your first patch seems to be the sanest approach.

>  {
> @@ -1889,16 +1895,18 @@ static __always_inline void *slab_alloc(struct kmem_cache *s,
>  	struct kmem_cache_cpu *c;
>  #ifdef CONFIG_CMPXCHG_LOCAL
>  	unsigned long tid;
> -#else
> +#endif
> +#ifdef MASK_IRQ_IN_SLAB_ALLOC
>  	unsigned long flags;
>  #endif
>

Yea well that does not bring us much.
