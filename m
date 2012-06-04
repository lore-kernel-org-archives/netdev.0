From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 4 Jun 2012 22:56:42 +0300
Message-ID: <20120604195642.GA2069@redhat.com>
References: <1337276056.3403.37.camel@edumazet-glaptop>
 <20120604123738.GA28992@redhat.com>
 <1338815213.2760.1806.camel@edumazet-glaptop>
 <20120604134138.GA29814@redhat.com>
 <1338818501.2760.1821.camel@edumazet-glaptop>
 <20120604141731.GA30226@redhat.com>
 <1338822064.2760.1834.camel@edumazet-glaptop>
 <20120604181623.GF32205@redhat.com>
 <1338838185.2760.1899.camel@edumazet-glaptop>
 <20120604194330.GA1648@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10871 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568Ab2FDT5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 15:57:06 -0400
Content-Disposition: inline
In-Reply-To: <20120604194330.GA1648@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 04, 2012 at 10:43:30PM +0300, Michael S. Tsirkin wrote:
> On Mon, Jun 04, 2012 at 09:29:45PM +0200, Eric Dumazet wrote:
> > On Mon, 2012-06-04 at 21:16 +0300, Michael S. Tsirkin wrote:
> > 
> > > Yes but if a tcp socket then hangs on, on one of the fragments,
> > > while the other has been freed, the whole page is still
> > > never reused, right?
> > > 
> > > Doesn't this mean truesize should be 4K?
> > > 
> > 
> > Yes, or more exactly PAGE_SIZE, but then performance would really go
> > down on machines with 64KB pages.
> > Maybe we should make the whole frag
> > head idea enabled only for PAGE_SIZE=4096.
> > 
> > Not sure we want to track precise truesize, as the minimum truesize is
> > SKB_DATA_ALIGN(length + NET_SKB_PAD) + SKB_DATA_ALIGN(sizeof(struct
> > skb_shared_info)) (64 + 64 + 320) = 448
> > 
> > Its not like buggy drivers that used truesize = length
> > 
> > 
> 
> Interesting. But where's the threshold?

And just to explain why I'm asking, if it's OK to
declare 2K when you use 4K, we can do (effectively):

+       skb->truesize += PAGE_SIZE * nfrags;
-       skb->truesize += min(1500, skb->data_len);

which means with 1500 byte packets we can use
as much memory as we did before
4b727361f0bc7ee7378298941066d8aa15023ffb

> -- 
> MST
