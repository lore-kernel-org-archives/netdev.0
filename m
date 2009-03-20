From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: lec use dev_change_mtu
Date: Fri, 20 Mar 2009 00:48:41 -0700 (PDT)
Message-ID: <20090320.004841.194259369.davem@davemloft.net>
References: <20090319172400.239594f8@nehalam>
	<49C34990.1020500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47794
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750920AbZCTHs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 03:48:56 -0400
In-Reply-To: <49C34990.1020500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Fri, 20 Mar 2009 15:45:20 +0800

> Stephen Hemminger wrote:
> > Rather than calling device pointer directly (which is incorrect with
> > net_device_ops), use the standard dev_change_mtu. Compile tested only.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/net/atm/lec.c	2009-03-19 17:18:35.140652628 -0700
> > +++ b/net/atm/lec.c	2009-03-19 17:19:19.500777355 -0700
> > @@ -502,7 +502,7 @@ static int lec_atm_send(struct atm_vcc *
> >  		priv->lane2_ops = NULL;
> >  		if (priv->lane_version > 1)
> >  			priv->lane2_ops = &lane2_ops;
> > -		if (dev->change_mtu(dev, mesg->content.config.mtu))
> > +		if (dev_set_mtu(dev, mesg->content.config.mtu))
> 
> I think it's not correct.This dev->change_mtu is:
>  663 static int lec_change_mtu(struct net_device *dev, int new_mtu)
>  664 {
>  665         if ((new_mtu < 68) || (new_mtu > 18190))
>  666                 return -EINVAL;
>  667         dev->mtu = new_mtu;
> 		^^^^^^^^^^^^^^^^maybe should use dev_set_mtu() here.
>  668         return 0;
>  669 }
> 
> and it's not quite same as dev_set_mtu.

dev_set_mtu() calls netdev->ops->ndo_set_mtu() so it will call
this function you are quoting.
