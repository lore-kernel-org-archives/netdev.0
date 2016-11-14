From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2] net: dummy: Introduce dummy virtual
 functions
Date: Mon, 14 Nov 2016 06:23:11 -0800
Message-ID: <1479133391.8455.52.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161114130205.18333-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Sabrina Dubroca <sd@queasysnail.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35988 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751750AbcKNOXN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 09:23:13 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so9119110pgx.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 06:23:13 -0800 (PST)
In-Reply-To: <20161114130205.18333-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 14:02 +0100, Phil Sutter wrote:
> The idea for this was born when testing VF support in iproute2 which was
> impeded by hardware requirements. In fact, not every VF-capable hardware
> driver implements all netdev ops, so testing the interface is still hard
> to do even with a well-sorted hardware shelf.
> 
...
>  static int dummy_dev_init(struct net_device *dev)
>  {
> +	struct dummy_priv *priv = netdev_priv(dev);
> +
>  	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
>  	if (!dev->dstats)
>  		return -ENOMEM;
>  
> +	priv->num_vfs = num_vfs;
> +	priv->vfinfo = NULL;
> +
> +	if (!num_vfs)
> +		return 0;
> +
> +	priv->vfinfo = kcalloc(num_vfs, sizeof(struct vf_data_storage),
> +			       GFP_KERNEL);
> +	if (!priv->vfinfo)
> +		return -ENOMEM;

You must free dev->dstats here, otherwise kernel memory will leak. 

> +
>  	return 0;
>  }
>  
