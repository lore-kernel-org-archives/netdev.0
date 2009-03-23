From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 19/77] irda: convert ksdazzle device to net_device_ops
Date: Mon, 23 Mar 2009 12:37:31 +0100
Message-ID: <20090323113731.GP8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.973495714@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:37046 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755978AbZCWLfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:35:17 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.973495714@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:46PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> --- a/drivers/net/irda/ksdazzle-sir.c	2009-03-19 22:52:37.149901612 -0700
> +++ b/drivers/net/irda/ksdazzle-sir.c	2009-03-19 23:08:49.416839813 -0700
> @@ -562,6 +562,13 @@ static int ksdazzle_net_ioctl(struct net
>  	return ret;
>  }
>  
> +static const struct net_device_ops ksdazzle_ops = {
> +	.ndo_start_xmit	= ksdazzle_hard_xmit,
> +	.ndo_open	= ksdazzle_net_open,
> +	.ndo_stop	= ksdazzle_net_close,
> +	.ndo_do_ioctl	= ksdazzle_net_ioctl,
> +};
> +
>  /*
>   * This routine is called by the USB subsystem for each new device
>   * in the system. We need to check if the device is ours, and in
> @@ -684,10 +691,7 @@ static int ksdazzle_probe(struct usb_int
>  	irda_qos_bits_to_value(&kingsun->qos);
>  
>  	/* Override the network functions we need to use */
> -	net->hard_start_xmit = ksdazzle_hard_xmit;
> -	net->open = ksdazzle_net_open;
> -	net->stop = ksdazzle_net_close;
> -	net->do_ioctl = ksdazzle_net_ioctl;
> +	net->netdev_ops = &ksdazzle_ops;
>  
>  	ret = register_netdev(net);
>  	if (ret != 0)
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
