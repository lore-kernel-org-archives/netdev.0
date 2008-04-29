From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bug 10575] New: WARNING: at mm/slub.c:2444
Date: Tue, 29 Apr 2008 16:00:06 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804291551410.15273@schroedinger.engr.sgi.com>
References: <bug-10575-27@http.bugzilla.kernel.org/>
 <20080429082231.2c5470ff.akpm@linux-foundation.org> <481773A6.5050507@trash.net>
 <20080429123741.bce81cf8.akpm@linux-foundation.org> <48177EB2.2070309@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, htmldeveloper@gmail.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:56721 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751974AbYD2XAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 19:00:08 -0400
In-Reply-To: <48177EB2.2070309@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Apr 2008, Pekka Enberg wrote:

> Well, it's obviously nf_conntrack_cachep but this is the second time I see the
> SLUB WARN_ON trigger but can't find anything wrong with the code. Christoph,
> if you look at nf_conntrack_cleanup() in net/netfilter/nf_conntrack_core.c:
> 
>  i_see_dead_people:
>         nf_conntrack_flush();
>         if (atomic_read(&nf_conntrack_count) != 0) {
>                 schedule();
>                 goto i_see_dead_people;
>         }

And we are sure that no additional items are allocatable after this?

>         ct = kmem_cache_zalloc(nf_conntrack_cachep, GFP_ATOMIC);
> 
> So I don't see how we can call kmem_cache_destroy() with unfree'd objects in
> it... Can you take a look at this?

Nothing jumps out but then there are numerous components involved.

> And oh, Peter, if you can trigger this with mainline, please do post the oops.
> I should give us better information what's happening.

The new diagnostics should give us a lot more data to go on. Make sure you 
run with "slub_debug" as a kernel parameter or SLUB_DEBUG_ON configured.

The dump will include the time and place when the remaining objects were 
allocated which should resolve this issue.

