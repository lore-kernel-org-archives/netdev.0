From: Hadar Hen-Zion <hadarh@dev.mellanox.co.il>
Subject: Re: mlx4_en: Only cycle port if HW timestamp config changes
Date: Wed, 1 Jan 2014 10:52:21 +0200
Message-ID: <20140101085221.GB23104@mtl-eit-vdi-41.mtl.labs.mlnx>
References: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
 <1388511580-3657-3-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:33677 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbaAAIw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 03:52:26 -0500
Received: by mail-ee0-f43.google.com with SMTP id c13so5750887eek.2
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 00:52:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1388511580-3657-3-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/12/13 11:39 -0600, Shawn Bohrer wrote:
> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> If the hwtstamp_config matches what is currently set for the device then
> simply return.  Without this change any program that tries to enable
> hardware timestamps will cause the link to cycle even if hardware
> timstamps were already enabled.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> index 30712b3..abaf6bb 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> @@ -42,6 +42,10 @@ int mlx4_en_timestamp_config(struct net_device *dev, int tx_type, int rx_filter)
>  	int port_up = 0;
>  	int err = 0;
>  
> +	if (priv->hwtstamp_config.tx_type == tx_type &&
> +	    priv->hwtstamp_config.rx_filter == rx_filter)
> +		return 0;
> +
>  	mutex_lock(&mdev->state_lock);
>  	if (priv->port_up) {
>  		port_up = 1;
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Acked-By: Hadar Hen Zion <hadarh@mellanox.com>
