From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 15:06:53 +0200
Message-ID: <1338815213.2760.1806.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
	 <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu>
	 <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55170 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab2FDNG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 09:06:59 -0400
Received: by eeit10 with SMTP id t10so1521038eei.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 06:06:58 -0700 (PDT)
In-Reply-To: <20120604123738.GA28992@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 15:37 +0300, Michael S. Tsirkin wrote:
> On Thu, May 17, 2012 at 07:34:16PM +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Please note I havent tested yet this patch, lacking hardware for this.
> > 
> > (tg3/bnx2/bnx2x use build_skb, r8169 does a copy of incoming frames,
> > ixgbe uses fragments...)
> 
> virtio-net uses netdev_alloc_skb but maybe it should call
> build_skb instead?
> 
> Also, it's not uncommon for drivers to copy short packets out to be able
> to reuse pages.  virtio does this but I am guessing the logic is not
> really virtio specific.
> 
> We could do
> 	if (len < GOOD_COPY_LEN)
> 		netdev_alloc_skb
> 		memmov
> 	else
> 		build_skb
> 
> but maybe it makes sense to put this logic in build_skb?
> 
> 

I am not sure to understand the question.

If virtio-net uses netdev_alloc_skb(), all is good, you have nothing to
change.

build_skb() is for drivers that allocate the memory to hold frame, and
wait for NIC completion before allocating/populating the skb itself.
