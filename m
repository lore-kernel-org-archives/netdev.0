From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/4] e1000: only enable TSO6 via ethtool when using correct
 hardware
Date: Fri, 27 Jun 2008 01:32:43 -0400
Message-ID: <48647B7B.3030805@garzik.org>
References: <20080619211902.GE22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56675 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbYF0Fcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:32:47 -0400
In-Reply-To: <20080619211902.GE22981@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> When enabling TSO via ethool on e1000, it is possible to set
> NETIF_F_TSO6 on hardware that does not support it.  Setting TSO via
> ethtool now matches the settings used when the hardware is probed.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/e1000/e1000_ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
> index 701531e..a3f6a9c 100644
> --- a/drivers/net/e1000/e1000_ethtool.c
> +++ b/drivers/net/e1000/e1000_ethtool.c
> @@ -347,7 +347,7 @@ e1000_set_tso(struct net_device *netdev, u32 data)
>  	else
>  		netdev->features &= ~NETIF_F_TSO;
>  
> -	if (data)
> +	if (data && (adapter->hw.mac_type > e1000_82547_rev_2))
>  		netdev->features |= NETIF_F_TSO6;

applied


