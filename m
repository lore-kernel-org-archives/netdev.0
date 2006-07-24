From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 0/2] PHYLIB: Fix forcing mode reduction
Date: Mon, 24 Jul 2006 11:40:46 -0500
Message-ID: <1D5FF487-7443-4BBF-B61D-51CC8AD9BAB4@kernel.crashing.org>
References: <1149551159.10700.46.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Nathaniel Case <ncase@xes-inc.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:48824 "EHLO
	nommos.sslcatacombnetworking.com") by vger.kernel.org with ESMTP
	id S932208AbWGXQky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 12:40:54 -0400
In-Reply-To: <1149551159.10700.46.camel@localhost.localdomain>
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Any status on accepting this patch, I've got some additional fixes  
that are based on having access to genphy_update_link()

- kumar

On Jun 5, 2006, at 6:45 PM, Nathaniel Case wrote:

> On Mon, 2006-06-05 at 17:08 -0500, Andy Fleming wrote:
>> Looks good.  Feel free to send these patches to
>> netdev@vger.kernel.org (you may need to subscribe), and copy Jeff
>> Garzik <jeff@garzik.org>.
>
> This fixes a problem seen when a port without a cable connected would
> repeatedly print out "Trying 1000/HALF".  While in the PHY_FORCING
> state, the call to phy_read_status() was resetting the value of
> phydev->speed and phydev->duplex, preventing it from incrementally
> trying the speed/duplex variations.
>
> Since we really just want the link status updated for the PHY_FORCING
> state, calling genphy_update_link() instead of phy_read_status() fixes
> this issue.
>
> Patch tested on a MPC8540 platform with a BCM5421 PHY.
>
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>
>
> ---
>
> --- a/drivers/net/phy/phy.c	2006-06-04 16:01:59.000000000 -0500
> +++ b/drivers/net/phy/phy.c	2006-06-05 10:55:31.000000000 -0500
> @@ -767,7 +783,7 @@
>  			}
>  			break;
>  		case PHY_FORCING:
> -			err = phy_read_status(phydev);
> +			err = genphy_update_link(phydev);
>
>  			if (err)
>  				break;
> --- a/drivers/net/phy/phy_device.c	2006-06-04 16:02:08.000000000 -0500
> +++ b/drivers/net/phy/phy_device.c	2006-06-04 19:12:26.000000000 -0500
> @@ -417,6 +417,7 @@
>
>  	return 0;
>  }
> +EXPORT_SYMBOL(genphy_update_link);
>
>  /* genphy_read_status
>   *
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

