From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 22:05:17 +0200
Message-ID: <1338840317.2760.1952.camel@edumazet-glaptop>
References: <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
	 <20120604141731.GA30226@redhat.com>
	 <1338822064.2760.1834.camel@edumazet-glaptop>
	 <20120604181623.GF32205@redhat.com>
	 <1338838185.2760.1899.camel@edumazet-glaptop>
	 <20120604194330.GA1648@redhat.com>  <20120604195642.GA2069@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53118 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab2FDUFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 16:05:22 -0400
Received: by bkcji2 with SMTP id ji2so3963520bkc.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 13:05:21 -0700 (PDT)
In-Reply-To: <20120604195642.GA2069@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 22:56 +0300, Michael S. Tsirkin wrote:

> And just to explain why I'm asking, if it's OK to
> declare 2K when you use 4K, we can do (effectively):
> 
> +       skb->truesize += PAGE_SIZE * nfrags;
> -       skb->truesize += min(1500, skb->data_len);
> 
> which means with 1500 byte packets we can use
> as much memory as we did before
> 4b727361f0bc7ee7378298941066d8aa15023ffb
> 

How are you sure data_len is >= 1500 ?

If you know that you use a full page for a fragment, then PAGE_SIZE is
better than 1500


If you share a page with 2/4 frames (But not one hundred), you can
assume risk of underestimation is really low.
