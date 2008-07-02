From: Adrian Bunk <bunk@kernel.org>
Subject: Re: WAN: Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP
	doesn't exist
Date: Wed, 2 Jul 2008 23:17:55 +0300
Message-ID: <20080702201754.GA2145@cs181140183.pp.htv.fi>
References: <m3r6ac3xs8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:60139 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753115AbYGBUSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 16:18:21 -0400
Content-Disposition: inline
In-Reply-To: <m3r6ac3xs8.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 02, 2008 at 09:12:55PM +0200, Krzysztof Halasa wrote:
> For review only, the actual patch will be made available in git.
> 
> Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP doesn't exist
>     
> diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
> index 9ab31a3..6c20205 100644
> --- a/net/wanrouter/wanmain.c
> +++ b/net/wanrouter/wanmain.c
> @@ -565,9 +565,6 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
>  {
>  	wanif_conf_t *cnf;
>  	struct net_device *dev = NULL;
> -#ifdef CONFIG_WANPIPE_MULTPPP
> -	struct ppp_device *pppdev=NULL;
> -#endif
>  	int err;
>  
>  	if ((wandev->state == WAN_UNCONFIGURED) || (wandev->new_if == NULL))
> @@ -586,25 +583,10 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
>  		goto out;
>  
>  	if (cnf->config_id == WANCONFIG_MPPP) {
> -#ifdef CONFIG_WANPIPE_MULTPPP
> -		pppdev = kzalloc(sizeof(struct ppp_device), GFP_KERNEL);
> -		err = -ENOBUFS;
> -		if (pppdev == NULL)
> -			goto out;
> -		pppdev->dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
> -		if (pppdev->dev == NULL) {
> -			kfree(pppdev);
> -			err = -ENOBUFS;
> -			goto out;
> -		}
> -		err = wandev->new_if(wandev, (struct net_device *)pppdev, cnf);
> -		dev = pppdev->dev;
> -#else
>  		printk(KERN_INFO "%s: Wanpipe Mulit-Port PPP support has not been compiled in!\n",
>  				wandev->name);

The printk() also needs some updating.

>  		err = -EPROTONOSUPPORT;
>  		goto out;
> -#endif
>  	} else {
>  		dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
>  		err = -ENOBUFS;
> @@ -659,17 +641,9 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
>  	kfree(dev->priv);
>  	dev->priv = NULL;
>  
> -#ifdef CONFIG_WANPIPE_MULTPPP
> -	if (cnf->config_id == WANCONFIG_MPPP)
> -		kfree(pppdev);
> -	else
> -		kfree(dev);
> -#else
>  	/* Sync PPP is disabled */
>  	if (cnf->config_id != WANCONFIG_MPPP)
>  		kfree(dev);
> -#endif
> -
>  out:
>  	kfree(cnf);
>  	return err;
> 
> Krzysztof Halasa

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

