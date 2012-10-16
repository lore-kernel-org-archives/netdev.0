From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net dsa: add phy's interrupts management
Date: Tue, 16 Oct 2012 10:03:29 +0200
Message-ID: <20121016080329.GI15785@wantstofly.org>
References: <1350308008-17189-1-git-send-email-giometti@linux.it>
 <1350308008-17189-4-git-send-email-giometti@linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rodolfo Giometti <giometti@linux.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61758 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab2JPILg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 04:11:36 -0400
Content-Disposition: inline
In-Reply-To: <1350308008-17189-4-git-send-email-giometti@linux.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 15, 2012 at 03:33:28PM +0200, Rodolfo Giometti wrote:

> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 6e9e4546..817bbbd 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -340,6 +340,11 @@ static const struct net_device_ops trailer_netdev_ops = {
>  };
>  #endif
>  
> +static void dsa_slave_handle_link_change(struct net_device *dev)
> +{
> +	/* nop */
> +}
> +
>  /* slave device setup *******************************************************/
>  struct net_device *
>  dsa_slave_create(struct dsa_switch *ds, struct device *parent,
> @@ -400,8 +405,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	netif_carrier_off(slave_dev);
>  
>  	if (p->phy != NULL) {
> -		phy_attach(slave_dev, dev_name(&p->phy->dev),
> -			   0, PHY_INTERFACE_MODE_GMII);
> +		phy_connect_direct(p->dev, p->phy, dsa_slave_handle_link_change,
> +				0, PHY_INTERFACE_MODE_GMII);
>  
>  		p->phy->autoneg = AUTONEG_ENABLE;

What does this do?
