From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 19 Apr 2011 12:10:40 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1104191210011.17888@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop> <1303183217.4152.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.prem.mail.ac4.yahoo.com ([76.13.13.46]:48646 "HELO
	smtp107.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753523Ab1DSRKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 13:10:45 -0400
In-Reply-To: <1303183217.4152.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Apr 2011, Eric Dumazet wrote:

>  	}
>  }
>
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#if defined(CONFIG_CMPXCHG_LOCAL) && \
> +	!defined(CONFIG_KMEMCHECK) && !defined(DEBUG_PAGEALLOC)
> +#define SLUB_USE_CMPXCHG_DOUBLE
> +#endif
> +
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  #ifdef CONFIG_PREEMPT
>  /*

Ugg.. Isnt there some way to indicate to kmemcheck that a speculative
access is occurring?
