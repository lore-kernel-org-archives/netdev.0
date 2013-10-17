From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: refactor sk_page_frag_refill()
Date: Thu, 17 Oct 2013 15:46:25 -0400 (EDT)
Message-ID: <20131017.154625.1687353288700164892.davem@davemloft.net>
References: <CANJ5vPJpVfDjaC8JauGYu=Qe4ZshqmBMkCbB1cru-xAfa7K1+g@mail.gmail.com>
	<1381623952.3392.25.camel@edumazet-glaptop.roam.corp.google.com>
	<1381639591.3392.31.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, dborkman@redhat.com, netdev@vger.kernel.org,
	ffusco@redhat.com, ycheng@google.com, ncardwell@google.com,
	digitaleric@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758233Ab3JQTq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:46:28 -0400
In-Reply-To: <1381639591.3392.31.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 12 Oct 2013 21:46:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While working on virtio_net new allocation strategy to increase
> payload/truesize ratio, we found that refactoring sk_page_frag_refill()
> was needed.
> 
> This patch splits sk_page_frag_refill() into two parts, adding
> page_frag_refill() which can be used without a socket.
> 
> While we are at it, add a minimum frag size of 32 for
> sk_page_frag_refill()
> 
> Michael will either use netdev_alloc_frag() from softirq context,
> or page_frag_refill() from process context in refill_work() (GFP_KERNEL
> allocations)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Please rename this to something like "skb_page_frag_refill" so that it
is clear that this is a networking interface.

Thanks Eric.
