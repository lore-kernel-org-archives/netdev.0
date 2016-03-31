From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: [PATCH] fec: Do not access unexisting register in Coldfire
Date: Fri, 1 Apr 2016 09:43:34 +1000
Message-ID: <56FDB626.9040107@uclinux.org>
References: <1459436717-12809-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out2.external.iinet.net.au ([203.59.1.155]:47708
	"EHLO icp-osb-irony-out2.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757589AbcCaXnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:43:24 -0400
In-Reply-To: <1459436717-12809-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for taking care of that Fabio.

Regards
Greg


On 01/04/16 01:05, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Commit 55cd48c821de ("net: fec: stop the "rcv is not +last, " error
> messages") introduces a write to a register that does not exist in
> Coldfire.
> 
> Move the FEC_FTRL register access inside the FEC_QUIRK_HAS_RACC 'if' block,
> so that we guarantee it will not be used on Coldfire CPUs.
> 
> Reported-by: Greg Ungerer <gerg@uclinux.org>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 37c0815..08243c2 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -943,8 +943,8 @@ fec_restart(struct net_device *ndev)
>  		else
>  			val &= ~FEC_RACC_OPTIONS;
>  		writel(val, fep->hwp + FEC_RACC);
> +		writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
>  	}
> -	writel(PKT_MAXBUF_SIZE, fep->hwp + FEC_FTRL);
>  #endif
>  
>  	/*
> 
