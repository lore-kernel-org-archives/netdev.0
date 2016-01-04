From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 03/24] phy: Use phy_read() instead of mdiobus_read()
Date: Mon, 04 Jan 2016 12:07:43 -0800
Message-ID: <568AD10F.7070005@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35401 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbcADUIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:08:15 -0500
Received: by mail-pa0-f68.google.com with SMTP id gi1so22885995pac.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:08:15 -0800 (PST)
In-Reply-To: <1451929022-5580-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Since we have a phydev, make use of it and the phy_read() function.
> This will help with later refactoring.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---

[snip]


> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 47cd306dbb3c..67a77956ae6f 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -407,8 +407,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
>  		/* fall through */
>  
>  	case SIOCGMIIREG:
> -		mii_data->val_out = mdiobus_read(phydev->bus, mii_data->phy_id,
> -						 mii_data->reg_num);
> +		mii_data->val_out = phy_read(phydev, mii_data->reg_num);
>  		return 0;

Do we have any guarantee that users of this interface do a prior
SIOCGMIIPHY ioctl() to select the PHY address? If not, then this change
forces it. Arguably, you are current allowed to issue MII reads/writes
using a PHY device that can be different from the intent, that does not
sound like a robust interface...

>  
>  	case SIOCSMIIREG:
> @@ -445,8 +444,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
>  			}
>  		}
>  
> -		mdiobus_write(phydev->bus, mii_data->phy_id,
> -			      mii_data->reg_num, val);
> +		phy_write(phydev, mii_data->reg_num, val);

Same here.

>  
>  		if (mii_data->phy_id == phydev->addr &&
>  		    mii_data->reg_num == MII_BMCR &&
> 


-- 
Florian
