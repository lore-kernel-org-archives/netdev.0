From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] atm: lec use dev_change_mtu
Date: Fri, 20 Mar 2009 15:45:20 +0800
Message-ID: <49C34990.1020500@cn.fujitsu.com>
References: <20090319172400.239594f8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50730 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbZCTHqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 03:46:14 -0400
In-Reply-To: <20090319172400.239594f8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Rather than calling device pointer directly (which is incorrect with
> net_device_ops), use the standard dev_change_mtu. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/atm/lec.c	2009-03-19 17:18:35.140652628 -0700
> +++ b/net/atm/lec.c	2009-03-19 17:19:19.500777355 -0700
> @@ -502,7 +502,7 @@ static int lec_atm_send(struct atm_vcc *
>  		priv->lane2_ops = NULL;
>  		if (priv->lane_version > 1)
>  			priv->lane2_ops = &lane2_ops;
> -		if (dev->change_mtu(dev, mesg->content.config.mtu))
> +		if (dev_set_mtu(dev, mesg->content.config.mtu))

I think it's not correct.This dev->change_mtu is:
 663 static int lec_change_mtu(struct net_device *dev, int new_mtu)
 664 {
 665         if ((new_mtu < 68) || (new_mtu > 18190))
 666                 return -EINVAL;
 667         dev->mtu = new_mtu;
		^^^^^^^^^^^^^^^^maybe should use dev_set_mtu() here.
 668         return 0;
 669 }

and it's not quite same as dev_set_mtu.

>  			printk("%s: change_mtu to %d failed\n", dev->name,
>  			       mesg->content.config.mtu);
>  		priv->is_proxy = mesg->content.config.is_proxy;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


-- 
Regards
Yang Hongyang
