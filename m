From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] net: Kill directly reference of netdev->priv
Date: Tue, 09 Dec 2008 10:53:22 +0800
Message-ID: <493DDDA2.9080100@cn.fujitsu.com>
References: <20081208145333.GB6830@ubuntu> <20081208.122742.46904963.davem@davemloft.net> <20081209013241.GA15483@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jianjun Kong <jianjun@zeuux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60572 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbYLICw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 21:52:27 -0500
In-Reply-To: <20081209013241.GA15483@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jianjun Kong wrote:
> another new patch for net-next-2.6
> ---
>
> >From fbd6be20695810f32aa58a5cd889f959d87a019f Mon Sep 17 00:00:00 2001
> From: Jianjun Kong <jianjun@zeuux.org>
> Date: Tue, 9 Dec 2008 09:23:54 +0800
> Subject: [PATCH] net: Kill directly reference of netdev->priv
>
> drivers/net/wireless/ray_cs.c:
> Replace "(struct net_device *)link->priv" with "netdev_priv((struct net_device *)link)"
>   

You had tested this patch? Do you think your patch is correct? Stop do 
stupid things like this. This only make youself unbelievable.

> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
> ---
>  drivers/net/wireless/ray_cs.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
> index 81b71f0..828aa47 100644
> --- a/drivers/net/wireless/ray_cs.c
> +++ b/drivers/net/wireless/ray_cs.c
> @@ -412,7 +412,7 @@ static int ray_config(struct pcmcia_device *link)
>      int i;
>      win_req_t req;
>      memreq_t mem;
> -    struct net_device *dev = (struct net_device *)link->priv;
> +    struct net_device *dev = netdev_priv((struct net_device *)link);
>      ray_dev_t *local = netdev_priv(dev);
>  
>      DEBUG(1, "ray_config(0x%p)\n", link);
> @@ -784,7 +784,7 @@ static void join_net(u_long data)
>  =============================================================================*/
>  static void ray_release(struct pcmcia_device *link)
>  {
> -    struct net_device *dev = link->priv; 
> +    struct net_device *dev = netdev_priv((struct net_device *)link);
>      ray_dev_t *local = netdev_priv(dev);
>      int i;
>      
> @@ -807,7 +807,7 @@ static void ray_release(struct pcmcia_device *link)
>  
>  static int ray_suspend(struct pcmcia_device *link)
>  {
> -	struct net_device *dev = link->priv;
> +	struct net_device *dev = netdev_priv((struct net_device *)link);
>  
>  	if (link->open)
>  		netif_device_detach(dev);
> @@ -817,7 +817,7 @@ static int ray_suspend(struct pcmcia_device *link)
>  
>  static int ray_resume(struct pcmcia_device *link)
>  {
> -	struct net_device *dev = link->priv;
> +	struct net_device *dev = netdev_priv((struct net_device *)link);
>  
>  	if (link->open) {
>  		ray_reset(dev);
> @@ -2505,7 +2505,7 @@ static void associate(ray_dev_t *local)
>  {
>      struct ccs __iomem *pccs;
>      struct pcmcia_device *link = local->finder;
> -    struct net_device *dev = link->priv;
> +    struct net_device *dev = netdev_priv((struct net_device *)link);
>      int ccsindex;
>      if (!(pcmcia_dev_present(link))) {
>          DEBUG(2,"ray_cs associate - device not present\n");
> @@ -2597,7 +2597,7 @@ static int ray_cs_proc_show(struct seq_file *m, void *v)
>      link = this_device;
>      if (!link)
>      	return 0;
> -    dev = (struct net_device *)link->priv;
> +    dev = netdev_priv((struct net_device *)link);
>      if (!dev)
>      	return 0;
>      local = netdev_priv(dev);
>   

