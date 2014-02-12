From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 04/10] net: phy: add genphy_aneg_done()
Date: Wed, 12 Feb 2014 18:43:38 +0400
Message-ID: <52FB889A.4000207@cogentembedded.com>
References: <1392168462-18888-1-git-send-email-f.fainelli@gmail.com> <1392168462-18888-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:53424 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaBLOnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:43:42 -0500
Received: by mail-lb0-f171.google.com with SMTP id c11so7091793lbj.2
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 06:43:40 -0800 (PST)
In-Reply-To: <1392168462-18888-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-02-2014 5:27, Florian Fainelli wrote:

> In preparation for allowing PHY drivers to potentially override their
> auto-negotiation done callback, move the contents of phy_aneg_done() to
> genphy_aneg_done() since that function really is the generic
> implementation based on the BMSR_ANEGCOMPLETE status.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 82514e7..4e7db72 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -865,6 +865,22 @@ int genphy_config_aneg(struct phy_device *phydev)
>   }
>   EXPORT_SYMBOL(genphy_config_aneg);
>
> +/**
> + * genphy_aneg_done - return auto-negotiation status
> + * @phydev: target phy_device struct
> + *
> + * Description: Reads the status register and returns 0 either if
> + *   auto-negotiation is incomplete, or if there was an error.
> + *   Returns BMSR_ANEGCOMPLETE if auto-negotiation is done.
> + */
> +int genphy_aneg_done(struct phy_device *phydev)
> +{
> +	int retval = phy_read(phydev, MII_BMSR);
> +
> +	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);

    I doubt parens are needed here.

WBR, Sergei
