From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 15:51:48 +0100
Message-ID: <20170208145148.GF10855@lunn.ch>
References: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
 <20170208142857.GD10855@lunn.ch>
 <CAOMZO5BzLh4az9t=fJkG80GW3_xdD3YxUbagL4dJp7Hwr4koZw@mail.gmail.com>
 <20170208144029.GE10855@lunn.ch>
 <CAOMZO5CjRbvPJjNDGkOFjz+AZ1ydN9+SRBsypCPyNocPoFOdRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59997 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753928AbdBHPlS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 10:41:18 -0500
Content-Disposition: inline
In-Reply-To: <CAOMZO5CjRbvPJjNDGkOFjz+AZ1ydN9+SRBsypCPyNocPoFOdRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, this is what I am using right now:
> 
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -920,11 +920,6 @@ int phy_attach_direct(struct net_device *dev,
> struct phy_device *phydev,
>                 return -EIO;
>         }
> 
> -       if (!try_module_get(d->driver->owner)) {
> -               dev_err(&dev->dev, "failed to get the device driver module\n");
> -               return -EIO;
> -       }
> -
>         get_device(d);
> 
>         /* Assume that if there is no driver, that it doesn't
> @@ -946,6 +941,11 @@ int phy_attach_direct(struct net_device *dev,
> struct phy_device *phydev,
>                         goto error;
>         }
> 
> +       if (!try_module_get(d->driver->owner)) {
> +               dev_err(&dev->dev, "failed to get the device driver module\n");
> +               return -EIO;
> +       }
> +
>         if (phydev->attached_dev) {
>                 dev_err(&dev->dev, "PHY already attached\n");
>                 err = -EBUSY;
> 
> Would you like me to submit this one?

I'm just wondering about the get_device(d); Does the ordering matter
here? Lets wait for Florian before submitting a patch.

      Andrew
