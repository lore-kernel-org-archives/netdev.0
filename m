From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] fq_codel: add batch ability to fq_codel_drop()
Date: Mon, 2 May 2016 19:15:43 +0200
Message-ID: <20160502191543.170fc046@redhat.com>
References: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160502094954.24cc9549@redhat.com>
	<1462199668.5535.239.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160502180036.25bebdfe@redhat.com>
	<1462205571.5535.253.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>,
	Jonathan Morton <chromatix99@gmail.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbcEBRPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 13:15:48 -0400
In-Reply-To: <1462205571.5535.253.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 May 2016 09:12:51 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2016-05-02 at 18:00 +0200, Jesper Dangaard Brouer wrote:
> 
> > It is not that complicated, inside kfree_skb_list(), we just call
> > skb_release_all(skb) on each SKB first, and then bulk free the SKB's
> > themselves in the end.  Example see, _kfree_skb_defer().
> > 
> > The question is where to store the SKB array needed by kmem_cache_free_bulk.
> > 
> > The easy option is just to use the stack of kfree_skb_list(), but we
> > have to be careful about the stack size, it might not be so good
> > because skb_release_all() can be deep and via skb_release_data() invoke
> > kfree_skb_list() a second time.
> >   
> 
> It sounds you are reinventing the wheel ;)
> 
> If drivers use napi_consume_skb(), qdisc should be able to use it the
> same, since BH are disabled in their ->enqueue()/->dequeue() handlers.

Oh, yes. That is true, we can just use napi_consume_skb().  Should we
have a napi_kfree_skb(), to get the trace_kfree_skb() correct?

> This would be a separate patch of course.
> 
> This fq_codel fix might need to be backported.

Agreed.  I ACK your patch.

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
