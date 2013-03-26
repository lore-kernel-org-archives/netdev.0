From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: fec: TX Buffer incorrectly initialized
Date: Tue, 26 Mar 2013 08:44:04 -0700
Message-ID: <1364312644.1716.33.camel@edumazet-glaptop>
References: <y> <1364311507-7489-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:64988 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965117Ab3CZPoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 11:44:07 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so1064299pdj.30
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 08:44:06 -0700 (PDT)
In-Reply-To: <1364311507-7489-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 15:25 +0000, Jim Baxter wrote:
> The TX Buffer in fec_enet_alloc_buffers was being initialized
> with the receive register define BD_ENET_RX_INT instead of
> the transmit register define BD_ENET_TX_INT
> 
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 3eb608f..2b78a1e 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1391,7 +1391,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
>  
>  		if (fep->bufdesc_ex) {
>  			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
> -			ebdp->cbd_esc = BD_ENET_RX_INT;
> +			ebdp->cbd_esc = BD_ENET_TX_INT;
>  		}
>  
>  		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);

I am curious. What is the point having cbd_esc ?

Its a written only field.
