From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: by default join ff01::1 and in case of forwarding ff01::2 and ff05:2
Date: Sun, 10 Feb 2013 15:59:22 +0100
Message-ID: <20130210145922.GG18219@order.stressinduktion.org>
References: <20130210133431.GD18219@order.stressinduktion.org> <5117B306.4070402@yoshifuji.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55498 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618Ab3BJO7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 09:59:23 -0500
Content-Disposition: inline
In-Reply-To: <5117B306.4070402@yoshifuji.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 10, 2013 at 11:47:34PM +0900, YOSHIFUJI Hideaki wrote:
> > @@ -611,10 +617,15 @@ static void dev_forward_change(struct inet6_dev *idev)
> >  	if (idev->cnf.forwarding)
> >  		dev_disable_lro(dev);
> >  	if (dev->flags & IFF_MULTICAST) {
> > -		if (idev->cnf.forwarding)
> > +		if (idev->cnf.forwarding) {
> >  			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
> > -		else
> > +			ipv6_dev_mc_inc(dev, &in6addr_interfacelocal_allrouters);
> > +			ipv6_dev_mc_inc(dev, &in6addr_sitelocal_allrouters);
> > +		} else {
> >  			ipv6_dev_mc_dec(dev, &in6addr_linklocal_allrouters);
> > +			ipv6_dev_mc_dec(dev, &in6addr_interfacelocal_allrouters);
> > +			ipv6_dev_mc_inc(dev, &in6addr_sitelocal_allrouters);
>                                     ~~~dec?
> > +		}
> >  	}

Yes, that was the broken part. I fixed it locally and then send out the old
patch file.
