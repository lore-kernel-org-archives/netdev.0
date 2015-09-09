From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH net-next 1/1] net: fec: add netif status check before
 set mac address
Date: Wed, 09 Sep 2015 11:14:17 +0200
Message-ID: <1441790057.9583.7.camel@pengutronix.de>
References: <1441766567-30689-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53213 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbbIIJOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 05:14:23 -0400
In-Reply-To: <1441766567-30689-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, den 09.09.2015, 10:42 +0800 schrieb Fugang Duan:
> There exist one issue by below case that case system hang:
> ifconfig eth0 down
> ifconfig eth0 hw ether 00:10:19:19:81:19
> 
> After eth0 down, all fec clocks are gated off. In the .fec_set_mac_address()
> function, it will set new MAC address to registers, which causes system hang.
> 
> So it needs to add netif status check to avoid registers access when clocks are
> gated off. Until eth0 up the new MAC address are wrote into related registers.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 91925e3..cd09dbb 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3029,6 +3029,9 @@ fec_set_mac_address(struct net_device *ndev, void *p)
>  		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
>  	}
>  
> +	if (!netif_running(ndev))
> +		return 0;
This deserves a comment in the code as to why it is needed and how it
still works.

Regards,
Lucas
> +
>  	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
>  		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
>  		fep->hwp + FEC_ADDR_LOW);

-- 
Pengutronix e.K.             | Lucas Stach                 |
Industrial Linux Solutions   | http://www.pengutronix.de/  |
