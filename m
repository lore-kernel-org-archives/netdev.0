From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Mon, 9 May 2011 23:06:12 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1105092305260.7275@tiger>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>  <1303279470.2756.17.camel@edumazet-laptop>  <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
 <1303286998.3186.18.camel@edumazet-laptop>  <1303290464.3186.32.camel@edumazet-laptop>  <1303293765.3186.74.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200904440.8634@router.home>  <1303309591.3186.84.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200942020.9266@router.home>
 <1303311687.3186.100.camel@edumazet-laptop> <alpine.DEB.2.00.1105092241390.6784@tiger> <alpine.DEB.2.00.1105091502260.26839@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filtteri6.pp.htv.fi ([213.243.153.189]:47642 "EHLO
	filtteri6.pp.htv.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab1EIUOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 16:14:05 -0400
In-Reply-To: <alpine.DEB.2.00.1105091502260.26839@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 May 2011, Christoph Lameter wrote:
> There is still an issue and now you can no longer fix the thing through
> CONFIG_CMPXCHG_LOCAL.
>
> It needs to be legal for slub to deref the counter even if the object has
> been freed.

We can use kmemcheck_mark_initialized() for that.
