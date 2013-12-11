From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC] mlx4_en: Add PTP hardware clock
Date: Wed, 11 Dec 2013 21:35:11 +0000
Message-ID: <1386797711.1516.279.camel@bwh-desktop.uk.level5networks.com>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, <tomk@rgmadvisors.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63428 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab3LKVfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 16:35:16 -0500
In-Reply-To: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 12:24 -0600, Shawn Bohrer wrote:
[...]
> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
[...]
> -void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
> -{
> -	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
> -					      mdev->overflow_period);
> +	/* Configure the PHC */
> +	mdev->ptp_clock_info = mlx4_en_ptp_clock_info;
> +	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
> +		snprintf(mdev->ptp_clock_info.name,
> +			 sizeof(mdev->ptp_clock_info.name), "%pm",
[...]

Name should be "mlx4", I think.

Does each function have an independent clock or is this shared between
functions?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
