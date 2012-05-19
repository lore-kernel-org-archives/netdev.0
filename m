From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tg3: use netdev_alloc_frag() API
Date: Sat, 19 May 2012 09:31:41 +0200
Message-ID: <1337412701.7029.79.camel@edumazet-glaptop>
References: <1337411749.7029.77.camel@edumazet-glaptop>
	 <20120519.031914.1744866102736414778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37373 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613Ab2ESHbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 03:31:45 -0400
Received: by wibhj8 with SMTP id hj8so798804wib.1
        for <netdev@vger.kernel.org>; Sat, 19 May 2012 00:31:44 -0700 (PDT)
In-Reply-To: <20120519.031914.1744866102736414778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-19 at 03:19 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 19 May 2012 09:15:49 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Update our reference driver to use netdev_alloc_frag() API instead of
> > the temporary custom allocator I introduced in commit 8d4057a938
> > (tg3: provide frags as skb head)
> > 
> > This removes the memory leak we had, since we could leak one page at
> > device dismantle.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Hmmm, doesn't apply cleanly to net-next for some reason:
> 
> [davem@drr net-next]$ git am --signoff net-next-tg3-use-netdev_alloc_frag-API.patch 
> Applying: tg3: use netdev_alloc_frag() API
> error: patch failed: drivers/net/ethernet/broadcom/tg3.c:5631
> error: drivers/net/ethernet/broadcom/tg3.c: patch does not apply
> Patch failed at 0001 tg3: use netdev_alloc_frag() API
> When you have resolved this problem run "git am --resolved".
> If you would prefer to skip this patch, instead run "git am --skip".
> To restore the original branch and stop patching run "git am --abort".

Indeed, there is an extra space at the end of one line in my tree... ???

atomic_add((PAGE_SIZE / TG3_FRAGSIZE) - 1, &page->_count); <HERE>

I submit a v2 immediately.

Sorry
