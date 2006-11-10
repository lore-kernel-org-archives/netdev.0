From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT] mv643xxx_eth_start_xmit oops
Date: Fri, 10 Nov 2006 13:35:55 -0800
Message-ID: <20061110133555.7400e555@freekitty>
References: <20061110191745.GA13783@codepoet.org>
	<20061110115444.07f58e40@freekitty>
	<20061110205327.19468.qmail@farnsworth.org>
	<20061110210343.GA9453@electric-eye.fr.zoreil.com>
	<20061110130715.5e99ce9f@freekitty>
	<20061110213043.GB9453@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27373 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S966111AbWKJVgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 16:36:00 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061110213043.GB9453@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Nov 2006 22:30:43 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > skb_linearize is documented to free skb on failure.
> 
> __skb_linearize
> -> __pskb_pull_tail
>    -> pskb_expand_head
>       [...]
>         data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
>         if (!data)
>                 goto nodata;
>       [...]
> nodata:
>         return -ENOMEM;
> 
> I don't see where the skb is freed on this path.
> 
> Btw, the same __skb_linearize() is followed by a kfree_skb() in
> drivers/net/via-velocity.c since 364c6badde0dd62a0a38e5ed67f85d87d6665780
> 
> I may be wrong but the source code does not seem completely right either.


Your correct, it does leave the skb alone. so it would be a leak.
Better documentation in skb_linearize would help.

-- 
Stephen Hemminger <shemminger@osdl.org>
