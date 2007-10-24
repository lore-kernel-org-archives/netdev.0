From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] PowerPC: Add BCM5248 and Marvell 88E1111 PHY support
	to NEW EMAC.
Date: Wed, 24 Oct 2007 13:31:58 +1000
Message-ID: <1193196718.2085.35.camel@pasglop>
References: <20071015175717.GA4602@ru.mvista.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	jwboyer@linux.vnet.ibm.com, jeff@garzik.org
To: Valentine Barshak <vbarshak@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53032 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503AbXJXDdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 23:33:35 -0400
In-Reply-To: <20071015175717.GA4602@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-10-23 at 20:57 -0500, Valentine Barshak wrote:

> +static int m88e1111_init(struct mii_phy *phy)
> +{
> +	printk("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
> +	phy_write(phy, 0x14, 0x0ce3);
> +	phy_write(phy, 0x18, 0x4101);
> +	phy_write(phy, 0x09, 0x0e00);
> +	phy_write(phy, 0x04, 0x01e1);
> +	phy_write(phy, 0x00, 0x9140);
> +	phy_write(phy, 0x00, 0x1140);
> +
> +	return  0;
> +}

Care to put a few comments on why the above is necessary and what it
does ?

Thanks !
Ben.

> +static struct mii_phy_ops m88e1111_phy_ops = {
> +	.init		= m88e1111_init,
> +	.setup_aneg	= genmii_setup_aneg,
> +	.setup_forced	= genmii_setup_forced,
> +	.poll_link	= genmii_poll_link,
> +	.read_link	= genmii_read_link
> +};
> +
> +static struct mii_phy_def m88e1111_phy_def = {
> +
> +	.phy_id		= 0x01410CC0,
> +	.phy_id_mask	= 0x0ffffff0,
> +	.name		= "Marvell 88E1111 Ethernet",
> +	.ops		= &m88e1111_phy_ops,
> +};
> +
>  static struct mii_phy_def *mii_phy_table[] = {
>  	&cis8201_phy_def,
> +	&bcm5248_phy_def,
> +	&m88e1111_phy_def,
>  	&genmii_phy_def,
>  	NULL
>  };

