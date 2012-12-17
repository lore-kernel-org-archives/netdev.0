From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: openconnect triggers soft lockup in __skb_get_rxhash
Date: Mon, 17 Dec 2012 10:11:21 +0200
Message-ID: <20121217081121.GA24173@shutemov.name>
References: <20121217005616.GA23029@shutemov.name>
 <20121216.172214.687979484434537200.davem@davemloft.net>
 <20121217014631.GA23101@shutemov.name>
 <1355719589.10504.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, maxk@qti.qualcomm.com,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shutemov.name ([204.155.152.216]:37652 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab2LQIKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 03:10:39 -0500
Content-Disposition: inline
In-Reply-To: <1355719589.10504.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2012 at 08:46:29PM -0800, Eric Dumazet wrote:
> On Mon, 2012-12-17 at 03:46 +0200, Kirill A. Shutemov wrote:
> > On Sun, Dec 16, 2012 at 05:22:14PM -0800, David Miller wrote:
> > > 
> > > Already fixed in Linus's tree by:
> > > 
> > > From 499744209b2cbca66c42119226e5470da3bb7040 Mon Sep 17 00:00:00 2001
> > 
> > No, it's not. I use up-to-date (2a74dbb) Linus tree with the patch in and
> > still see the issue.
> > 
> 
> Coud you try the following one liner ?

Works for me. So far no problems.

Reported-and-tested-by: Kirill A. Shutemov <kirill@shutemov.name>

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 255a9f5..173acf5 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1199,6 +1199,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>  	}
>  
> +	skb_reset_network_header(skb);
>  	rxhash = skb_get_rxhash(skb);
>  	netif_rx_ni(skb);
>  
> 
> 

-- 
 Kirill A. Shutemov
