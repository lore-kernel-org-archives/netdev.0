From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: add batch ability to fq_codel_drop()
Date: Mon, 02 May 2016 09:12:51 -0700
Message-ID: <1462205571.5535.253.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160502094954.24cc9549@redhat.com>
	 <1462199668.5535.239.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160502180036.25bebdfe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>,
	Jonathan Morton <chromatix99@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34444 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbcEBQMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:12:54 -0400
Received: by mail-pa0-f48.google.com with SMTP id r5so77487103pag.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:12:54 -0700 (PDT)
In-Reply-To: <20160502180036.25bebdfe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-02 at 18:00 +0200, Jesper Dangaard Brouer wrote:

> It is not that complicated, inside kfree_skb_list(), we just call
> skb_release_all(skb) on each SKB first, and then bulk free the SKB's
> themselves in the end.  Example see, _kfree_skb_defer().
> 
> The question is where to store the SKB array needed by kmem_cache_free_bulk.
> 
> The easy option is just to use the stack of kfree_skb_list(), but we
> have to be careful about the stack size, it might not be so good
> because skb_release_all() can be deep and via skb_release_data() invoke
> kfree_skb_list() a second time.
> 

It sounds you are reinventing the wheel ;)

If drivers use napi_consume_skb(), qdisc should be able to use it the
same, since BH are disabled in their ->enqueue()/->dequeue() handlers.

This would be a separate patch of course.

This fq_codel fix might need to be backported.
