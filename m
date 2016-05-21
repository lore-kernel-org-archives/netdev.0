From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sat, 21 May 2016 21:47:33 +0200
Message-ID: <20160521194733.GA30557@electric-eye.fr.zoreil.com>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	David Miller <davem@davemloft.net>, wxt@rock-chips.com,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org
To: Shuyu Wei <wsy2220@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52720 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcEUTsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 15:48:08 -0400
Content-Disposition: inline
In-Reply-To: <20160521160910.GA14945@debian-dorm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shuyu Wei <wsy2220@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index a3a9392..c2447b0 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -686,6 +686,9 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
>  
>         skb_tx_timestamp(skb);
>  
> +       /* Make sure timestamp is set */
> +       smp_wmb();

Should be dma_wmb() (see davem's message).

It's completely unrelated to SMP.

-- 
Ueimor
