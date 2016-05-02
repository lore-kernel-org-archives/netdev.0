From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: add batch ability to fq_codel_drop()
Date: Mon, 02 May 2016 07:34:28 -0700
Message-ID: <1462199668.5535.239.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160502094954.24cc9549@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>,
	Jonathan Morton <chromatix99@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33320 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131AbcEBOed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 10:34:33 -0400
Received: by mail-yw0-f172.google.com with SMTP id t10so290753764ywa.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 07:34:32 -0700 (PDT)
In-Reply-To: <20160502094954.24cc9549@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-02 at 09:49 +0200, Jesper Dangaard Brouer wrote:

> What about using bulk free of SKBs here?
> 
> There is a very high probability that we are hitting SLUB slowpath,
> which involves an expensive locked cmpxchg_double per packet.  Instead
> we can amortize this cost via kmem_cache_free_bulk().
> 
> Maybe extend kfree_skb_list() to hide the slab/kmem_cache call?

Sounds tricky, because of skb destructors. skb are complex objects.

For each skb, need to free the frags, skb->head, and skb.
