From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] remove bogus CONFIG_GFAR_NAPI's
Date: Thu, 07 Aug 2008 02:11:46 -0400
Message-ID: <489A9222.4020902@garzik.org>
References: <20080804085936.GB6088@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Scott Wood <scottwood@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47913 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753791AbYHGGL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:11:57 -0400
In-Reply-To: <20080804085936.GB6088@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> The commit that made the CONFIG_GFAR_NAPI code unconditional was 
> included at the same time as a new CONFIG_GFAR_NAPI user, resulting
> in these bugus #ifdef's.
> 
> Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/gianfar.c |    4 ----
>  1 file changed, 4 deletions(-)
> 
> f30b77c42e33dee1d469a1f1fd0fcfd9cdc26761 
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index b8394cf..ca6cf6e 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -414,9 +414,7 @@ static int gfar_suspend(struct platform_device *pdev, pm_message_t state)
>  		spin_unlock(&priv->rxlock);
>  		spin_unlock_irqrestore(&priv->txlock, flags);
>  
> -#ifdef CONFIG_GFAR_NAPI
>  		napi_disable(&priv->napi);
> -#endif
>  
>  		if (magic_packet) {
>  			/* Enable interrupt on Magic Packet */
> @@ -469,9 +467,7 @@ static int gfar_resume(struct platform_device *pdev)
>  
>  	netif_device_attach(dev);
>  
> -#ifdef CONFIG_GFAR_NAPI
>  	napi_enable(&priv->napi);
> -#endif
>  
>  	return 0;

applied


