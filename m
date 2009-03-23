From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 06/77] irda: net_device_ops ioctl fix
Date: Mon, 23 Mar 2009 12:33:30 +0100
Message-ID: <20090323113330.GC8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.012084771@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:43778 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752730AbZCWLbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:31:16 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.012084771@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:33PM -0700, Stephen Hemminger wrote:
> Need to reference net_device_ops not old pointer.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> 
> ---
>  net/irda/irda_device.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> --- a/net/irda/irda_device.c	2009-03-19 22:40:30.469964248 -0700
> +++ b/net/irda/irda_device.c	2009-03-19 22:42:44.867089916 -0700
> @@ -149,13 +149,14 @@ int irda_device_is_receiving(struct net_
>  
>  	IRDA_DEBUG(2, "%s()\n", __func__);
>  
> -	if (!dev->do_ioctl) {
> +	if (!dev->netdev_ops->ndo_do_ioctl) {
>  		IRDA_ERROR("%s: do_ioctl not impl. by device driver\n",
>  			   __func__);
>  		return -1;
>  	}
>  
> -	ret = dev->do_ioctl(dev, (struct ifreq *) &req, SIOCGRECEIVING);
> +	ret = (dev->netdev_ops->ndo_do_ioctl)(dev, (struct ifreq *) &req,
> +					      SIOCGRECEIVING);
>  	if (ret < 0)
>  		return ret;
>  
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
