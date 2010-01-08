From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] drivers/net/skfp/skfddi.c: use %pMF to show MAC address
Date: Fri, 8 Jan 2010 11:02:24 +1100
Message-ID: <20100108000224.GH2436@verge.net.au>
References: <201001071627.46569.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55585 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706Ab0AHAC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 19:02:27 -0500
Content-Disposition: inline
In-Reply-To: <201001071627.46569.hartleys@visionengravers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 04:27:46PM -0700, H Hartley Sweeten wrote:
> Use the %pMF kernel extension to display the MAC address.
> 
> The address will still be displayed in the FDDI Canonical format.

I'm not sure that it matters, but prior to this patch
the address was displayed with octets delimited by spaces,
and afterwards its delimited by hyphens. So perhaps the comment
should read:

The address will now be displayed in the FDDI Canonical format.

> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: David S. Miller <davem@davemloft.net>
> 
> ---
> 
> diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
> index db216a7..1f9698c 100644
> --- a/drivers/net/skfp/skfddi.c
> +++ b/drivers/net/skfp/skfddi.c
> @@ -435,13 +435,7 @@ static  int skfp_driver_init(struct net_device *dev)
>  		goto fail;
>  	}
>  	read_address(smc, NULL);
> -	pr_debug(KERN_INFO "HW-Addr: %02x %02x %02x %02x %02x %02x\n",
> -	       smc->hw.fddi_canon_addr.a[0],
> -	       smc->hw.fddi_canon_addr.a[1],
> -	       smc->hw.fddi_canon_addr.a[2],
> -	       smc->hw.fddi_canon_addr.a[3],
> -	       smc->hw.fddi_canon_addr.a[4],
> -	       smc->hw.fddi_canon_addr.a[5]);
> +	pr_debug(KERN_INFO "HW-Addr: %pMF\n", smc->hw.fddi_canon_addr.a);
>  	memcpy(dev->dev_addr, smc->hw.fddi_canon_addr.a, 6);
>  
>  	smt_reset_defaults(smc, 0);
> @@ -890,15 +884,8 @@ static void skfp_ctl_set_multicast_list_wo_lock(struct net_device *dev)
>  							  (struct fddi_addr *)dmi->dmi_addr, 
>  							  1);
>  
> -					pr_debug(KERN_INFO "ENABLE MC ADDRESS:");
> -					pr_debug(" %02x %02x %02x ",
> -					       dmi->dmi_addr[0],
> -					       dmi->dmi_addr[1],
> -					       dmi->dmi_addr[2]);
> -					pr_debug("%02x %02x %02x\n",
> -					       dmi->dmi_addr[3],
> -					       dmi->dmi_addr[4],
> -					       dmi->dmi_addr[5]);
> +					pr_debug(KERN_INFO "ENABLE MC ADDRESS: %pMF\n",
> +						dmi->dmi_addr);
>  					dmi = dmi->next;
>  				}	// for
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
