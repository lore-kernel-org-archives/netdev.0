From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: fix overly long udelay()
Date: Fri, 25 Nov 2016 20:56:38 -0500 (EST)
Message-ID: <20161125.205638.2032421932060534687.davem@davemloft.net>
References: <20161124162630.3802535-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbcKZB4n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:56:43 -0500
In-Reply-To: <20161124162630.3802535-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 24 Nov 2016 17:26:22 +0100

> irda_get_mtt() returns a hardcoded '10000' in some cases,
> and with gcc-7, we get a build error because this triggers a
> compile-time check in udelay():
> 
> drivers/net/irda/w83977af_ir.o: In function `w83977af_hard_xmit':
> w83977af_ir.c:(.text.w83977af_hard_xmit+0x14c): undefined reference to `__bad_udelay'
> 
> Older compilers did not run into this because they either did not
> completely inline the irda_get_mtt() or did not consider the
> 10000 value a constant expression.
> 
> The code has been wrong since the start of git history.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
 ...
> @@ -518,7 +518,9 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
>  		
>  		mtt = irda_get_mtt(skb);
>  		pr_debug("%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
> -			if (mtt)
> +			if (mtt > 1000)
> +				mdelay(mtt/1000);
> +			else if (mtt)
>  				udelay(mtt);

I know this isn't caused by you, but wow what is going on with the
indentation here?!?!?
