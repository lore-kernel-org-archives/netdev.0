From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_fclone_busy() needs to detect orphaned skb
Date: Thu, 30 Oct 2014 19:59:47 -0400 (EDT)
Message-ID: <20141030.195947.399658939004489177.davem@davemloft.net>
References: <1414690354.9028.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161211AbaJ3X7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:59:50 -0400
In-Reply-To: <1414690354.9028.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Oct 2014 10:32:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Some drivers are unable to perform TX completions in a bound time.
> They instead call skb_orphan()
> 
> Problem is skb_fclone_busy() has to detect this case, otherwise
> we block TCP retransmits and can freeze unlucky tcp sessions on
> mostly idle hosts.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 1f3279ae0c13 ("tcp: avoid retransmits of TCP packets hanging in host queues")

Applied, and queued up for -stable, thanks Eric.

>  This problem is known to hurt users of linux-3.16 kernels used by guests kernels.
>  David, I can provide backports if you want.

Since 3.16 is no longer active, I'll only need to put this into 3.17-stable
which I should be able to handle on my own.

But thanks for offering, sometimes difficult backports take up a lot
of time.
