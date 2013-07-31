From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Tue, 30 Jul 2013 19:11:38 -0700 (PDT)
Message-ID: <20130730.191138.420648092010563209.davem@davemloft.net>
References: <87y58pva88.fsf@canonical.com>
	<1375111804.10515.1.camel@edumazet-glaptop>
	<1375118644.10515.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luis.henriques@canonical.com, bhutchings@solarflare.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org, jcliburn@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab3GaCLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:11:42 -0400
In-Reply-To: <1375118644.10515.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Jul 2013 10:24:04 -0700

> [PATCH] atl1c: use custom skb allocator
> 
> We had reports ( https://bugzilla.kernel.org/show_bug.cgi?id=54021 )
> that using high order pages for skb allocations is problematic for atl1c
> 
> We do not know exactly what the problem is, but we suspect that crossing
> 4K pages is not well supported by this hardware.
> 
> Use a custom allocator, using page allocator and 2K fragments for
> optimal stack behavior. We might make this allocator generic
> in future kernels.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Theoretically we'll still potentially hit this with > PAGE_SIZE
MTUs....

But whatever, this is a step in the positive direction so applied
and queued up for -stable, thanks Eric!
