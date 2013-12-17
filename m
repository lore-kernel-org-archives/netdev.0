From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH net-next 2/2] mlx4_en: Only cycle port if HW timestamp
 config changes
Date: Tue, 17 Dec 2013 14:32:24 -0600
Message-ID: <20131217203224.GC8693@sbohrermbp13-local.rgmadvisors.com>
References: <1387311745-9291-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f42.google.com ([209.85.128.42]:54574 "EHLO
	mail-qe0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997Ab3LQUc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:32:29 -0500
Received: by mail-qe0-f42.google.com with SMTP id b4so5780177qen.1
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 12:32:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1387311745-9291-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 02:22:25PM -0600, Shawn Bohrer wrote:
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
> index 9b0d515..cc6a546 100644
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

Sorry had an email malfunction I'll resend this series again including
a cover and patch 1.

--
Shawn
 
