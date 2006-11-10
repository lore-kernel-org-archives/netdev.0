From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT] mv643xxx_eth_start_xmit oops
Date: Fri, 10 Nov 2006 13:07:15 -0800
Message-ID: <20061110130715.5e99ce9f@freekitty>
References: <20061110191745.GA13783@codepoet.org>
	<20061110115444.07f58e40@freekitty>
	<20061110205327.19468.qmail@farnsworth.org>
	<20061110210343.GA9453@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60132 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161497AbWKJVHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 16:07:19 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061110210343.GA9453@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Nov 2006 22:03:43 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Dale Farnsworth <dale@farnsworth.org> :
> [...]
> > Can you provide more detail about the leak?
> 
> +       if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
> +               stats->tx_dropped++;
> +               if (net_ratelimit())
> +                       printk(KERN_DEBUG "%s: failed to linearize tiny "
> +                              "unaligned fragment\n", dev->name);
> +               return NETDEV_TX_OK;
> 
> Missing kfree_skb(skb) before returning NETDEV_TX_OK ?
> 

skb_linearize is documented to free skb on failure.





-- 
Stephen Hemminger <shemminger@osdl.org>
