From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 2/2] net: phy: Marvell: Add mv88e6390 internal PHY
Date: Thu, 26 Jan 2017 13:01:06 +0100
Message-ID: <87y3xyyqrh.fsf@free-electrons.com>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
        <1485309314-23942-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:51874 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753588AbdAZMBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 07:01:16 -0500
In-Reply-To: <1485309314-23942-3-git-send-email-andrew@lunn.ch> (Andrew Lunn's
        message of "Wed, 25 Jan 2017 02:55:14 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
 
 On mer., janv. 25 2017, Andrew Lunn <andrew@lunn.ch> wrote:


> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index b5b73ff4329a..9debe1a4a6f6 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -2140,6 +2140,25 @@ static struct phy_driver marvell_drivers[] = {
>  		.get_strings = marvell_get_strings,
>  		.get_stats = marvell_get_stats,
>  	},
> +	{
> +		.phy_id = MARVELL_PHY_ID_88E6390,
> +		.phy_id_mask = MARVELL_PHY_ID_MASK,
> +		.name = "Marvell 88E6390",
> +		.features = PHY_GBIT_FEATURES,
> +		.flags = PHY_HAS_INTERRUPT,
> +		.probe = marvell_probe,

In order to get the temperature support I also had to modify the line
above by using m88e1510_probe instead of the marvell_probe. Indeed the
hwmon register was not done marvell_probe.

I think that you use marvell_probe because currently the value you get
are wrong for 6390. So either we have the 6390 which returns an
incorrect value for the temperature until you find the correct setting
or we introduce a new phy_id for the 6341 family with the hwmon support.

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
