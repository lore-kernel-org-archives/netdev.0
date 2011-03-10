From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/8] macb: convert printk to pr_ and friends
Date: Thu, 10 Mar 2011 14:48:04 -0800
Message-ID: <1299797284.20104.162.camel@Joe-Laptop>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
	 <1299751843-9743-4-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4172 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840Ab1CJWsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 17:48:07 -0500
In-Reply-To: <1299751843-9743-4-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-10 at 10:10 +0000, Jamie Iles wrote:
> macb is already using the dev_dbg() and friends helpers so use pr_foo()
> along with a pr_fmt() definition to make the printing a little cleaner.
> Signed-off-by: Jamie Iles <jamie@jamieiles.com>

Hi Jamie.

Because these conversions use a struct net_device,
they would be better as:

	netdev_<foo>(struct net_device *dev, const char *fmt, ...)

> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> @@ -175,11 +176,11 @@ static void macb_handle_link_change(struct net_device *dev)
>  
>  	if (status_change) {
>  		if (phydev->link)
> -			printk(KERN_INFO "%s: link up (%d/%s)\n",
> +			pr_info("%s: link up (%d/%s)\n",
>  			       dev->name, phydev->speed,
>  			       DUPLEX_FULL == phydev->duplex ? "Full":"Half");

			netdev_info(dev, "link up (%d/%s)\n",
				    phydev->speed,
				    phydev->duplex == DUPLEX_FULL ? "Full" : "Half");
 
>  		else
> -			printk(KERN_INFO "%s: link down\n", dev->name);
> +			pr_info("%s: link down\n", dev->name);

			netdev_info(dev, "link down\n");

> @@ -193,7 +194,7 @@ static int macb_mii_probe(struct net_device *dev)
>  
>  	phydev = phy_find_first(bp->mii_bus);
>  	if (!phydev) {
> -		printk (KERN_ERR "%s: no PHY found\n", dev->name);
> +		pr_err("%s: no PHY found\n", dev->name);

		netdev_err(dev, "no PHY found\n");

> @@ -206,7 +207,7 @@ static int macb_mii_probe(struct net_device *dev)
>  				 PHY_INTERFACE_MODE_RMII :
>  				 PHY_INTERFACE_MODE_MII);
>  	if (ret) {
> -		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
> +		pr_err("%s: Could not attach to PHY\n", dev->name);

		netdev_err(dev, "could not attach to PHY\n");

etc...


