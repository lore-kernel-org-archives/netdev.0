From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: Invalidate LP advertising flags when
 restarting or disabling AN
Date: Mon, 26 Jan 2015 17:06:49 -0800
Message-ID: <54C6E4A9.6070603@gmail.com>
References: <1422320295.3524.26.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:47985 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbbA0BHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 20:07:07 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so14916848pad.4
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 17:07:07 -0800 (PST)
In-Reply-To: <1422320295.3524.26.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/15 16:58, Ben Hutchings wrote:
> It is possible to see the old value of the LP advertising flags
> through ethtool after reconfiguring the PHY and before autonegotiation
> completes.  If autonegotiation is turned off then the last value seen
> will persist indefinitely.

Good catch!

> 
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/phy.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 767cd11..cdcac6a 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -439,6 +439,9 @@ int phy_start_aneg(struct phy_device *phydev)
>  	if (AUTONEG_DISABLE == phydev->autoneg)
>  		phy_sanitize_settings(phydev);
>  
> +	/* Invalidate LP advertising flags */
> +	phydev->lp_advertising = 0;
> +
>  	err = phydev->drv->config_aneg(phydev);
>  	if (err < 0)
>  		goto out_unlock;
> 


-- 
Florian
