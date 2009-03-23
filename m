From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 09/77] irda: convert mcs driver to net_device_ops
Date: Mon, 23 Mar 2009 12:34:17 +0100
Message-ID: <20090323113417.GF8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.225888375@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:34408 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754200AbZCWLcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:32:05 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.225888375@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:36PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> ---
>  drivers/net/irda/mcs7780.c |   13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> --- a/drivers/net/irda/mcs7780.c	2009-03-19 22:40:30.408964174 -0700
> +++ b/drivers/net/irda/mcs7780.c	2009-03-19 22:42:47.157714010 -0700
> @@ -873,6 +873,13 @@ static int mcs_hard_xmit(struct sk_buff 
>  	return ret;
>  }
>  
> +static const struct net_device_ops mcs_netdev_ops = {
> +	.ndo_open = mcs_net_open,
> +	.ndo_stop = mcs_net_close,
> +	.ndo_start_xmit = mcs_hard_xmit,
> +	.ndo_do_ioctl = mcs_net_ioctl,
> +};
> +
>  /*
>   * This function is called by the USB subsystem for each new device in the
>   * system.  Need to verify the device and if it is, then start handling it.
> @@ -919,11 +926,7 @@ static int mcs_probe(struct usb_interfac
>  	/* Speed change work initialisation*/
>  	INIT_WORK(&mcs->work, mcs_speed_work);
>  
> -	/* Override the network functions we need to use */
> -	ndev->hard_start_xmit = mcs_hard_xmit;
> -	ndev->open = mcs_net_open;
> -	ndev->stop = mcs_net_close;
> -	ndev->do_ioctl = mcs_net_ioctl;
> +	ndev->netdev_ops = &mcs_netdev_ops;
>  
>  	if (!intf->cur_altsetting)
>  		goto error2;
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
