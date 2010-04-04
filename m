From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [BUG] latest net-next-2.6 doesnt fly
Date: Sun, 4 Apr 2010 18:16:11 +0900
Message-ID: <20100404181542N.fujita.tomonori@lab.ntt.co.jp>
References: <1270200783.1989.4.camel@edumazet-laptop>
	<1270201248.1989.8.camel@edumazet-laptop>
	<1270202304.1989.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	fujita.tomonori@lab.ntt.co.jp
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:40025 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216Ab0DDJQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 05:16:20 -0400
In-Reply-To: <1270202304.1989.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 Apr 2010 11:58:24 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index e19cdae..c6b5206 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1801,7 +1801,7 @@ EXPORT_SYMBOL(netdev_rx_csum_fault);
>   * 2. No high memory really exists on this machine.
>   */
>  
> -static inline int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
> +static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
>  {
>  #ifdef CONFIG_HIGHMEM
>  	int i;
> @@ -1814,6 +1814,8 @@ static inline int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
>  	if (PCI_DMA_BUS_IS_PHYS) {
>  		struct device *pdev = dev->dev.parent;
>  
> +		if (!pdev)
> +			return 0;

Sorry about that and thanks for the fix.

I think, if pdev is null, returning 1 here is safer since the device
doesn't set up dma info properly.

Do you know what device hits this bug? You said that you use bnx2 and
tg3. Both call SET_NETDEV_DEV with pdev->dev. I tested bnx2 and seems
that netdev->dev.parent is set up correctly.
