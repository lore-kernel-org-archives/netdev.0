From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 08/16] mlx4_en: Reporting HW revision in ethtool -i
Date: Wed, 23 Mar 2011 14:04:14 +0000
Message-ID: <1300889054.26693.527.camel@localhost>
References: <4D89B16F.4040008@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eugenia@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9098 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab1CWOES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 10:04:18 -0400
In-Reply-To: <4D89B16F.4040008@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-23 at 10:38 +0200, Yevgeny Petrilin wrote:
> HW revision is derived from device ID and rev id.
[...]
> -	sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
> +	switch (mdev->dev->rev_id) {
> +	case 0xa0:
> +		if (dev->dev_id >= MLX4_EN_CX3_LOW_ID && dev->dev_id <= MLX4_EN_CX3_HIGH_ID)
> +			sprintf(drvinfo->driver, DRV_NAME " (%s_CX-3)", mdev->dev->board_id);
> +		else
> +			sprintf(drvinfo->driver, DRV_NAME " (%s_CX)", mdev->dev->board_id);
> +		break;
> +	case 0xb0:
> +		sprintf(drvinfo->driver, DRV_NAME " (%s_CX-2)", mdev->dev->board_id);
> +		break;
> +	default:
> +		sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
> +		break;
[...]

This is an abuse of the ethtool_drvinfo::driver field.

Your users can use lspci -v, can't they?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

