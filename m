From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Wed, 14 Aug 2013 21:58:29 +0200
Message-ID: <20130814195829.GA1613@electric-eye.fr.zoreil.com>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com>
 <20130813222038.GC5635@electric-eye.fr.zoreil.com>
 <3465288.NFVErF5E7l@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52217 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932956Ab3HNT6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 15:58:39 -0400
Content-Disposition: inline
In-Reply-To: <3465288.NFVErF5E7l@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> Heh, I forgot about that case. Fixed it in the below patch. By the way,
> have you observed similar behavior on other hardware?

Notwithstanding really old PCI adapters - sometimes - none that I remember of.

[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index b5eb419..d367763 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1897,12 +1897,19 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>  			     void *p)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
> +	char *bytes = p;
> +	int i;
>  
>  	if (regs->len > R8169_REGS_SIZE)
>  		regs->len = R8169_REGS_SIZE;
>  
>  	rtl_lock_work(tp);
> -	memcpy_fromio(p, tp->mmio_addr, regs->len);
> +	if (regs->len >= 4) {
> +		for (i = 0; i < regs->len - 4; i += 4)
> +			memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
> +	}
> +	if (i < regs->len)

Comparison with random stack stuff when regs->len < 4. :o/

-- 
Ueimor
