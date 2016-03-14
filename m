From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/7] net: bulk alloc and reuse of SKBs in NAPI
 context
Date: Mon, 14 Mar 2016 07:55:37 +0100
Message-ID: <20160314075537.502378fc@redhat.com>
References: <20160304130054.32651.51776.stgit@firesoul>
	<20160304130143.32651.33813.stgit@firesoul>
	<CALYk33gF_qLuBpYLX4xLpekVJX9okUqaxdMnFgWpyDrRwu5e5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	gerlitz.or@gmail.com, brouer@redhat.com
To: Rana Shahout <rana.shahot@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35081 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933408AbcCNGzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 02:55:43 -0400
In-Reply-To: <CALYk33gF_qLuBpYLX4xLpekVJX9okUqaxdMnFgWpyDrRwu5e5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Mar 2016 16:06:17 +0200
Rana Shahout <rana.shahot@gmail.com> wrote:

> On Fri, Mar 4, 2016 at 3:01 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> 
> >  /* build_skb() is wrapper over __build_skb(), that specifically
> >   * takes care of skb->head and skb->pfmemalloc
> >   * This means that if @frag_size is not zero, then @data must be backed
> > @@ -490,8 +500,8 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
> >
> >         len += NET_SKB_PAD + NET_IP_ALIGN;
> >
> > -       if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> > -           (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
> > +       if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> > +                    (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA)))) {  
> 
> Why unlikely? I know it is better for the common case where most
> likely linear SKBs are << SKB_WITH_OVERHEAD(PAGE_SIZE)), but what
> about the case of Hardware LRO,  where linear SKB is likely to be >>
> SKB_WITH_OVERHEAD(PAGE_SIZE)).

You said it yourself, this is better for the common case.  With
unlikely() I'm asking the compiler to layout the code for the common
case.  This helps the CPU instruction cache prefetcher.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
