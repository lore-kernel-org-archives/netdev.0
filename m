From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Thu, 11 Jun 2015 00:06:13 -0700 (PDT)
Message-ID: <20150611.000613.1622512781124407517.davem@davemloft.net>
References: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, bblanco@plumgrid.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbFKHGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:06:14 -0400
In-Reply-To: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 10 Jun 2015 13:56:02 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Fix a BUG() where CONFIG_NET_SWITCHDEV is set but the driver for a bridged
> port does not support switchdec_port_attr_set op.  Don't BUG() if
> -EOPNOTSUPP is returned.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  net/switchdev/switchdev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index e008057..99bced4 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -103,7 +103,7 @@ static void switchdev_port_attr_set_work(struct work_struct *work)
>  
>  	rtnl_lock();
>  	err = switchdev_port_attr_set(asw->dev, &asw->attr);
> -	BUG_ON(err);
> +	BUG_ON(err && err != -EOPNOTSUPP);
>  	rtnl_unlock();
>  
>  	dev_put(asw->dev);

I agree with other feedback, in that this function can return other "normal"
errors like -ENOMEM and that's not absolutely not BUG_ON() material.
