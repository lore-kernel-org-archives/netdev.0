From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 22:48:07 +0300
Message-ID: <20120604194806.GB1648@redhat.com>
References: <20120604123738.GA28992@redhat.com>
 <1338815213.2760.1806.camel@edumazet-glaptop>
 <20120604134138.GA29814@redhat.com>
 <1338818501.2760.1821.camel@edumazet-glaptop>
 <20120604141731.GA30226@redhat.com>
 <1338822064.2760.1834.camel@edumazet-glaptop>
 <20120604172030.GA32205@redhat.com>
 <1338831890.2760.1842.camel@edumazet-glaptop>
 <20120604181636.GG32205@redhat.com>
 <1338837842.2760.1883.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128Ab2FDTsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 15:48:30 -0400
Content-Disposition: inline
In-Reply-To: <1338837842.2760.1883.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 09:24:02PM +0200, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 21:16 +0300, Michael S. Tsirkin wrote:
> 
> > Will take a look, thanks.
> > By the way, this comment at build_skb:
> > * @frag_size: size of fragment, or 0 if head was kmalloced
> > 
> > is not very clear to me. Could you clarify what exactly size
> > of fragment means in this context?
> > 
> 
> 
> If your driver did :
> 
> data = kmalloc(100) then you use @frag_size=0, so that build_skb() does
> the ksize(data) to fetch real size (It can depend on slab/slub/sob
> allocator)
> 
> 
> If you used netdev_alloc_frag(128), then you use 128 because there is no
> way build_skb() can guess the size of the fragment. Its also how we
> signal to build_skb() that skb->head_frag is set to 1.
> 
> __netdev_alloc_skb() for example does :
> 
> void *data = netdev_alloc_frag(fragsz);
> skb = build_skb(data, fragsz);
> 

If I do this what will truesize be? 128, no?
