From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 21:16:24 +0300
Message-ID: <20120604181623.GF32205@redhat.com>
References: <1337272404.3403.18.camel@edumazet-glaptop>
 <20120517164016.GL14498@1wt.eu>
 <1337273387.3403.24.camel@edumazet-glaptop>
 <1337276056.3403.37.camel@edumazet-glaptop>
 <20120604123738.GA28992@redhat.com>
 <1338815213.2760.1806.camel@edumazet-glaptop>
 <20120604134138.GA29814@redhat.com>
 <1338818501.2760.1821.camel@edumazet-glaptop>
 <20120604141731.GA30226@redhat.com>
 <1338822064.2760.1834.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087Ab2FDSQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 14:16:51 -0400
Content-Disposition: inline
In-Reply-To: <1338822064.2760.1834.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 05:01:04PM +0200, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 17:17 +0300, Michael S. Tsirkin wrote:
> 
> > bnx2 and tg3 both do skb_reserve of at least NET_SKB_PAD
> > after build_skb. You are saying it's not a must?
> > 
> 
> 32 would be the minimum. NETS_SKB_PAD is using a cache line (64 bytes
> on most x86 current cpus) to avoid using half a cache line.
> 
> > Hmm so maybe we should teach the hypervisor to write data
> > out at an offset. Interesting.
> > 
> > Another question is about very small packets truesize.
> > build_skb sets truesize to frag_size but isn't
> > this too small? We keep the whole page around, no?
> 
> We keep one page per cpu, at most.
> 
> For example on MTU=1500 and PAGE_SIZE=4096, one page is splitted into
> two fragments, of 1500 + NET_SKB_PAD + align(shared_info), so its good
> enough (this is very close from 2048 'truesize')

Yes but if a tcp socket then hangs on, on one of the fragments,
while the other has been freed, the whole page is still
never reused, right?

Doesn't this mean truesize should be 4K?

-- 
MST
