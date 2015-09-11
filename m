From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next 1/4] phylib: Add phy_set_max_speed helper
Date: Fri, 11 Sep 2015 16:34:58 +0300
Message-ID: <55F2D882.20908@cogentembedded.com>
References: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
 <1441936878-18290-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:33434 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbbIKNfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 09:35:00 -0400
Received: by lbcjc2 with SMTP id jc2so39662705lbc.0
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 06:34:59 -0700 (PDT)
In-Reply-To: <1441936878-18290-2-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/11/2015 5:01 AM, Simon Horman wrote:

> Add a helper to allow ethernet drivers to limit the speed of a phy
> (that they are attached to).
>
> This mainly involves factoring out the business-end of
> of_set_phy_supported() and exporting a new symbol.
>
> This code seems to be open coded in several places, in several different
> variants.
>
> This code is envisaged this will be used in situations where setting
> the "max-speed" property is not appropriate, e.g. because the maximum
> speed is not a property of the phy hardware.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
> ---
>
> v2
> * First post
> ---
>   drivers/net/phy/phy_device.c | 52 ++++++++++++++++++++++++++++----------------
>   include/linux/phy.h          |  1 +
>   2 files changed, 34 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index c0f211127274..d9a020095972 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1205,6 +1205,37 @@ static int gen10g_resume(struct phy_device *phydev)
>   	return 0;
>   }
>
> +static void __set_phy_supported(struct phy_device *phydev, u32 max_speed)
> +{
> +	if (!IS_ENABLED(CONFIG_OF_MDIO))
> +		return;
> +
> +	/* The default values for phydev->supported are provided by the PHY
> +	 * driver "features" member, we want to reset to sane defaults fist

    s/fist/first/.

> +	 * before supporting higher speeds.
> +	 */
> +	phydev->supported &= PHY_DEFAULT_FEATURES;
> +
> +	switch (max_speed) {
> +	default:
> +		return;
> +

    I don't think empty line is needed here.

> +	case SPEED_1000:
> +		phydev->supported |= PHY_1000BT_FEATURES;

    Need a comment like /* Fall thru */.

> +	case SPEED_100:
> +		phydev->supported |= PHY_100BT_FEATURES;

    And here.

> +	case SPEED_10:
> +		phydev->supported |= PHY_10BT_FEATURES;
> +	}
> +}
[...]

MBR, Sergei
