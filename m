From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next V1 10/11] net/mlx4_en: Fix Supported/Advertised
 link mode reported by ethtool
Date: Tue, 17 Dec 2013 15:46:54 +0000
Message-ID: <1387295214.1799.63.camel@bwh-desktop.uk.level5networks.com>
References: <1387263720-31222-1-git-send-email-amirv@mellanox.com>
	 <1387263720-31222-11-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<netdev@vger.kernel.org>, Rana Shahout <ranas@mellanox.com>,
	"Eugenia Emantayev" <eugenia@mellanox.co.il>,
	Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54786 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab3LQPq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 10:46:59 -0500
In-Reply-To: <1387263720-31222-11-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 09:01 +0200, Amir Vadai wrote:
> From: Rana Shahout <ranas@mellanox.com>
> 
> Correctly report the support for 1/10/40Gbps link-speed as
> supported/advertised link mode in ethtool's get_settings command.
[...]
> +	cmd->supported = SUPPORTED_1000baseT_Full |
> +		SUPPORTED_10000baseT_Full |
> +		SUPPORTED_1000baseKX_Full |
> +		SUPPORTED_10000baseKX4_Full |
> +		SUPPORTED_10000baseKR_Full |
> +		SUPPORTED_10000baseR_FEC |
> +		SUPPORTED_40000baseKR4_Full |
> +		SUPPORTED_40000baseCR4_Full |
> +		SUPPORTED_40000baseSR4_Full |
> +		SUPPORTED_40000baseLR4_Full;
> +
> +	cmd->advertising = ADVERTISED_1000baseT_Full |
> +		ADVERTISED_10000baseT_Full |
> +		ADVERTISED_1000baseKX_Full |
> +		ADVERTISED_10000baseKX4_Full |
> +		ADVERTISED_10000baseKR_Full |
> +		ADVERTISED_10000baseR_FEC |
> +		ADVERTISED_40000baseKR4_Full |
> +		ADVERTISED_40000baseCR4_Full |
> +		ADVERTISED_40000baseSR4_Full |
> +		ADVERTISED_40000baseLR4_Full;
[...]

How is this correct?  You should report the actual capabilities of the
MAC and PHY are present, not the union of all possible modes of all the
supported boards.

(And the Kconfig description for MLX4_EN says '10Gbit Ethernet support',
so if this driver now supports some 40G boards that should be updated.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
