From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: fib_hash removal
Date: Thu, 15 Mar 2007 08:40:46 +0100
Message-ID: <20070315074046.GA1671@ff.dom.local>
References: <45F87C14.8010404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, tgr@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44760 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933406AbXCOHgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 03:36:31 -0400
Content-Disposition: inline
In-Reply-To: <45F87C14.8010404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14-03-2007 23:49, Patrick McHardy wrote:
...
> I noticed this a couple of times, but didn't manage to look
> into it yet:
> 
> BUG: sleeping function called from invalid context at mm/slab.c:3032
> in_atomic():1, irqs_disabled():0
> no locks held by ip/14309.
> 
> Call Trace:
>  [<ffffffff810956e9>] debug_show_held_locks+0x9/0xb
>  [<ffffffff8100b0b0>] __might_sleep+0xd9/0xdb
>  [<ffffffff8100f745>] __kmalloc_track_caller+0x67/0x10f
>  [<ffffffff810aaff1>] __kzalloc+0x15/0x2f
>  [<ffffffff811fc5a5>] tnode_new+0x55/0x122

tnode_alloc() uses GFP_KERNEL ...

>  [<ffffffff811fcc88>] resize+0x616/0x966
>  [<ffffffff811d2e08>] nlmsg_notify+0x43/0x6f
>  [<ffffffff811fd074>] trie_rebalance+0x9c/0xef
>  [<ffffffff811fd231>] trie_leaf_remove+0x16a/0x1c2

... but we have preempt_disable() here.

Regards,
Jarek P.
