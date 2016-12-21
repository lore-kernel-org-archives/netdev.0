From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: check if parent device is NULL
Date: Tue, 20 Dec 2016 16:33:53 -0800
Message-ID: <8cdfecf2-60c1-121d-a708-20de9f44d906@gmail.com>
References: <87oa06upl5.fsf@babayev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Ruslan Babayev <ruslan@babayev.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34257 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754484AbcLUAd4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 19:33:56 -0500
Received: by mail-pg0-f66.google.com with SMTP id b1so14023658pgc.1
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 16:33:56 -0800 (PST)
In-Reply-To: <87oa06upl5.fsf@babayev.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2016 03:51 PM, Ruslan Babayev wrote:
> Fixes a crash observed on Octeon.
> 
> Signed-off-by: Ruslan Babayev <ruslan@babayev.com>
> Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a
> different owner")

Assuming you saw this with the staging Octeon driver, a fix has already
been submitted:

https://lkml.org/lkml/2016/12/14/756

If this is with a different driver, I would rather we fix it in a
similar way that the fix proposed above.

Thanks

> ---
>  drivers/net/phy/phy_device.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 9c06f8028f0c..043328b85643 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -905,7 +905,8 @@ EXPORT_SYMBOL(phy_attached_print);
>  int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  		      u32 flags, phy_interface_t interface)
>  {
> -	struct module *ndev_owner = dev->dev.parent->driver->owner;
> +	struct device *parent = dev->dev.parent;
> +	struct module *ndev_owner = parent ? parent->driver->owner : NULL;
>  	struct mii_bus *bus = phydev->mdio.bus;
>  	struct device *d = &phydev->mdio.dev;
>  	int err;
> 


-- 
Florian
