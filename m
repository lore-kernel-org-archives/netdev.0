From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 4/8] phy: kill useless local variables
Date: Sat, 04 Jan 2014 20:55:14 -0800
Message-ID: <1388897714.17770.3.camel@joe-AO722>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
	 <201401050321.52499.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0146.hostedemail.com ([216.40.44.146]:41767 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750798AbaAEEzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 23:55:18 -0500
In-Reply-To: <201401050321.52499.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-05 at 03:21 +0300, Sergei Shtylyov wrote:
> A number of functions (especially in phy.c) has local variables that were hardly
> needed in the first place -- remove them.
[]
> +++ net-next/drivers/net/phy/phy.c
> @@ -67,12 +67,10 @@ EXPORT_SYMBOL(phy_print_status);
>   */
>  static int phy_clear_interrupt(struct phy_device *phydev)
>  {
> -	int err = 0;
> -
>  	if (phydev->drv->ack_interrupt)
> -		err = phydev->drv->ack_interrupt(phydev);
> +		return phydev->drv->ack_interrupt(phydev);
>  
> -	return err;
> +	return 0;
>  }

My preference for this sort of conversion would be to
make the generic return at the bottom of the block like:

static int phy_clear_interrupt(struct phy_device *phydev)
{
	if (!phydev->drv->ack_interrupt)
		return 0;

	return phydev->drv->ack_interrupt(phydev);
}

> @@ -84,13 +82,11 @@ static int phy_clear_interrupt(struct ph
>   */
>  static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
>  {
> -	int err = 0;
> -
>  	phydev->interrupts = interrupts;
>  	if (phydev->drv->config_intr)
> -		err = phydev->drv->config_intr(phydev);
> +		return phydev->drv->config_intr(phydev);
>  
> -	return err;
> +	return 0;
>  }

etc..,
