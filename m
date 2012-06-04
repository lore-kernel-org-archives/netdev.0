From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 21:24:02 +0200
Message-ID: <1338837842.2760.1883.camel@edumazet-glaptop>
References: <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
	 <20120604141731.GA30226@redhat.com>
	 <1338822064.2760.1834.camel@edumazet-glaptop>
	 <20120604172030.GA32205@redhat.com>
	 <1338831890.2760.1842.camel@edumazet-glaptop>
	 <20120604181636.GG32205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40011 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab2FDTYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:24:07 -0400
Received: by bkcji2 with SMTP id ji2so3928122bkc.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 12:24:06 -0700 (PDT)
In-Reply-To: <20120604181636.GG32205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 21:16 +0300, Michael S. Tsirkin wrote:

> Will take a look, thanks.
> By the way, this comment at build_skb:
> * @frag_size: size of fragment, or 0 if head was kmalloced
> 
> is not very clear to me. Could you clarify what exactly size
> of fragment means in this context?
> 


If your driver did :

data = kmalloc(100) then you use @frag_size=0, so that build_skb() does
the ksize(data) to fetch real size (It can depend on slab/slub/sob
allocator)


If you used netdev_alloc_frag(128), then you use 128 because there is no
way build_skb() can guess the size of the fragment. Its also how we
signal to build_skb() that skb->head_frag is set to 1.

__netdev_alloc_skb() for example does :

void *data = netdev_alloc_frag(fragsz);
skb = build_skb(data, fragsz);
